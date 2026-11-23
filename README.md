<p align="center"><img src="docs/icon.png" width="128" alt=""></p>

# Monster Hunter Rise for Android

A native Android port of the Switch version of **Monster Hunter Rise**, made from **your own copy** of the game. It
isn't an emulator: the game's own ARM64 code runs straight on the phone's CPU, and this project rewrites the parts of the
console it talks to (files, threads, input, audio, and the NVN graphics API on top of Vulkan).

> **Free, unofficial fan project.** Not affiliated with, endorsed or sponsored by Nintendo or Capcom. All trademarks
> belong to their owners. This repository has **no game code and no game assets**: you need a copy of the game you
> bought, with its files extracted on your own console.

**This build** is tuned for the Snapdragon 8 Gen 2 (Adreno 740, tested on an Odin 2 Portal with the Turnip T30 driver): steady ~45 fps with the FPS limit set to 45 and mesh detail lowered, Sunbreak DLC and Steam-save support, and settings from the in-game menu that apply live without restarting. It's a fork of [klark231/mhrise-recomp](https://github.com/klark231/mhrise-recomp).

This started as [IamWilmar's port](https://github.com/IamWilmar/mhrise-recomp) for the Retroid Pocket 5 and Flip 2
(Snapdragon 865). This fork takes it to phones in general: other Adrenos, Mali, Xclipse and PowerVR, stock drivers
and custom ones, high end and low end.

## Status

**Playable.** Kamura, the hunts and Sunbreak (if you have it) run. When a scene gets too heavy the game's internal
resolution drops for a moment instead of the frame rate, and FSR 1 scales the picture up to your screen.

- The first visit to a place can hitch while its shaders are built. They're cached, so it gets smoother as you play.
- Some effects may still look wrong on some GPUs. A bug report from the menu (see below) is the quickest way to get
  one fixed.

## Phones and GPUs

- **Adreno** (Snapdragon): Qualcomm's own driver or Turnip. You can also load a driver of your own from a `.zip` in the
  usual AdrenoTools format (Settings → GPU driver, or on the start screen); if the game can't draw with it,
  the app goes back to the system driver by itself and tells you why.
- **Mali** (MediaTek, Google Tensor, some Exynos): ARM's driver or PanVK. Mali can't read the game's BC textures, so
  they're decoded on the GPU or re-encoded to ASTC (in the background, with a cache so each texture is only done
  once).
- **Xclipse** (Exynos 2200 and newer): BC textures handled as on Mali, and the shader fixes these AMD-based GPUs need.
- **PowerVR:** pipelines are built on one thread, because its shader compiler crashes building several at once.
- **Low memory** (under 5 GB): smaller caches.
- **Benchmark builds** (`-antutu` and `-ludashi` APKs): the same app under a benchmark's package name, which many
  MediaTek and Chinese-brand phones run at full clocks.

The log (`log.txt` in the data folder) says what the port picked for your phone.

## What's in it

- **Touch controls** laid out like a real controller, with a full editor (size, position, opacity, your own pictures
  and shapes), combos and turbo, plus any USB or Bluetooth controller.
- **Settings menu** in the game: resolution, aspect ratio, FPS limit, shadows, effects, overlay stats (FPS, frame time,
  CPU, GPU, RAM, temperature), Local Play and more.
- **Frame generation:** a built-in one (three quality levels), or Lossless Scaling's if you have its DLL.
- **Mods and cheats** like Eden: add a mod's zip, turn each one on or off, and use Atmosphere cheat files with a
  toggle per cheat.
- **Local Play** over Wi-Fi with other copies of the port.

## What you need

- **The game files of version 16.0.1**, already extracted on your own console, as plain folders:
  - **ExeFS** — the folder with `main`, `main.npdm`, `sdk`, … of the game *with update 16.0.1 applied*
    (the app checks the build ID of `main`: `55d50ca1805e9c5bba508d601add852f255a32ba`).
  - **RomFS** — the game's RomFS with the same update applied.
- **DLC (optional, e.g. Sunbreak):** the RomFS of each DLC you own, each in its own folder. Keep the DLC title ID in the
  folder name as your extraction tool named it (for example `... (0100B04011743001) ...`): that is how the app tells the DLC
  apart. Folders named `aoc/<index>` also work.
- Enough free space for the game plus about 1 GB for the shader cache and saves (internal storage or SD card).

**Where do the files come from?** From your own copy of the game: if your console runs custom firmware, its homebrew
tools can extract the ExeFS and RomFS for you. The app only reads those plain folders (it doesn't open packaged or
protected files), which keeps it simple, and it will tell you exactly what is missing if a folder isn't usable. Questions
about the app itself are always welcome in the issues; just please don't share or ask for game files there.

## Install and first run

1. Download `mhriseport-vX.Y.Z.apk` from the [latest release](https://github.com/klark231/mhrise-recomp/releases/latest) (or build
   it yourself, below) and install it on the device.
2. Copy your extracted game folders to the device, anywhere you like (for example one folder `MHRise` with the ExeFS
   and RomFS folders inside).
3. Open the app, grant *All files access*, browse to that folder with the touch screen or the d-pad and choose
   **Use this folder**. The app checks that the files are this game, the right version and not encrypted. It only reads
   that folder.
