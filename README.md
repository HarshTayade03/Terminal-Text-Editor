# Kilo Editor — Cross-Platform Text Editor (C)

A text editor that runs directly inside the terminal — no GUI, no external libraries — built in C and engineered to run natively on **both Windows and Linux/macOS** from a single shared codebase.

## Why This Project Is Interesting

Most simple programs just print output and wait for you to press Enter. A text editor can't work that way — it has to react to *every single keystroke* the instant it happens (arrow keys, backspace, etc.) and redraw the screen instantly, all while talking directly to the operating system's terminal — no helper libraries involved.

The catch: Linux/macOS and Windows handle terminals completely differently under the hood. This project's core challenge was designing the editor so that almost the entire program doesn't have to care which operating system it's running on, with only a small, isolated layer that does.

## High-Level Design

The editor is organized into a few clear layers:

**1. Terminal Control Layer (the only OS-specific part)**
Switches the terminal into "raw mode," a mode where keystrokes reach the program immediately instead of waiting for Enter. This is implemented separately for Linux/macOS (using standard POSIX terminal controls) and Windows (using the native Windows Console API) — but both expose the same behavior to the rest of the program.

**2. Shared Input/Display Protocol**
Both platforms are configured to speak the same language for keyboard input and screen drawing: ANSI escape codes, a long-standing terminal standard. By getting the Windows console to interpret these the same way a Unix terminal does, everything built on top of this layer works identically on both operating systems, with no duplicated logic.

**3. Text Buffer**
Keeps the file's contents in memory as a list of lines, along with cursor position, scroll position, and unsaved-changes tracking.

**4. Syntax Highlighter**
Scans each line and classifies pieces of it (keywords, strings, numbers, comments) so they can be rendered in different colors.

**5. Screen Renderer**
Converts the current editor state into terminal drawing instructions and redraws the screen efficiently after every change.

**6. File I/O**
Handles opening and saving files consistently, avoiding the silent file-format differences (like line-ending conversion) that often trip up cross-platform tools.

```
┌─────────────────────────────────────────┐
│           Text Buffer + Cursor           │
├───────────────────┬───────────────────────┤
│ Syntax Highlighter │   Screen Renderer     │
├───────────────────┴───────────────────────┤
│       Shared ANSI Input/Display Protocol  │
├──────────────────────┬─────────────────────┤
│  Linux/macOS Terminal │  Windows Console    │
│  Control (POSIX)      │  Control (Win32)    │
└──────────────────────┴─────────────────────┘
```

## Engineering Highlights

- Isolated all OS-specific logic into one small layer, so the vast majority of the editor required **zero changes** to support a second operating system.
- Found and fixed real bugs in the existing code — including a window-size detection routine that was silently broken — and replaced a missing standard library function that Windows doesn't provide.
- Verified the port by building for both platforms (compiling natively and cross-compiling for Windows) and running automated checks, rather than relying on manual testing alone.

## Built With

- C (no external dependencies, single source file)
- POSIX terminal APIs (Linux/macOS)
- Win32 Console API (Windows)

## Running It

```bash
# Linux / macOS
gcc kilo.c -o kilo
./kilo myfile.txt

# Windows (MinGW-w64)
gcc kilo.c -o kilo.exe
kilo.exe myfile.txt
```

## Credits

Based on the original [Kilo](https://github.com/antirez/kilo) editor by Salvatore Sanfilippo and the *Build Your Own Text Editor* tutorial. Licensed under BSD-2-Clause.