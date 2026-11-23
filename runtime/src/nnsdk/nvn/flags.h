#pragma once
// Live switches: a line "name = 1" in <datos>/mhr.ini (what the settings menu writes; ini.h), or an empty file with that
// name in the data folder (`adb shell touch <datos>/<name>`, `rm` to go back), changes a behaviour without reinstalling
// or restarting the game. The ini wins when it names the switch. Handy to compare an optimisation with and without it
// in the same scene, and to turn it off if something goes wrong.
// Cada interruptor mira su fichero al usarse la primera vez; después los mira todos un hilo propio ("Interruptores")
// una vez por segundo, con un solo readdir de la carpeta de datos, y anota los cambios en el log. Antes cada uno hacía
// su access() en el hilo que lo leía: ~75 búsquedas por segundo en la SD (FUSE → MediaProvider → exFAT) desde el
// executor, el hilo del juego y el del audio, de 0,2-3 ms cada una y paradas del todo cuando la SD se atasca.

#include <dirent.h>
#include <pthread.h>
#include <unistd.h>

#include <atomic>
#include <chrono>
#include <cstdlib>
#include <mutex>
#include <string>
#include <thread>
#include <unordered_set>
#include <vector>

#include "nnsdk/ini.h"
#include "nnsdk/nvn/nvn.h"

namespace nvn {

class LiveFlag {
public:
    explicit LiveFlag(const char* name);
    bool get() const { return value_.load(std::memory_order_relaxed); }
    const char* name() const { return name_; }
    // Desde el hilo de los interruptores.
    void set(bool v) {
        if (v != value_.exchange(v, std::memory_order_relaxed)) NVN_LOG("switch %s: %s\n", name_, v ? "on" : "off");
    }

private:
    const char* name_;
    std::atomic<bool> value_{false};
};

// Los interruptores creados y el hilo que los mira. Nunca se destruye: el hilo sigue hasta que muere el proceso.
class LiveFlags {
public:
    static LiveFlags& instance() {
        static LiveFlags* flags = new LiveFlags;
        return *flags;
    }
    void add(LiveFlag* flag) {
        std::lock_guard lock(mutex_);
        flags_.push_back(flag);
        if (!started_) {
            started_ = true;
            std::thread([this] { run(); }).detach();
        }
    }

private:
    LiveFlags() = default;
    void run() {
#if defined(__ANDROID__) || defined(__linux__)
        pthread_setname_np(pthread_self(), "Interruptores");
#endif
        const char* env = getenv("NIER_DATA");
        const std::string data = env ? env : ".";
        std::unordered_set<std::string> present;
        std::vector<LiveFlag*> flags;
        ::nnsdk::ini::Values values;
        for (;;) {
            std::this_thread::sleep_for(std::chrono::seconds(1));
            DIR* dir = opendir(data.c_str());
            if (!dir) continue;  // la SD no responde: se quedan como estaban
            present.clear();
            while (const dirent* e = readdir(dir)) present.insert(e->d_name);
            closedir(dir);
            // Read every time: the menu saves through a temp file renamed over mhr.ini, and on the SD card's FUSE mount
            // the modification time didn't change visibly from here, so gating on it missed the menu's changes until
            // the game restarted. The file is a few hundred bytes.
            values = ::nnsdk::ini::read();
            {
                std::lock_guard lock(mutex_);
                flags = flags_;
            }
            for (LiveFlag* f : flags) f->set(::nnsdk::ini::on(values, f->name(), present.count(f->name()) != 0));
        }
    }

    std::mutex mutex_;
    std::vector<LiveFlag*> flags_;
    bool started_ = false;
};

inline LiveFlag::LiveFlag(const char* name) : name_(name) {
    const bool v = ::nnsdk::ini::on(name_);
    value_.store(v, std::memory_order_relaxed);
    NVN_LOG("switch %s: %s\n", name_, v ? "on" : "off");
    LiveFlags::instance().add(this);
}

}  // namespace nvn

// true if mhr.ini turns it on (or, without it there, <NIER_DATA>/<name> exists); `name` is a literal (a file name, no
// '/'). Reading it is an atomic load: fine on any path, per draw too.
#define NVN_FLAG(nombre)                     \
    ([]() -> bool {                          \
        static ::nvn::LiveFlag flag(nombre); \
        return flag.get();                   \
    }())