4. Choose a **data folder**: where the port keeps your saves, the shader cache, `log.txt` and its settings. It can be any
   folder (*New folder here* makes one), or the game folder itself if you'd rather keep everything together.
5. Press **Start game**. From then on the app starts the game directly; to change either folder, switch on
   *Change folder* in the settings panel (see below) or open the app twice in a row (within ten seconds). Changing the
   data folder copies your saves and settings to the new one (the old copy stays until you delete it).

**Two copies on one phone.** A clone of the app (or the AnTuTu / Ludashi build next to the normal one) can play Local Play
with the other copy, as long as each has **its own data folder**: same game folder, different data folders. Each data
folder is its own console user (`user_id.txt`) with its own saves, and the second copy gets its own UDP port.

**Benchmark package builds.** Each release also has `mhriseport-vX.Y.Z-antutu.apk` (package `com.antutu.ABenchMark`) and
`mhriseport-vX.Y.Z-ludashi.apk` (`com.ludashi.benchmark`). They're the same app under a benchmark's package name: some
phones (many MediaTek and Chinese-brand ones) recognise it and keep the CPU and GPU at full clock. They install next to
the normal one, each with its own settings and drivers, so choose the game folder again in each. Uninstall the real
benchmark first if you have it (same package name). Build one yourself with
`PACKAGE=com.antutu.ABenchMark tools/build_apk.sh`.

Saves, the shader cache and `log.txt` are written into the data folder. The first time you visit each place the game
may stutter while its shaders are translated and compiled; they are cached for the next time.

## Controls and the settings panel

- **Controllers are read by position.** Whatever is printed on them, the bottom face button is B, the right one A, the
  top one X and the left one Y, as on the game's own console. That goes for a handheld's built-in controls and for any
  pad over USB or Bluetooth (a DualSense, for example).
- **Settings panel.** Swipe in from the right edge of the screen (the system's back gesture, the one that shows an arrow)
  and a panel slides out over the game. It has a switch for the FPS counter (your choice is remembered) and *Change
  folder*, which brings the folder screen back the next time you open the app. The same swipe, a tap outside the panel
  or a few seconds without touching it hide it again.
- **Touch controls.** A full controller on the screen, laid out like a traditional one: both sticks, the D-pad, A B X Y,
  L R ZL ZR, − and +, and L3 / R3 (also a short tap on a stick, without moving it). A finger can slide from one button to
  the next. The right stick is hidden by default: dragging on the game (camera swipe) turns the camera instead. A tap that
  lands on no control still reaches the game's touch screen.
- **Controls menu.** The gear between − and + opens it:
  - *Touch:* on or off, opacity, size, vibration (off, light, medium, strong), sliding between buttons, the sticks' dead
    zone, the tap for L3 / R3, and camera swipe and its speed (to turn the camera with a stick instead, show the right
    stick in *Edit layout* and turn camera swipe off).
  - *Edit layout:* drag each control where you want it, change its size or hide it from the bar at the top, or put the
    traditional layout back. *Edit* opens the chosen control, any of them: its size, opacity and outline width, a
    plate colour, and a picture of yours instead of its drawing (any image: the app keeps a 256-pixel copy), either
    cut to the control's shape or in its own shape, where only the picture itself takes touches. A stick's picture is
    its knob, and its shape is its base's. Buttons and the menu also get a shape (circle, rounded square, square), an
    icon and your own label, and buttons *Tap to hold* (a tap keeps it pressed until the next tap). *Add* makes a new button and *Copy as a new button* another of a console button;
    both are combos, so a controller button can fire them too. *Grid* shows a grid and snaps what you drag to it.
  - *Export layout* / *Import layout:* the whole touch layout in a `.zip` (`layout.json` and the pictures), to keep or
    to share; places are fractions of the screen, so it fits another phone.
  - *Combos:* up to eight. Each presses several buttons at once (A+X, say, or a stick direction: LS↑ holds the left
    stick all the way up), from its own button on the screen and, if you
    choose one, from a controller button or a pair of them (L3, −+R…). One of a single button is called *Button n* and
    looks like that button; one of several, *Combo n*. Under *Controller → Added buttons and combos* each can also get
    any key of a controller or a keyboard.
  - *Controller:* the sticks' dead zone, how far an analog trigger travels before it is ZL / ZR, and where the right stick
    is read from. *By controller* picks Z/RZ or RX/RY from the axes each pad says it has, with triggers on LTRIGGER /
    RTRIGGER, BRAKE / GAS or Z/RZ, so Xbox, DualSense and generic pads all work. The log says what it chose for each pad.
  - *Button mapping* (under Controller): tap a Switch button and press the controller button you want for it. Analog
    triggers and a hat d-pad can be mapped too, and so can the sticks' directions (a keyboard's WASD as the left
    stick, say). To swap two buttons, map each one to the other; *Reset mapping* puts
    everything back. The log lists each mapping (`[input] controller key … mapped to …`).

## Options

