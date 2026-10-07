# Building

This repository holds two unrelated projects in separate folders:

| Folder | What it is |
| --- | --- |
| `sm64coopdx/` | Super Mario 64 multiplayer PC port |
| `Minecraft-Xbox-360-Decompilation/` | Functional decompilation of Minecraft Legacy Console Edition (Xbox 360, TU2) |

They don't depend on each other. `build.bat` just builds either or both from one place.

## Quick start (Windows)

```bat
build.bat           :: interactive menu (or double-click it)
build.bat sm64      :: build sm64coopdx
build.bat xbox360   :: build the Xbox 360 decompilation
build.bat all       :: build both
```

The second argument picks the CMake configuration for the Xbox 360 build (`Release` by default, or `Debug`).
The script checks for each prerequisite first and tells you what is missing instead of failing halfway.

## sm64coopdx

**Needs:** [MSYS2](https://www.msys2.org) installed (default `C:\msys64`, or set the `MSYS2_ROOT` environment variable).

The script installs the remaining packages through MSYS2's `pacman` (the same set the project's own CI uses: `make`, `git`, `unzip`, `zip`, `python3`, and the MinGW64 `gcc`, `glew` and `SDL2`), then runs `make -j$(nproc)` inside `sm64coopdx/`.

**Output:** `sm64coopdx\build\us_pc\sm64coopdx.exe`

If `pacman` reports a package as not found, open an "MSYS2 MSYS" terminal once, run `pacman -Syu`, and rerun the script.

## Minecraft Xbox 360 decompilation

**Needs:**

- [CMake](https://cmake.org) 3.29 or newer and [Ninja](https://ninja-build.org) on your `PATH`
- Microsoft's **Xbox 360 XDK v2.0.21119**. It is proprietary, so it is **not** in this repository. Copy the XDK's `include`, `lib` and `bin` folders into `Minecraft-Xbox-360-Decompilation\Compiler\` as described in that project's README. The script looks for `Compiler\bin\win32\cl.exe`.

**Output:** an Xbox 360 executable (`Rewritten.xex`) under `Minecraft-Xbox-360-Decompilation\out\build\<Config>\`.

Keep in mind:

- This is an Xbox 360 binary. It does not run on a Windows PC.
- The decompilation is still early: the CMake project currently contains only a handful of source files, and the author notes the project is a side project that may not be actively developed.
- The upstream README says the build steps are still a TODO. This script follows the project's own `CMakeSettings.json` (Ninja generator plus the `XMsvc.cmake` toolchain), but it has not been run against a real XDK setup.
