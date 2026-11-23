# WMO1.1_Jster_Mod — handoff

A single-file HTML replacement for the Chinese config software that came with a white
IntelliMouse-Optical-shaped wireless mouse (PAW3395 sensor). The original installer,
`IO1.120Pro.exe` (SHA256 `afbd0115dbfa1cb849f9cdb46c8f12e33d1d47603cec1f505b6bc78164be599e`),
was flagged as malware on VirusTotal, so **it has never been run**. Its USB protocol was
worked out by static disassembly only.

> **What has been tested on the real mouse (2026-11-22, 2.4 GHz dongle, sent with a Python/ctypes script, not the browser):**
> the status query works (tag `M150`, sensor `0x95` PAW3395, battery 82%), and a polling-rate
> packet (`0x07`, 1000 Hz) was accepted and acknowledged. **Not yet tested on hardware:** every other
> settings packet, the WebHID path in Edge/Chrome (the Connect button), and live sync. The interface
> itself was checked in a browser against a simulated mouse.

---

## Files (this folder)

| File | What it is |
|---|---|
| `WMO1.1_Jster_Mod.html` | **The app** (version 3, Windows 95 look). One self-contained file, about 340 KB (most of it the embedded mouse picture, plus the icon and the pixel font). Works fully offline. |
| `Open WMO.cmd` | **Double-click this to start.** Opens the app in its own Edge (or Chrome) window with no tabs or address bar. |
| `WMO 1.1 Jster Mod.lnk` | Shortcut to `Open WMO.cmd` that carries the app icon and hides the command window. It stores absolute paths, so recreate it if the folder moves. |
| `wmo.ico` | The app icon (16, 32, 48, 64 and 256 px), built from `art/icon-original.png`. Used by the shortcut. The same picture at 64 px is embedded in the HTML as the favicon, which is what the app window and taskbar show. |
| `art/` | The owner's artwork as supplied: `mouse-original.png` (pixel-art mouse, 477×830) and `icon-original.png` (the mouse on a Windows 95 button, 512×512). The picture and icon inside the app, and `wmo.ico`, were made from these. |
| `re-notes/` | Reverse-engineering kit: `scripts/` (analysis scripts and two hardware test scripts), `disasm/` (saved disassembly listings), `vendor-config/` (the original app's text config: default profiles + English strings). See "Reverse-engineering notes". |
| `.claude/launch.json` | Preview-server config for Claude's browser pane (`py -I -m http.server 8765`). Only needed for development with Claude; safe to delete by hand. |

**Removed in the clean-up of 2026-11-22** (permanently deleted at the owner's request; no copies were kept): the three earlier versions of the app (`mouse-config.html`, `archive/…v1_neon.html`, `archive/…v2_retro.html`), `wmo-neon.png`, the scaled copies of the artwork (`art/mouse-300.png`, `art/icon-16…256.png`), and the image scripts that only served the neon picture (`cutout.ps1`, `neon.ps1`, `swapimg.py`).

## Why it's still HTML

Python, a real `.exe` and a shell script were considered. HTML stayed because:

- The mouse's settings interface is a vendor-defined HID collection (usage page `0xFF00`, feature report 12), which Chrome and Edge are allowed to open through WebHID. Checked against the real dongle.
- Nothing to install, build, sign or keep updated, and no SmartScreen or antivirus prompts.
- The cm/360 finder needs raw, unaccelerated mouse counts. The browser gives that with one call (Pointer Lock `unadjustedMovement`); in Python or .NET it means Raw Input plumbing.
- `Open WMO.cmd` gives it its own window, so it behaves like a desktop program.

The protocol code doesn't depend on the UI. If a tray icon, per-game profile switching or apply-on-startup is ever wanted, that would be the reason to add a small native helper (the Python/ctypes route works with no extra packages: `HidD_SetFeature` / `HidD_GetFeature` on the `col04` interface).

## How to use it

1. Close the original mouse app if it's running.
2. Double-click `Open WMO.cmd` (or open `WMO1.1_Jster_Mod.html` in Edge or Chrome; Firefox and Safari have no WebHID).
3. Click **Connect mouse** and pick the mouse (dongle `248A:5B2F` or cable `248A:5B2E`). The browser asks again each session, because the mouse has no serial number for it to remember.
4. Change settings on any tab. The bar at the bottom lists what isn't on the mouse yet; **Apply to mouse** sends only those parts. **Undo changes** puts the page back to what the mouse last confirmed.
5. Advanced → Packet log shows every packet. It also has a raw-packet sender.

WebHID won't work inside a sandboxed iframe or a claude.ai artifact; the file has to be opened locally.

---

## Design (v3: Windows 95)

- **Look:** a Windows 95 "Mouse Properties" window on a teal desktop, styled after [95CSS](https://github.com/YoshiMannaert/95CSS) (MIT, © 2025 Yoshi Mannaert).
  - Taken from 95CSS: the colour tokens, the bevel box-shadows (`--in1…4`, `--out1…5`), and the pixel artwork for check boxes, radio buttons and the slider thumb. Its stylesheet is **not** linked: it styles bare `header`, `button`, `input` and would fight this app's markup, so the rules are rewritten in the app's own `<style>` (credit and licence note at the top of it).
  - The W95FA pixel font is embedded in the `@font-face` rule as a base64 data URI, so the app loads nothing from the internet. It is `w95fa.woff2` (7,880 bytes, SHA256 `D81CBD6C…E71644`) from `cdn.jsdelivr.net/npm/95css@0.4.2/fonts/`. The font is by FontsArena; the 95CSS package ships no separate licence file for it, so check its terms before redistributing the app. If it ever fails to load, the fallbacks are MS Sans Serif / Microsoft Sans Serif / Tahoma.
  - Win95 equivalents used: on/off switches became check boxes, segmented controls became latching button groups (pressed = sunken with the dithered fill), the effect picker is a dropdown, groups are etched `fieldset`s, the Apply bar is a status field plus dialog buttons, unsent tabs get a `*`, notes are tooltip-yellow boxes, and the finder is its own window.
  - The mouse picture is the owner's pixel-art photo (made from `art/mouse-original.png`, embedded as `window.WMO_PHOTO`) in a grey sunken panel. It is a plain picture: the lighting preview that used to recolour it was removed at the owner's request, and so was the DPI colour flash. The only things drawn over it are the numbered markers on the Buttons tab.
  - There is no red accent any more; selection navy (`#0f0086`) is the only highlight.
- **Earlier looks, no longer in the folder:** v1 was dark with red neon; v2 was a putty desk, white property sheet, dark stitched mousepad, tail-light red, Franklin Gothic + Tahoma.
- **The left column** is always visible: the mouse picture, readouts for DPI stage, polling rate and battery, then connection state and sensor. On the Buttons tab the picture shows numbered markers that match the list.
- **The readouts show the real mouse, not the profile being edited** (`renderMat`). The mouse can't be asked what it's showing, so "real" means what it last confirmed from this app, plus the DPI stage and polling rate it reports itself:
  - Readouts keep the mouse's values while an edit is unsent and get an "edited" mark; before anything has been confirmed they show the profile's values marked "unsent".
  - Lighting has no on-screen preview any more, so there is nothing to show for it here; unsent lighting changes appear in the Apply bar like everything else.
- **Instant lighting and DPI** (`liveKick` / `liveFlush`, switch under Advanced, on by default): while connected, an edit to lighting or DPI stages is sent 350 ms after the last change, so you see the result on the real mouse straight away. Rules:
  - Only an edit to one of those two groups triggers it. Connecting, switching profile and Undo never send anything by themselves.
  - A DPI number being typed is sent when it's finished (blur or Enter), not per keystroke.
  - Buttons, polling, lift-off, debounce and power still wait for Apply.
- **One Apply bar** replaces the six separate Apply buttons. Tabs with unsent changes get a `*`.
- **Tabs:** Pointer · Test · Sensitivity · Buttons · Lighting · Power · Advanced. The app opens on Pointer; the first three are the owner's order, the rest is arbitrary. The log, raw packets, "send everything again" and factory reset live under Advanced.
- **Size:** the whole interface is drawn at 80% (`html{--zoom:.8;zoom:var(--zoom)}`), because the owner found 100% too big and liked the browser at 80%. Change `--zoom` to resize everything. `Open WMO.cmd` opens a 1100×900 window to suit. Anything that mixes pointer positions with layout sizes has to allow for the scale; the Test tab's canvas does (`f` in `drawStrokes`).
- **No pop-ups:** profile rename and the factory-reset confirmation are inline.

## Features and where they live

| Feature | Tab | Notes |
|---|---|---|
| Button assignments (6 slots) | Buttons | One dropdown per button; mouse buttons + DPI cycle only (see open items). Refuses to apply with no Left click assigned. |
| DPI stages (1–6, 50–26000 step 50, colour per stage) | Pointer | Logarithmic slider plus an exact number box. The radio button picks the stage in use. |
| Polling rate, lift-off 1/2 mm, debounce 2–20 ms | Pointer | |
| **Angle snapping** | Pointer | **Experimental**: sent as byte 2 of the lift-off packet (see protocol). |
| Lighting effects 0–9, speed, brightness, direction, colours | Lighting | The effect is a dropdown (`#fxSel`). There is no on-screen preview. Names are partly guessed. |
| Sleep timer, lights off while moving, motion wake-up | Power | Labels confirmed from the app's English text. |
| Sensitivity calculator (eDPI, cm/360, in/360, target cm/360, per-stage table) | Sensitivity | Never sends anything to the mouse. The game list is the owner's: Counter Strike, the other Source games, Quake Live, Halo CE and Fortnite. Each has a fixed yaw in `GAMES` (`yawOf`), and there is no yaw field. Source and Quake Live use 0.022. Halo uses 2/90, the Master Chief Collection value; the original 2003 PC Halo CE has a 1–10 slider with built-in acceleration and no fixed yaw, so the entry is labelled as MCC. Fortnite uses 0.005555 per percent of its X sensitivity (two converter sites say 0.5515 per 100% instead of 0.5555; 0.5555 was kept because it agrees with the published "CS sensitivity × 3.96" conversion). None of these were measured in-game. |
| **cm/360 finder** | Sensitivity → "Measure my mousepad..." | An overlay window, not full screen. Pointer Lock with `unadjustedMovement` (raw counts). Optional ruler DPI check, then 3 swipes. Results: cm/360 range (fast = swipe, sweet = 1.5×, slow = 2×) and eDPI/sens. The sweet spot is saved automatically as the calculator's "Hit a target" value. Backing out: a left click without moving (under about 2 mm) while measuring returns to the first screen; a left click on the teal area around the window, or Esc, closes it. |
| **cm/180 option** | Sensitivity → "Measure turns as" | Shows every distance per half turn instead of per full turn (calculator, per-stage table, Hit a target, mousepad summary, finder results). Everything is still computed per 360; `tf()` scales it for display. `C.turn` (360 or 180) is saved, and the Hit-a-target value is converted when the unit is switched. |
| **Test tab** | Test | Three checks, none of which sends anything to the mouse. **Polling rate:** counts reports (`pointerrawupdate`, or `pointermove` coalesced events) over a 500 ms window of continuous movement and shows now / average / highest against the setting. **Click debounce:** counts presses and flags two presses of the same button under 50 ms apart as bounce. **Angle snapping:** draw tilted lines on a canvas; each gets length, tilt, wobble (RMS from a straight line), longest level stretch and number of sideways steps, in screen pixels, to compare snapping off against on. Checked with synthetic events only. |
| Send whole profile, **restore factory defaults**, device info, packet log, raw packets | Advanced | Reset is cmd `0x0F`. It no longer overwrites the page's profile: the factory values can't be read back, so the app just forgets what was on the mouse. |
| Live sync | (automatic) | Listens for input report 5 when the mouse changes its DPI stage or polling rate on its own. Each report carries both values; only the one that differs from the mouse's known state counts as a change, so pressing the DPI button doesn't wipe an unsent polling edit (v1 did). |
| Battery, sensor, connection | Left column | From the `0x20` status query, refreshed every 2 minutes. |

### How "what's on the mouse" is tracked

The mouse can't be asked for its current settings, so the app remembers what it last got **confirmed**:

- Settings are split into 8 packet groups (`GROUPS`): buttons, DPI stages, polling, lift-off/angle snap, debounce, lighting, sleep, wake-up.
- Each group builds its packets from the profile. The packet bytes are the group's signature.
- After the mouse acknowledges a group, its signature and values are saved (`M`, localStorage key `wmo11.jster.onmouse`).
- A group is "not on the mouse yet" when the current profile's signature differs from the saved one. That's what the Apply bar and tab dots show, so switching profiles naturally lists the differences.
- A packet the mouse doesn't acknowledge leaves its group pending and shows "The mouse didn't confirm: …".

### Code map (`WMO1.1_Jster_Mod.html`)

Search for the comment banners.

- `<style>`: 95CSS-derived tokens on `:root`, then controls, the window (`.win`, `.titlebar`, `.top`), the left column (`.mat`, `.screen`, `.reads`), the tabbed sheet, and the finder window.
- `<aside class="mat">`: the left column with the inline `<svg id="mouse">` (picture `#mousePic`, markers in `#hot`). The app icon is a `<link rel="icon">` data URI in `<head>`, reused for the title-bar icon. The picture's data URI sits in its own one-line `<script>window.WMO_PHOTO = …</script>` just before the main script.
- `<section class="pane" id="pane-…">`: one per tab. `<footer class="apply">` is the Apply bar. `<div class="finder" id="pad">` is the cm/360 finder.
- Script (one IIFE), in order:
  - `// ===== protocol =====`: `packet(cmd, payload, block)`, `send` (sends, then waits for the acknowledgement), `readReply`, `sendRaw`.
  - `// ===== state + profiles =====`: `DEFAULT()`, profiles and `M` in localStorage, inline rename.
  - `// ===== tabs =====`, then `// ===== BUTTONS =====` (`ACTIONS`, `BTN`, `SPOTS` = marker positions), `// ===== POINTER =====`, `// ===== LIGHTING =====` (`MODES`), `// ===== POWER =====`.
  - `// ===== what gets sent =====`: `GROUPS`, `pending()`, `renderApply()`, `run`, `sendGroups`, factory reset.
  - `// ===== SENSITIVITY =====` (`GAMES`, `C`, `syncCalc`), then `// ---- cm/360 finder ----` (`P`, `padStart`, `padDraw`, `padFinish`).
  - `// ===== connect + status =====`: `pickInterface`, `openDev`, `onLive` / `listenLive`, `readStatus`.
  - `// ===== boot =====`

### Browser storage (localStorage, per origin)

- `wmo11.jster.v1`: `{cur, list:[5 × {name, s}]}`, where `s` is the settings object (`DEFAULT()` shape, including `snap`). Same key and shape as v1.
- `wmo11.jster.onmouse`: `{sig, val}` per packet group: what the mouse last confirmed.
- `wmo11.jster.live`: `{on}`, the instant-sending switch.
- `wmo11.jster.calc`: calculator state `{game, yaw, src, dpi, sens, target, pad}`. `pad` holds the last finder result.

`file://` and `http://127.0.0.1` are different origins, so settings made in one don't show in the other. Moving or renaming the HTML file can also start it with empty storage.

---

## Protocol reference (decoded from `IO1.1 3395 Pro.exe`)

- **Device:** VID `0x248A`; PID `0x5B2F` (2.4 GHz dongle) or `0x5B2E` (wired). Use the HID interface that has **feature report ID 12 (0x0C)**.
- **HID layout of the dongle (read from the real device):**

  | Interface | Usage page / usage | Reports |
  |---|---|---|
  | `MI_00` | `0001/0002` mouse | input (the pointer itself) |
  | `MI_01 COL01` | `0001/0006` keyboard | input 1, output 1 |
  | `MI_01 COL02` | `0001/0080` system control | input 2 |
  | `MI_01 COL03` | `000C/0001` consumer control | input 3 |
  | **`MI_01 COL04`** | **`FF00/0001` vendor** | **feature 12, 33 bytes: the settings channel** |
  | `MI_01 COL05` | `0001/0000` | feature 7, 8 bytes (unknown) |
  | `MI_01 COL06` | `0001/0000` | input 5, 33 bytes (live DPI/polling reports) |
  | `MI_02` | `FFEF/0000` vendor | input/output/feature 5, 64 bytes (unknown, probably firmware update or pairing; never touched) |

- **Writes:** `HidD_SetFeature` with 33 bytes, which is `sendFeatureReport(0x0C, 32 bytes)` in WebHID. Leave about **60 ms** between packets.

```
[0]=0x0C report id  [1]=0x01  [2]=cmd  [3]=0x00  [4]=seq++  [5]=0x01  [6]=len  [7..]=payload
```

- **Acknowledgement (seen on the real mouse):** reading feature report 12 after a settings packet returns `[2]=cmd [4]=seq [5]=0x01 [6]=0x00`, e.g. `0c 01 07 00 00 01 00 …` after a polling-rate packet. The app treats `r[2]==cmd && r[4]==seq && r[5]==1` as confirmed. What a rejection looks like is unknown.

| Cmd | Payload | Status |
|---|---|---|
| `0x04` | `[slot 0–5, a, b, c]` button action. Codes: Left `10 01 00`, Right `10 02 00`, Middle `10 04 00`, Back/M4 `10 08 00`, Forward/M5 `10 10 00`, DPI cycle `40 01 00`. Macro type byte is `0x90`. | confirmed from code + default profiles |
| `0x05` | 18 bytes: `(active<<4)\|count`, enable mask, then 6 × `(code lo, code hi)` where code = DPI/50 − 1. The last 4 bytes are always 0. | confirmed from code |
| `0x06` | 8 × RGB DPI-stage LED colours | confirmed from code |
| `0x07` | polling interval in ms: 8/4/2/1 = 125/250/500/1000 Hz | confirmed from code, **accepted by the real mouse** |
| `0x08` | lighting block: `[0x01, len, mode, speed<<4\|bright, …]`. Mode data: 1 = direction byte, 2 = count + up to 7 RGB, 3 = one RGB, 6 = 7 fixed RGB, 7 = 2 fixed RGB, others none. | bytes confirmed from code, **mode names partly guessed** |
| `0x09` | `[lod 1\|2, angleSnap]`. The original app declares len 2 but always sends byte 2 as 0. | LOD confirmed from code; **angle-snap byte is a guess** |
| `0x0A` | `[debounce ms]` | confirmed from code |
| `0x0B` | `[sleep minutes, lightsOffWhileMoving]` | confirmed from code (labels from `Lan_En.txt` 268) |
| `0x0C` | `[motionWakeup]` | confirmed from code (label from `Lan_En.txt` 274) |
| `0x0E` | macro upload in 25-byte chunks | **not implemented** |
| `0x0F` | `[0xFF]`: restore defaults. The original sends it after its "restore default setting?" prompt. | confirmed from code |
| `0x20` | status query: send, wait about 15 ms, then read feature report 12. If `r[6]==0`, retry. | **works on the real mouse** |
| `0x71` | bulk write of all keys (`[1]=0x71`, then 3-byte codes) | not used |
| report 9 | macro list/header (`09 81 55 …`, `09 90 …`) | not implemented |

**Status reply** (the 33-byte buffer, including the report ID). Real example:
`0c 01 20 00 00 01 10 00 4d 31 35 30 25 01 00 95 12 ff 52 00 ff 01 00 00 5c 00 20 38 ff c7 67 09 6d`

- `r[2]=0x20`, `r[5]=1`, `r[6]=0x10` (reply length)
- `r[8..11]` is a 4-character tag: `"M150"` on this mouse (the disassembly mentioned `"M110"`)
- `r[15]` is the sensor (`0x95` = PAW3395)
- `r[18]` is battery % (`0x52` = 82)
- `r[19]` is the charge state: 0 = on battery, 1 = charging, 2 = full
- `r[21]` is the online flag
- The other bytes are not decoded.

**Input report 5** comes from the mouse when you use its own buttons. Its bytes are `05 06 ?? <poll interval> <DPI stage 1-6>`. WebHID drops the report ID, so in the event data these are `data[0]=6`, `data[2]` = poll and `data[3]` = stage. On the real device it lives on `MI_01 COL06`. Whether the page actually receives it is untested.

---

## Open items / next steps

1. **Finish the hardware test from the app itself.** Connect in Edge, then change one thing per tab and Apply, watching Advanced → Packet log:
   - Does **Connect mouse** find the settings interface, and does each group come back confirmed?
   - **Lighting:** do the effects match their names?
   - **Angle snapping:** does byte 2 of cmd `0x09` do anything? If the mouse misbehaves, switch it off and apply. That sends `[lod, 0]`, which is exactly what the original sends.
   - **Live sync:** does pressing the mouse's DPI button update the page?
   - **cm/360 finder:** do the cm readings match a ruler? The ruler check is built in for this.
2. **The dongle vanished from Windows during the 2026-11-22 session**, roughly 25 minutes after the last packet was sent to it (a status query that answered normally). Cause unknown; most likely it was unplugged. If it ever drops by itself right after applying a polling-rate change, note it here.
3. **Factory values are unknown.** `DEFAULT()` in the app is a sensible starting profile, not the mouse's real factory state. The vendor's `default1.psf` has different values (`XYSetting1..6Value=08 0E 16 1E 30 32`, lift-off 2, 500 Hz), and how those DPI bytes map to real DPI isn't worked out.
4. **Extra button actions.** The original's menu has DPI+/DPI−, DPI lock, polling-rate switch, lighting switch, disable, multimedia, office keys, rapid fire, triple click, key combos and tilt (see `Lan_En.txt` 026–080). Their 3-byte codes weren't found: they aren't in a static table, and no constant search hit them. What is known:
   - Key slots live at `0x9ba118 + profile*0x370 + slot*0x10`, with the type byte at `+4`.
   - The macro type is `0x90`.
   - The next step would be to find the key-assignment popup's WM_COMMAND handler (menus built with AppendMenu or InsertMenu).
   - Don't guess codes: a wrong one can leave a button doing something odd until it's reassigned.
5. **Lighting names.** `Lan_En.txt` lists 100 Colorful Streaming, 101 Breathing, 102 Steady, 103 Neon, 104 Tail, 105 Colorful Steady, 106 Flicker, 107 Tailing, 108 Wave, 109 None, 110 Snake and 111 Stars Twinkle. How those map to mode numbers 0–9 isn't confirmed. The page's `MODES` names are best guesses, and mode 9 is unnamed.
6. **Macros** (cmd `0x0E` + report 9) are not implemented.
7. **Separate X/Y DPI** is not supported: there's a leftover `XYSynchronous` key, but the DPI packet never carries separate values.

---

## How things were verified (to repeat a check)

- **Preview server:** run `py -I -m http.server 8765 --bind 127.0.0.1` from this folder and open `http://127.0.0.1:8765/WMO1.1_Jster_Mod.html`. The desktop app's browser pane can't run scripts on `file://` pages, and its device chooser never returns a device, so the real mouse can't be reached from it.
- **Mock mouse:**
  1. Fetch the HTML.
  2. Inject a `<script>` right after `<head>` that redefines `navigator.hid` with a fake device. The fake needs `opened:true`, collections with `featureReports:[{reportId:12}]` and `inputReports:[{reportId:5}]`, a `sendFeatureReport` that records packets, and a `receiveFeatureReport` that echoes the last packet's cmd and seq with `r[5]=1` (plus a status reply for cmd `0x20`). Set `r[5]=0` to test the "didn't confirm" path.
  3. Load the result into an `iframe` via `srcdoc`.
  4. Click buttons, then read the recorded packets. Call the fake's stored `inputreport` listener with `{reportId:5, data: DataView([6,0,poll,stage])}` to test live sync.
- **Mock Pointer Lock** (finder):
  1. Override `document.pointerLockElement` with `Object.defineProperty`, and stub `pad.requestPointerLock` and `document.exitPointerLock`.
  2. Dispatch `MouseEvent('mousemove', {movementX})` on `#pad`.
- **Real mouse without a browser:** `re-notes/scripts/hidtalk.py`, a short Python script using only `ctypes` (`setupapi` to find the `vid_248a … col04` path, `CreateFileW`, then `hid.dll` `HidD_SetFeature` / `HidD_GetFeature` with a 33-byte buffer starting `0x0C`). That's how the status query and the acknowledgement format were confirmed.
- **What was checked (mock mouse):** a full apply sends the same 14 packets, byte for byte, as the first version did; a single change sends only its group; an unacknowledged packet leaves the group pending; Undo restores the confirmed values; no Left click blocks Apply; live sync updates the stage and polling rate; the finder produces results with mocked swipes; no horizontal scroll at 700 px wide.

## Reverse-engineering notes

All of this was done statically; the original program was never run.

- **Tools:**
  - `innoextract` to unpack the Inno Setup installer.
  - Python with `capstone` and `pefile` (wheels unzipped, run with `py -I`).
  - The app is 32-bit MFC: `IO1.1 3395 Pro.exe`, plus `KeyboardHook.dll` for macros. The DLL is the likely reason for the antivirus hits; that's unconfirmed.
- **What's in `re-notes/`** (copied here so it survives; the vendor `.exe`/`.dll` were deliberately left out):

  | File | Purpose |
  |---|---|
  | `scripts/an1.py LIB EXE OUT.pkl` | Disassembles the app's `.text` with capstone into `insns.pkl` (list of `(addr, size, mnemonic, operands)`, the import table, and the image base) and prints the HID/SetupAPI call sites. **Run this first**: the 21 MB pickle wasn't kept. |
  | `scripts/an2.py`, `an6.py` | Early one-off dumps (call-site context, imports). |
  | `scripts/an3.py PKL "pat1,pat2" CTX` | Substring search over operands, with ±CTX instructions. Patterns split on commas, so don't put commas inside one. |
  | `scripts/an4.py` | DPI table probe (it turned out to be built at runtime by `0x408760`). |
  | `scripts/an5.py LIB EXE PKL fields` | Finds struct-field accesses and nearby UTF-16 strings. |
  | `scripts/an7.py LIB EXE PKL "Key=,..."` | Finds the code that reads or writes a `.psf` key, via its format string. |
  | `scripts/an8.py PKL REGEX BEFORE AFTER` | Regex search over `mnemonic operands` with context. The most useful one. |
  | `scripts/an9.py LIB EXE PKL START END` | Disassembles a hex address range and resolves UTF-16 string references. |
  | `scripts/an10.py LIB EXE PKL "s1,s2"` | Finds code references to exact UTF-16 strings. |
  | `scripts/hidcaps.py` | Lists the mouse's HID interfaces and their report IDs. Read-only: sends nothing to the mouse. Run with `py -I`. |
  | `scripts/hidtalk.py status` / `set CMD B0 B1 …` | Talks to the settings interface directly: `status` is the read-only status query; `set` sends one settings packet (hex bytes) and prints the acknowledgement. `set` changes the mouse. |
  | `disasm/hid.asm` | Listing of the whole HID-sending area (`0x42c800`…). Every packet builder is in here. |
  | `disasm/dpi.asm`, `dpitab.asm`, `ui.asm` | DPI packet and table builder, plus a UI-handler excerpt. |
  | `vendor-config/default0-4.psf` | The original default profiles (UTF-16 INI). `default0` has Chinese names; the others are English. |
  | `vendor-config/Lan_En.txt` | All the original UI strings by ID: button actions 020–080, lighting 100–111, power 260–274. |

- **Setup to re-run the scripts:**
  - Python 3 with capstone and pefile. pip wasn't available, so the wheels were downloaded and unzipped into a folder that is passed as `LIB`.
  - Unpack the installer with `innoextract` to get `IO1.1 3395 Pro.exe`, and keep it in its own folder.
  - Always run with `py -I`. **Never run the vendor exe.**
- **Useful addresses:**
  - Packet buffer: `this+0xd769c`. The cmd byte is written as `word [this+0xd769d] = 0x<cmd>01`.
  - Builders: `0x430bf2` (DPI), `0x430f78` (LOD), `0x430ff6` (debounce), `0x43123b` (sleep), `0x431399` (wake), `0x432a40` (reset `0x0F`), `0x42f23a` (macro `0x0E`).
  - Profile `.psf` writer: around `0x42ae7a`. `AngleSnapValue` is at profile `+0x9ba3e4` and is saved and loaded but never sent.
- **Swapping the mouse image:**
  1. Give the picture a transparent background and scale it to about 300 px wide (the current one was made from `art/mouse-original.png` with System.Drawing in PowerShell: crop to the alpha bounding box, high-quality bicubic resize to 300×547).
  2. Base64 it into the `window.WMO_PHOTO = "data:image/png;base64,…"` script tag.
  3. Set the `<image id="mousePic">` size to the picture's pixel size and the `<svg id="mouse">` viewBox to that plus a small margin (currently `300×547` in `-16 -12 332 571`).
  4. Re-place the Buttons-tab markers by editing `x`/`y` in `SPOTS` (picture pixels).
- **Changing the icon:** replace the `href` of `<link rel="icon" id="appIcon">` with a 64 px PNG data URI, and rebuild `wmo.ico` from `art/icon-original.png` (crop to the alpha bounding box, scale to 16, 32, 48, 64 and 256 px, then write an ICO file whose entries are those PNG files themselves).