The in-game settings menu (the gear of the touch controls) sets the common ones by section; choices with more than two options open a drop-down, and Display > Menu size scales the menu's text: **Display** (base
resolution, dynamic resolution, FSR, FPS limit, FPS counter), **Graphics** (shadows, texture arrays, anisotropic filtering), **GPU driver** (the system's or one of your own), **Frame generation** (on/off, generator, Quality Preset, Lossless.dll),
**Performance** (performance hints, fast cores, low memory, shader warm-up, pipelines on one thread), and the touch
controls, combos and controller. Underneath, each is a `name = value` line (`1` is on) in `mhr.ini` in your data
folder, which the game checks once a second; the ones only read at start-up say so. You can edit `mhr.ini` by hand
too, and Display → Restore default settings puts everything back (touch layout, combos and button mapping stay). An empty file with the switch's name in the data folder still works for switches the ini doesn't mention (handy
with adb); changing that setting in the menu moves it into the ini.

| Name | Effect |
|---|---|
| `lsfg/` | Frame generation (Lossless Scaling's LSFG) to show ~60 fps. Needs **your own** `Lossless.dll` from the Windows app *Lossless Scaling* (sold on Steam): import it in Settings → Frame generation or on the start screen's GPU driver page (it's copied into the app), or copy it into that `lsfg` folder or to `Download/Lossless.dll`. Not included here. Read at start-up. Its flow scale (how finely it follows motion) is 25 % by default; `lsfg_flow_50` / `lsfg_flow_100` (Settings → Frame generation → Quality Preset) are sharper and heavier. |
| `lsfg/motion.*`, `shaders/fg_*.comp` | The built-in frame generator: no Lossless.dll, plain Vulkan 1.1 compute. Dense optical flow both ways (A to B and B to A) by inverse search, the method of Kroeger et al., *Fast Optical Flow using Dense Inverse Search* (ECCV 2016): a luma pyramid from a quarter of the picture down to 1/32, 8x8 patches every 4 texels refined by Lucas-Kanade against the template's own gradients, then densified per texel by how well each patch fits there. The picture between follows both flows back, uses a forward-backward check to tell covered from uncovered areas and takes those from the frame that sees them, and keeps still pixels such as the HUD unwarped; bicubic samples. Quality Preset (Settings → Frame generation, the same `lsfg_flow_50` / `lsfg_flow_100` switches as LSFG's flow): the finest flow level at 1/4 of the picture (Light, default), 1/3 (Balanced) or 1/2 (Sharp). Used when there's no DLL or Lossless's chain can't run on the GPU, or always with `fg_builtin` (Settings → Frame generation → Generator). Turned on with `lsfg`, as before. |
| `fg_target_60`, `fg_target_90`, `fg_target_120` | Adaptive frame generation (Settings → Frame generation → Target): instead of one generated picture per real frame, as many as reach the target (up to three), placed evenly between the real ones (at 1/3 and 2/3, say), never more than the screen's refreshes between two real frames. A new multiplier has to hold for 15 real frames before it's used. With Lossless Scaling's generator each extra picture waits for the one before on the GPU; the built-in one only redoes its last pass. Applies at once. |
| `resolution_240`, `resolution_360`, `resolution_432`, `resolution_480`, `resolution_576`, `resolution_648`, `resolution_720` | Base resolution of the 3D scene: 427x240 (the lowest, for the weakest GPUs; FSR helps the upscale), 640x360, 768x432, 854x480 (lower, for weak GPUs), 1024x576, 1152x648 or 1280x720 instead of the game's 960x540 (720p fills the whole 720p picture, with no scaling inside the game). In docked mode, the same ratios of the docked scene. Live. |
| `aspect_4_3`, `aspect_21_9`, `aspect_16_10`, `aspect_stretch` | Aspect ratio, like Eden's: the picture in the largest rectangle of that shape on the screen, centred, black around it. None of them: 16:9, the game's own (black bars at the sides on a long phone). `aspect_stretch` fills the screen. Display → Aspect ratio. Live. |
| `dock_mode` | Docked mode: the game believes it's on the dock (1080p TV picture, about twice the pixels, and the controls as player 1's Pro Controller). For strong GPUs. Read at start-up. |
| `no_dynamic_resolution` | Keeps the scene at the base resolution (no dynamic resolution). Live. |
| `no_fsr` | Plain linear scaling to the screen instead of FSR 1. Live. |
| `no_hud_frametime`, `no_hud_cpu`, `no_hud_gpu`, `no_hud_ram`, `no_hud_shaders` | Performance overlay lines under the FPS counter (Settings → Picture → Performance overlay), all on unless switched off here, each on its own: frame time and 1 % low, the game's CPU use, GPU load (where the phone lets apps read it: kgsl or `/sys/kernel/gpu`), the game's RAM and the phone's, pipelines being built. With any on, the counter is a small box that also shows the real fps under frame generation. Live. |
| `sync_astc` | On Mali (BC textures stored as ASTC), a big texture level that isn't in the ASTC cache yet is encoded by a background thread instead of inside the frame, and drawn from its next smaller mip until it's ready (a moment of blur instead of a freeze, the first time a monster's or effect's textures load). This switch encodes them in the frame, as before. Live. |
| `no_robust` | On Mali, robust buffer access is on by default: a shader reading past the end of a buffer gets 0 instead of a GPU page fault (`GROUP_ERROR_FATAL` in the log), which on Mali drops the whole batch of work and leaves black or magenta screens. This turns it off (Settings → Debug → Driver workarounds). `robusto` turns it on on other GPUs. At start-up. |
| `cutout` | Expand into the cutout (Settings → Display): the game's window also covers the strip beside the camera cutout, as Eden and Azahar can. Next start. |
| `gpu_unswizzle` | GPU texture unswizzle (Settings → Performance, off by default): textures go to the GPU in the console's tiled order, one straight copy, and a compute shader puts them in rows there instead of the CPU, like Eden's option. Less stutter when areas and monsters load. Not for textures decoded or re-encoded on the CPU. Applies at once. |
| `pipeline_threads_1`, `pipeline_threads_3`, `pipeline_threads_4` | Pipeline worker threads (Settings → Performance, 2 by default): how many background threads build pipelines, like Eden's setting. Next start. |
| `async_present` | Asynchronous presentation (Settings → Performance, off by default): the frame is put on screen (swapchain image, frame generation, present) by a thread of its own, so NvnSubmit goes on with the next frame's command lists. At most one frame behind. Applies at once. |
| `system_bars` | Show Android's bars (Settings → Display): keeps the status and navigation bars on screen. By default both are hidden while playing (a swipe in from the edge shows them for a moment), so three-button navigation no longer sits over the game. |
| `touch_gpu` | Draw controls with the GPU (Settings → Display): the touch controls and the capture button drawn by the GPU through Android's RenderThread (`1`), or by the CPU (`0`). Mali's GLES driver crashed on that thread while hunting (the game itself runs on Vulkan and was fine), so without it they're drawn by the CPU on MediaTek and Exynos chips and by the GPU elsewhere. Next start. |
| `tight_barriers` | Skip empty GPU barriers (Settings → Performance, off by default): the full barriers with nothing recorded since the previous one (about half of the ~250 a frame) are skipped; each still drained the GPU on Turnip. Live. |
| `dynamic_state`, `vertex_input_state` | Extended dynamic state and vertex input dynamic state (Settings → Graphics → Extensions, shown only where the driver has `VK_EXT_extended_dynamic_state` / `VK_EXT_vertex_input_dynamic_state`; off by default). The first sets cull mode, front face, depth test/write/compare and the stencil test and ops per draw; the second the vertex attributes' formats and the streams' strides and step rates. Either way, far fewer pipelines to build and switch. At start-up. |
| `no_adpf` | No Android performance hints (Android 13+: the frame's threads report their work each frame so the system raises the clocks in time). Live. |
| `no_affinity` | Doesn't pin the frame's three threads to the fast cores (they're only pinned when the phone has at least three fast cores). Live. |
| `no_hud_heat` | Hides the overlay's HEAT line (Android's thermal headroom: 100 % is hard throttling). |
| `fps_20`, `fps_25`, `fps_40`, `fps_45` | FPS limit other than the game's 30 (`60fps` for 60). The game measures each frame's length, so it keeps its normal speed: a lower limit saves GPU, heat and battery without slow motion. Loading screens still run at 60. Live. |
| `no_shadows` | Shadows off: the shadow maps aren't drawn and every shadow lookup reads as lit. Live. |
| `fast_depth` | The colour pass draws with GEQUAL instead of EQUAL against the depth pre-pass (MH Rise uses reversed Z), which keeps Adreno's LRZ early rejection on. Meshes the pre-pass drew with a pixel shader (cut-outs: grass, leaves) keep EQUAL, or they would show as whole cards. Graphics → Fast depth test. Live. |
| `no_dynamic_shadows` | No shadows from things that move (the Renderer's DynamicShadowEnable, set through the game's own setter): the PC's Dynamic Shadows off. Graphics → Dynamic shadows. Live. |
| `no_foliage_sway` | Grass and leaves stop swaying (SwingEnable and SwingOnShadowEnable off): the PC's Foliage Sway off. Graphics → Foliage sway. Live. |
| `effects_lower`, `effects_lowest` | Experimental. The Renderer's ReducedTransparentBuffer one or two steps above the game's 2 (up to 4): particles and other see-through effects drawn into a smaller buffer. Graphics → Effects resolution. Live. |
| `no_ao` | Experimental. The Renderer's GeometryAOQuality at 0 (the game uses 1). Graphics → Ambient occlusion. Live. |
| `shadow_half`, `shadow_quarter` | Shadow maps at half or a quarter of the game's own size (never below 256), through the game's own shadow setting (the PC version's shadow quality). Blurrier edges, much less GPU work. Live. MH Rise 16.0.1 only. |
| `model_detail_low`, `model_detail_lowest`, `model_detail_min`, `model_detail_high` | Scales the game's mesh LOD rate (the PC version's mesh quality) by 0.75, 0.5, 0.25 or 1.5. Live. MH Rise 16.0.1 only. |
| `texture_bias_1`, `texture_bias_2` | The texture streamer skips one or two more of the largest mip levels (the game's TextureLoadLevelBias). Live. MH Rise 16.0.1 only. |
| `60fps` | Unlocks 60 fps mode (needs a strong GPU: most phones won't hold it in hunts). |
| `no_fps` | Hides the FPS counter (the same switch as in the settings panel). |
| `xbox_buttons`, `retro_buttons` | Force the face buttons to be read by position (`xbox_buttons`) or by name (`retro_buttons`) if a controller comes out swapped. |
| `bc_on_cpu` | Decompresses BC textures on the CPU even where the GPU reads them, the way Mali and PowerVR GPUs need (to try that path on an Adreno). |
| `short_subgroups`, `no_short_subgroups` | Subgroup operations on GPUs with subgroups under 32 (Mali). On by default with PanVK, which needs them for a complete picture (Eden's single-lane fallback loses quad derivatives), and with ARM's driver on GPUs without `VK_KHR_draw_indirect_count` (Dimensity 720), where the ground went missing without them; off with newer ARM drivers, where they stalled the GPU. These force one or the other. Read when shaders are translated. |
| `no_quad_derivatives` | Where subgroup operations are off (ARM's driver), quad swaps still carry the game's hand-made derivatives in pixel shaders. This turns them off too, as before. Read when shaders are translated. |
| `no_bindless_arrays`, `bindless_arrays` | Texture arrays in the shaders off or on (the menu's Graphics > Texture arrays). Auto, with neither: off with Qualcomm's own driver on an Adreno 7xx or 8xx (512.863 on an Adreno 730 rejected most of the scene's pixel shaders that index them, so things came out black), on elsewhere (Turnip, the Adreno 650). Read at start-up. |
| `no_spirv_opt_brx` | Graphics shaders that contain a switch (a BRX) are normally also passed through spirv-opt, as compute shaders always were: the control flow Eden builds for a switch is what Qualcomm's driver miscompiled in the hunter's face skinning, and what a Mali-G615 hung on every frame. This turns that off. Read at start-up. |
| `no_int_attribs`, `int_attribs` | Vertex attributes in integer formats (bone indices, IDs) declared as integers in the vertex shader, so it gets their raw bits the way the Switch does. Needed on Mali (ARM's driver converted them to floats: skinned characters stretched into spikes), so on by default there and on other non-Adreno GPUs. Off by default on Adreno, which passes the bits through anyway; with Turnip it made characters flash. `int_attribs` forces it on, `no_int_attribs` off (Debug → Integer vertex attributes). Read at start-up. |
| `keep_dead_functions` | Helper functions that a translated shader never calls are normally removed before the shader goes to the driver, along with the "variable pointers" capability they bring. On Qualcomm's own driver (512.863) every pipeline with such a pixel shader was rejected, which left characters black. This sends Eden's SPIR-V unchanged. Read at start-up. |
| `env.NAME = value` | Not a switch: lines of `mhr.ini` set in the environment before the GPU driver starts (`env.TU_DEBUG = nolrz,sysmem`). Mesa's drivers read their debug settings from them: Turnip (`TU_DEBUG=nolrz,sysmem,noubwc`, `FD_DEV_FEATURES=…`) and PanVK (`PANVK_DEBUG=…`). Debug → Driver environment writes them, with quick toggles for the Turnip ones; a `driver_env.txt` from earlier builds is moved into the ini when the menu opens. Read at start-up. |
| `no_depth_bias` | The game's depth bias (nvnCommandBufferSetPolygonOffsetClamp) was ignored before: shadow maps drawn without it make the ground shadow itself, which shows as stripes and triangles flickering on the floor, and decals fight the terrain under them. Now it reaches Vulkan as a dynamic depth bias where the game turns it on. This goes back to ignoring it. Read at start-up. |
| `no_split_overlays` | When the game writes a GPU range that only partly overlaps one the GPU wrote before (it carves the same memory differently from frame to frame), the old one is split: the overlapping part goes into the new one and the parts outside stay as they were. Before, the old one was thrown away and its outside parts came back from the game's stale memory, and whatever was drawn from there blew up for a frame (big black triangles flashing on the Adreno 830). This goes back to throwing them away. Live. |
| `no_warp_barriers` | On GPUs with subgroups smaller than the Switch's warp of 32 (Mali: 16), the compute shaders of a single warp get a workgroup barrier after their shared memory writes, since they count on the warp running in lockstep (without it a Mali hung while mining or attacking). This switch leaves them as before. Read when shaders are translated (start-up). |
| `no_async_shaders` | Translates every shader where it's first used, as before, instead of translating graphics shaders missing from the cache on a background thread (meanwhile the draws that need them are skipped for a few frames). Memory and shaders → Async shaders. Live. |
| `no_gpu_occlusion`, `gpu_occlusion` | The game's GPU occlusion culling (UseGpuOcclusionCulling) off or on. By default it's off on Mali: the test's compute shaders use the Switch's 32-lane warps, which Mali's 16-lane subgroups don't match (Eden's translator only handles larger ones), and grass and trees popped in and out with ARM's driver and PanVK alike. Off, nothing is hidden for being behind something else. Graphics → GPU occlusion culling. Live. |
| `count_check`, `no_count_check` | On by default on drivers without `VK_KHR_draw_indirect_count` (ARM's on a Dimensity 720), each GPU-counted multi-draw is still drawn up to its maximum, but the vertex shader reads the count the game's culling wrote and drops the draws past it (`nvn/count_check.h`): it reads it as the draw runs, so nothing is copied or fixed before the pass. Removes the stretched triangles of drawing them all. `no_count_check` turns it off. Graphics → Exact draw counts (Mali). |
| `no_count_fallback` | On drivers without `VK_KHR_draw_indirect_count` (old Vulkan 1.1 ones, such as ARM's on a Dimensity 720), skips the game's GPU-counted multi-draws as before instead of drawing them all. Without the fallback the world is missing there. |
| `adreno_turbo` | Keeps an Adreno at its top GPU clock while the game is in front (libadrenotools' turbo, no root). Hotter, more battery; thermal limits still apply. Performance → GPU boost, shown on Adreno only. Live. |
| `bc_astc` | On GPUs without BC textures (Mali), stores BC1/BC2/BC3/BC7 textures as ASTC 4x4 instead of RGBA8: 2-8 times less memory and bandwidth. BC1 (the most common) is converted block for block with no encoder, as fast as a copy; BC2, BC3 and BC7 are encoded on the CPU the first time (ARM's astcenc), then read from the app's own storage (`/data/data/<app>/files/astc_cache`; Graphics → Clear the ASTC cache empties it). Graphics → Textures as ASTC. Read at start-up. |
| `astc_cache_in_data_folder` | Keeps the ASTC cache in `<data>/astc_cache/` instead of the app's own storage (slower to open through Android's shared storage, but it survives reinstalling and can be copied). Read at start-up. |
| `no_gpu_bc` | On GPUs without BC textures (Mali, PowerVR), decodes BC1-BC5 on the CPU as before instead of with a compute shader. Live. |
| `spirv_opt_compute` | On Mesa drivers (Turnip, PanVK), runs every compute shader through spirv-opt as before, not just those with a switch. That cost seconds of freeze the first time a new attack or effect appeared. Read when shaders are translated. |
| `no_readback_copies` | Without `use_return`, the port still returns to the game's memory the buffers the game fills with a GPU copy out of GPU-written data, which is how it reads results back on the CPU. MH Rise's occlusion test works that way: without it the CPU saw zeros and never drew endemic life or wirebugs (they could still be gathered). This switch turns that off. Graphics → Occlusion results. Live. |
| `capture_button` | A floating button over the game: tap to capture a frame, hold to save the report, drag to move it. Debug → Capture button. Live. |
| `no_deferred_clear`, `no_store_ops`, `no_area` | The render pass shortcuts, one each: a clear folded into the next pass as loadOp CLEAR; storeOp DONT_CARE for what isn't read again; the render area cut to what's drawn. Off, the pass loads, stores and covers everything. For flicker that only shows with tiled rendering (Turnip in GMEM on Adreno 8xx). Debug → Driver workarounds (Adreno). Live. |
| `no_direct_mirrors` | A mirror the game rewrites whole frame after frame (MH Rise's 4 MB rings of per-frame data: two in the village at first, about eight after a quest) normally becomes direct after 8 such frames: three copies in memory the CPU writes and the GPU reads, used in turn, so a change is a memcpy into the one no submit in flight reads, with no staging, GPU copy or barriers. This keeps them as ordinary mirrors. Live (for mirrors made from then on). |
| `no_mirrors_at_start` | The mirrors (GPU copies of game buffers the shaders read) that were used in the last frame are no longer checked and uploaded together at the start of each submit, but by the first draw that reads each one, as before. That closed the render pass open at that moment and put two full barriers around each upload: after a quest, with about ten 4 MB buffers rewritten every frame, the depth pre-pass was split five times. Live. |
| `perf_stats` | The profile lines ("perfil …": where the port's CPU time goes) every 10 seconds, without the rest of `verbose_log`. Debug → Performance stats. Live. |
| `no_return_mali` | On Mali GPUs (ARM's driver and PanVK), the impossible branch Eden leaves after a switch is written as a plain return instead of an "unreachable", as on Qualcomm's driver, so the compiler can't make assumptions from it in the skinning shaders. This puts the "unreachable" back. Read at start-up. |
| `pack_half_fix`, `no_pack_half_fix` | On ARM's older Mali drivers (the ones without draw-indirect-count, like a Mali-G68's), a vertex shader's float-to-half packing (packHalf2x16) is built from integer operations: that driver's compiler failed on it ("LLVM ERROR: Cannot select" in the log) and closed the game mid-hunt. Newer Mali drivers keep the single instruction. `pack_half_fix` forces it on any Mali, `no_pack_half_fix` turns it off. Read at start-up. |
| (no switch) | 24-bit depth on GPUs without it (AMD-based ones such as Samsung's Xclipse have no DEPTH24_STENCIL8): the image is made as 32-bit float depth instead. Without that, every pass with the game's main depth buffer failed to start and its draws were skipped. |
| `no_demote_reorder` | On Samsung Xclipse and AMD GPUs, pixel discards are gathered into one at the end of each shader, as Eden does there: their compilers mishandle an early discard, and alpha-tested scenery (foliage, smoke, cliff edges) came out as big flat brown sheets. This turns that off. `demote_reorder` forces it on any GPU. Read at start-up. |
| `no_safe_translation` | Turns off the automatic retry for pipelines a driver rejects. Normally, when a driver refuses one (Qualcomm's own driver does with many of the scene's pixel shaders on newer Adrenos), its vertex and pixel shaders are translated again more conservatively, step by step (no NonUniform marking, then also optimized by spirv-opt, then also without subgroup operations), and the first that works is kept and remembered for the warm-up. |
| `breadcrumbs` | Debugging: GPU breadcrumbs. If the GPU hangs, or the driver aborts a stuck job, the log names the render pass or dispatch and its shaders. Everything on the GPU runs in order: slow. |
| `low_memory` | Smaller caches, as on a phone with less than 5 GB of RAM. |
| `no_af` | No anisotropic filtering: a little cheaper for a weak GPU, a little blurrier at a distance. |
| `single_thread_pipelines` | Builds every pipeline on the renderer's own thread, with no background threads or warm-up (on by itself on a PowerVR GPU, whose shader compiler crashes building several at once). `parallel_pipelines` turns that off. |
| `verbose_log` | Verbose log (line by line) plus a watchdog that prints the game's stack if it hangs. Slower: for debugging. |

## Multiplayer (Local Play over the internet)

The game's **Local Play** works over the internet through hub servers (`meoli.viewdns.net` by default, port 39510; the
MHGU hub servers aren't used, at their owners' request). Create a hub
in Local Play and it's listed there; search for hubs and the ones listed show up. Nobody needs to forward a port: the
server connects the players and passes their traffic. Only MH Rise hubs are listed for MH Rise (the server keeps each
game's hubs apart), so this isn't crossplay with MHGU.

Settings, under **Multiplayer** in the settings panel (saved as text files in the game folder):

| Setting | File | |
|---|---|---|
| Matchmaking key | `hub_key` | Players with the same key only see each other's hubs; empty, public. Only its SHA-256 is sent. |
| Hub servers | `hub_servers` | One `host[:port]` per line; `#` in front keeps it in the list switched off. Missing: the default. `off`: none. |
| Search hosts | `hub_hosts` | Other phones' `IP[:port]`, asked directly for their hub (same Wi-Fi, or a forwarded port). |
| Port | `hub_port` | The TCP port a created hub listens on for direct joins (default 39510, 0 off). |

The hub servers' protocol is the one documented in MHGU for Android's `server/`; the client here is this port's own
code (`runtime/src/nnsdk/ldn.cpp`), with its own link protocol between the players.

## How it works

```
APK
├── SetupActivity (Java)   finds and checks the user's game files, then starts the native activity
└── NativeActivity
    ├── loader             maps main + subsdk* from the ExeFS, applies relocations, links imports,
    │                      patches the few instructions that cannot run on Android (svc, tpidrro_el0, counters)
    └── libnnsdk.so        reimplementation of the console SDK the game imports: nn::os (threads, sync, memory),
        │                  nn::fs (RomFS, saves), nn::hid (controller), audio (AAudio), codecs, …
        └── nvn/           the NVN graphics API on top of Vulkan; the game's Maxwell shaders are translated to
                           SPIR-V with Eden's shader recompiler, then cached
```

The SDK and NVN layers were written from scratch by observing what the game calls and with which values (there are no
official SDK headers or code in this repository); comments next to each deduced value give the evidence. Code comments
are mostly in Spanish.

The [developer notes](docs/README.md) explain the architecture, how MH Rise renders and which engine objects the port
touches, what each GPU and driver needs, every fix with its cause, and the debugging tools.

## Building

Requirements (macOS or Linux): Android SDK with **NDK 28.2.13676358**, build-tools 35.0.0 and platform android-33; a JDK
(17 or newer); CMake ≥ 3.22; Python 3; git, curl and zip.

```bash
tools/setup.sh       # once: fetches the pinned third-party sources (Eden's shader recompiler, sirit, fmt, Boost…)
tools/build_apk.sh   # builds build/mhriseport.apk
adb install -r build/mhriseport.apk
```

`ANDROID_HOME` selects the SDK (default `~/Library/Android/sdk`). The APK is signed with the Android debug key unless you
pass `KEYSTORE=… KS_PASS=…`. `RELEASE=1` makes the build for players: `-O3` without debug info, unused code and duplicate
functions removed, symbols stripped, and an APK that isn't debuggable. Releases are built that way by the `release`
workflow when a `v*` tag is pushed, signed with the key in the `RELEASE_KEYSTORE_B64` and `RELEASE_KS_PASS` repository
secrets (alias `recomp`). For development, `tools/apk.sh` builds, installs, starts the game on the device connected by
adb and prints its log. The Python scripts in `tools/` are analysis helpers that work on your own extracted files in
`work/` (ignored by git).

## Reporting a graphics bug

No terminal needed. In the game, open the settings menu (the gear) → Debug → Bug report:

1. Stand where the problem shows and tap **Capture this frame**. The game stutters for a moment while it saves every
   picture of that frame (render targets, depth and shadow maps) and a trace of its draws.
2. Wait a few seconds, open the menu again and tap **Save the report**.
3. Send `Download/mhrise-report.zip`, with your phone model and which GPU driver you use.

If the problem is hard to catch with the menu open, turn on **Capture button** in the same place. A small round button
then sits over the game: tap it to capture the frame you're looking at (it turns green when the frame is saved), hold
it to save the report, and drag it wherever it's out of the way.

## Saves

Settings → **Saves** handles the save in the data folder's `save/`, which is in the Switch's format:

- **Export (Switch, Eden)**: a zip of `data001Slot.bin` and `data00-1.bin`, which work as they are on a Switch (JKSV,
  Checkpoint), in Eden or Yuzu, or in another copy of the port.
- **Import a save**: from a zip or a folder. A Switch save goes in as it is. A Steam save (`win64_save`) is converted:
  it's decrypted with the Steam ID of its account (read from its `SS1_*` files, a Goldberg/GSE `configs.user.ini` or a
  `userdata/<id>/` path when it has one, asked for when not), then filled into the layout of the save already here. Its `SS1_*` files (the photos taken in
  the game, as JPEGs, and their list) come across too, and the old save's go. The
  save that was here goes to `save_backups/` first (the last 10 are kept, **Restore a backup** brings one back). The game
  closes right after, since it still has the old save loaded and would write it back.
  Plain save files from another release (the Netflix one) or from a save editor are filled into this save's layout
  the same way, so a save of this version has to be there first: start the game, make a hunter and save once, then
  import (the backups count too). Don't copy the other release's files into `save/` by hand; the game crashes on them.
  When the imported save has its own hunter list (`data00-1.bin`), the old save's other hunter slots go as well.
- **Export for Steam**: the save converted to the PC version's, photos included, in `win64_save/`, to copy into Steam's
  `...\1446780\remote\win64_save` (with the game closed, and Steam Cloud off for it, or it may bring the old one back).
  It's encrypted for the account under **Steam account**.
- **Steam account → Set from a Steam save**: the PC version encrypts saves with a key that comes from the Steam ID, and
  that key can only be found from a save the game encrypted for the account. So the port learns it (and the PC
  version's layout, to fill) from any Steam save it opens: this row, an import or a convert. Nothing is imported here.
  Started in the port and never played on PC? Start the PC game once on that Steam account, make a character and save,
  then pick that save here. Until an account is set, the Steam export comes out unencrypted, for a save editor such as
  [ree-save-editor](https://github.com/kvasszn/ree-save-editor) to encrypt.
- **Convert a save**: the same conversions into a zip, without touching the port's save.

The two versions don't have quite the same fields, and the game lays its data out counting from the start of the file,
which isn't the same on each, so a converted save is rebuilt rather than copied: the other platform's save gives the
layout (this port's own save going to the Switch, the last Steam save imported going to Steam) and the converted one
gives every value both have. Have a save of your own on the target side for the best result.

## Credits

The port itself is [IamWilmar](https://github.com/IamWilmar)'s work; this fork builds on it. If you'd like to thank
him, he has a Ko-fi at [ko-fi.com/iamwilmar](https://ko-fi.com/iamwilmar).

## License

GPL-3.0-or-later (see [LICENSE](LICENSE)), because it builds on Eden's shader recompiler (GPL-3.0-or-later). Third-party
components and their licenses are listed in [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

---

## En español

Port nativo para Android de la versión de consola de **Monster Hunter Rise**. El código ARM64 del juego corre directo en la
CPU y este proyecto reimplementa el SDK de la consola y la API gráfica NVN sobre Vulkan.

- **Necesitas tu propia copia del juego**, versión 16.0.1, con el ExeFS y la RomFS ya extraídos en tu consola, como
  carpetas normales. Salen de tu propia copia: si tu consola tiene firmware modificado, sus herramientas homebrew los
  extraen. La app solo lee esas carpetas y te dice qué falta si algo no está. Este repositorio no tiene código ni
  archivos del juego.
- Descarga la APK de [Releases](https://github.com/klark231/mhrise-recomp/releases/latest) e instálala. Copia esas carpetas al
  dispositivo, abre la app, dale el permiso de archivos, elige la carpeta y pulsa *Iniciar juego*.
  Las partidas y la caché de shaders se guardan en esa misma carpeta.
- Funciona en móviles en general: Adreno (driver de Qualcomm o Turnip), Mali (driver de ARM o PanVK), Xclipse y
  PowerVR. Empezó como el port de IamWilmar para la Retroid Pocket 5 y la Flip 2.
- Los mandos se leen por posición, por USB o Bluetooth, y hay controles táctiles con editor. Deslizando un dedo desde el borde derecho de
  la pantalla sale un panel de ajustes, con el interruptor del contador de FPS y el de volver a elegir la
  carpeta. Con la carpeta ya elegida, la app abre el juego directamente.
- Proyecto de fans, gratis (las donaciones son opcionales y no desbloquean nada), sin relación con el fabricante de la consola ni
  con Capcom.

## Mods

Mods go in the data folder, like LayeredFS on a Switch: `<data folder>/mods/<mod name>/romfs/...`, with the mod's own
folder layout under `romfs` (most MH Rise Switch mods ship as `romfs/re_chunk_000.pak.patch_00N.pak` or loose files
under `romfs/natives/NSW/...`). A mod's file takes the place of the game's with the same path, or is added if the game
has none. With several mods, the first by folder name wins for a file both have. To switch a mod off without
deleting it, start its folder name with `#`. Mods are read when the game starts; the log lists each one (`[fs] mod:`)
and the first files it served (`[fs] mod file:`). Your game folder is never changed.

Settings → **Mods & cheats** does the same from the app: **Add a mod (.zip)** takes a zip made for Eden or Yuzu (it
finds the `romfs`/`cheats` folders inside, or a bare `natives/...` tree), and each mod gets an on/off row and can be
removed. `exefs` patches aren't used.

### Cheats

Atmosphere cheats, the same files Eden and Yuzu read: `<data folder>/mods/<mod name>/cheats/<build id>.txt`. The menu
shows this game's build ID, lists every cheat of the mods that are on, and turns each one on or off (`cheat_<hash>` in
mhr.ini); a change starts working within a second, no restart. **Add a cheat file (.txt)** puts a loose file into a
mod of its own, and refuses one named after another build ID (another game version). The game's own code runs natively
here, so cheats behave as on the console: pointer chains from main and code patches work. A cheat with a fixed heap
offset may miss, because this port's heap hands out memory in its own order. The log says which cheats are on and why
one stopped (`[cheats]`).

