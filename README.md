# flutter-no-debugprint-release

A lightweight wrapper that adds `--ndrelease` (no-debug-release) support to `flutter build`.

## What It Does

`flutter build <target> --ndrelease` compiles your Flutter app in release mode with all `debugPrint(...)` and `print(...)` calls automatically stripped from the source.

Your **original source code is never modified**. The wrapper creates a temporary shadow copy of your project, strips the debug prints in the copy, builds from there, and copies the output back.

## Installation

### Linux / macOS

```bash
git clone <repo-url>
cd flutter-no-debugprint-release
./install.sh
```

The installer will ask if you want to remove the cloned directory. Say **y** if you don't need it anymore — the wrapper is copied to `~/.flutter-ndrelease/`.

Then restart your terminal or run:
```bash
source ~/.bashrc  # or ~/.zshrc
```

### Windows

```batch
git clone <repo-url>
cd flutter-no-debugprint-release
install.bat
```

The installer will ask if you want to remove the cloned directory. Say **y** if you don't need it anymore — the wrapper is copied to `%USERPROFILE%\.flutter-ndrelease\`.

Then restart your terminal.

### Manual Installation

Add the `bin/` directory to your PATH **before** your Flutter SDK's `bin` directory:

```bash
export PATH="/path/to/flutter-no-debugprint-release/bin:$PATH"
```

## Usage

```bash
# Build for Linux without debug prints
flutter build linux --ndrelease

# Build for Windows without debug prints
flutter build windows --ndrelease

# Build for macOS without debug prints
flutter build macos --ndrelease

# Also accepts the long form
flutter build linux --no-debug-release
```

Build output goes to `build/ndrelease/` instead of `build/<platform>/`.

### Normal Release Build

All other `flutter` commands pass through unchanged:

```bash
flutter build linux --release      # Normal release (debug prints intact)
flutter run                          # Debug mode
flutter pub get                     # Works as usual
```

### Uninstall

```bash
flutter wrapper-uninstall -y
```

This removes the wrapper directory. You may also want to clean up the PATH entry in your shell config (`.bashrc` / `.zshrc`) or Windows environment variables.

## How It Works

1. Detects `--ndrelease` / `--no-debug-release` in build arguments
2. Creates a shadow copy of your project at `build/ndrelease_shadow/`
3. Strips `debugPrint(...)` and `print(...)` lines from all `.dart` files in the shadow
4. Runs the real `flutter build --release` inside the shadow
5. Copies build outputs from the shadow to `build/ndrelease/`
6. Deletes the shadow directory

If the build crashes or the terminal dies, the shadow directory may remain in `build/ndrelease_shadow/`. It is harmless and can be removed with `flutter clean`.

## Requirements

- Flutter SDK installed and in PATH
- Bash (Linux/macOS) or PowerShell (Windows)

## License

Apache License 2.0
