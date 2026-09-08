# Anti Overlay

A lightweight, zero-dependency Windows batch script designed solely to block Steam overlay DLL injection during game launch via Steam Launch Options.

---

## Setup

1. Copy anti_overlay.bat into your game's directory (where the game executable is located).
2. In Steam, right-click the game -> **Properties...**.
3. Under **Launch Options**, enter:
   ```text
   anti_overlay.bat %command%
   ```
4. Launch the game from Steam.

---

## How It Works

1. **One-Time Auto Setup**: On the first launch, if your user account doesn't yet have permission to manage the Steam overlay DLLs in `C:\Program Files (x86)\Steam`, it prompts UAC once to grant the `Users` group permission. All future launches run with **zero UAC prompts**.
2. **Denies Execute Permission**: Blocks `GameOverlayRenderer.dll` and `GameOverlayRenderer64.dll` via `icacls ... /deny "Users:(X)"`.
3. **Launches Game**: Spawns the game with `start "" %*` as a standard user.
4. **20-Second Wait**: Keeps the overlay DLLs blocked for 20 seconds to ensure the game has fully initialized past the overlay injection hook.
5. **Auto-Restore & Close**: Restores permissions (`icacls ... /remove:d "Users"`) and automatically closes the terminal window.
