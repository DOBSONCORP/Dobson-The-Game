# DOBSON — UWP app for Xbox (dev kit)

A Universal Windows Platform wrapper around **Dobson – The Game, v84**.
The whole game is one local HTML file (`DobsonGame/Assets/game/index.html`,
byte-identical to the current web build), shown fullscreen in a WebView.
It works fully offline: every sprite, background and song is embedded in
that file. No Store submission, no network, no special capabilities.

## What's in this folder

- `DobsonGame.sln` — the Visual Studio solution (x64 only: that's what Xbox is).
- `DobsonGame/` — the app itself:
  - `Package.appxmanifest` — identity `DobsonGame`, version **1.84.0.0**,
    targets `Windows.Universal` + `Windows.Xbox` (min 10.0.17763.0).
  - `App.xaml(.cs)` — launches straight into fullscreen.
  - `MainPage.xaml(.cs)` — a page holding *only* a WebView. That's
    deliberate: with no other focusable controls, the controller's input
    goes to the game's own Gamepad API/keyboard handling instead of XAML
    focus navigation. The WebView is given focus once the game loads.
  - `Assets/game/index.html` — the v84 game. Replace this file to update
    the game (see "Updating" below).
  - `Assets/*.png` — tile/splash logos (blue + gold Twinkie bar; on GitHub Actions they are generated at build time by `Assets/generate-logos.py`, since the upload path carries text files only).
- `Build-UWP.ps1` — one-command Windows build (see Option B).
- `.github/workflows/build-uwp.yml` — GitHub Actions build (see Option A).

## One thing to know first: there is no `.msixbundle` in this zip

A UWP package can only be compiled with the Windows SDK / MSBuild, which
don't run on Linux — so this zip contains the complete project, not a
fake package. Either build path below produces the real, installable
`.msixbundle` (plus its `.cer` certificate). Both are one step once set up.

## Option A — easiest: build with GitHub Actions (no Windows PC needed)

1. Create a GitHub repo (private is fine) and upload the contents of this
   zip to its **root**, so `DobsonGame.sln` and `.github/` are top-level.
2. Go to the repo's **Actions** tab → **Build UWP for Xbox** → **Run
   workflow** (it also runs automatically when you push a change under
   `DobsonGame/`).
3. When it finishes, download the **DobsonGame-Xbox** artifact and unzip
   it. You'll get two files from the *same* build — keep them together:
   - `DobsonGame_1.84.0.0_x64.msixbundle` (the game)
   - `DobsonGame.cer` (its test certificate)

## Option B — build on a Windows PC with Visual Studio

1. Install **Visual Studio 2022** with the **Universal Windows Platform
   development** workload.
2. Open `DobsonGame.sln`, or from PowerShell in this folder run:
   `.\Build-UWP.ps1`
   (First run creates a self-signed test certificate and exports
   `AppPackages\DobsonGame.cer` for you.)
3. The package lands under `AppPackages\` as a `.msixbundle`, next to
   its `.cer`.

## Install on your Xbox dev kit

1. On the dev kit, open **Dev Home** and note its IP address. Device
   Portal should already be enabled on a dev kit.
2. On a PC/phone browser on the same network, open
   `https://<dev-kit-IP>:11443` (accept the browser warning about the
   Portal's own certificate — that's expected on a local device).
3. Go to **Apps** → install/add an app, and upload the `.msixbundle`.
   If the Portal asks for a certificate, upload the `DobsonGame.cer`
   from the same build first, then the package.
4. Launch **DOBSON** from the dev kit's home/games list.

Alternative from a Windows PC with the Windows SDK installed:
`WinAppDeployCmd install -file <path to .msixbundle> -ip <dev-kit-IP>`
(add `-pin <pin>` if Dev Home shows a pairing PIN).

## Controls on Xbox

- **Xbox controller** (the game's own gamepad support): left stick /
  D-pad to move, **A** jump, **B** throw a Twinkie, **X** green throw,
  **Start/Menu** to pause and advance menus/dialogue.
- **USB keyboard** also works: arrows/WASD, Space to jump, X to throw.
- There are no touch buttons on Xbox (the game hides them when a
  controller is connected). If the controller ever seems unresponsive,
  press **A** once on the title screen — the game takes input focus
  from there.

## Updating to a new version of the game

1. Copy the new `index.html` over `DobsonGame/Assets/game/index.html`.
2. Bump `Version` in `DobsonGame/Package.appxmanifest`
   (e.g. `1.84.0.0` → `1.85.0.0`) — Xbox only installs a *higher*
   version over the old one.
3. Rebuild (Option A or B) and install over the existing app.
   Updating this way keeps the app's saved data, so high scores,
   unlocked levels and audio settings carry over.

**Xbox WebView note (2026-10-28):** the Xbox app runs the older EdgeHTML
browser, which cannot parse `?.` optional chaining — that was why the
first install showed only a dark screen. The copy of the game in
`DobsonGame/Assets/game/index.html` has those 4 expressions replaced
with plain if-guards (same behaviour, no version change). If a future
game version reintroduces `?.`, re-apply the same replacement to the
Xbox copy before building, or the Xbox build will break again.

**Xbox controller note (2026-10-28):** the Xbox copy also remaps the
controller: RT throws a Twinkie, RB throws a green Twinkie (the main
game uses B/X), D-pad up/down on the title menu no longer also
activates the selection, and the app shell swallows the system Back
request so B never kicks the player to the Xbox menu mid-game. If a
future game version replaces `DobsonGame/Assets/game/index.html`,
re-apply both the EdgeHTML and the controller patches to the new copy.

## Notes and limits (honest ones)

- This is a UWP **WebView wrapper**, not a native Xbox GDK game. That's
  the right fit for this 2D canvas game, but it means no Xbox Live
  achievements, no Store listing, and performance is web-level.
- The in-game **Quit** menu won't close the app on Xbox the way
  `window.close()` does in a browser — use the Xbox (Guide) button to
  leave the game.
- High scores on the console live in the app's own WebView storage.
  They are **not** shared with the phone/web versions.
- **Certificates are per-build in Option A**: every Actions run makes a
  fresh test cert, so always install the `.cer` that came with that
  run's `.msixbundle`. If you want one stable cert across builds, build
  locally once (Option B) and reuse the same certificate.

## Troubleshooting

- **Install fails with a certificate/trust error** → the `.cer` from
  the same build wasn't installed first. Upload it in Device Portal,
  then install the package again.
- **Install fails on architecture** → the package must be x64. Both
  build paths here are x64-only by design; don't switch to ARM/x86.
- **Device Portal won't open** → check the dev kit is on the same
  network, Dev Mode / Device Portal is enabled in Dev Home, and you're
  using `https` with port `11443`.
- **Black screen on launch** → the splash screen shows first by design;
  give it a few seconds (the 2.3 MB game file loads locally, then the
  title screen appears).
