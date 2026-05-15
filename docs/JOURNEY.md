# The Journey: From Raw Data to Neon Mission Control

This document traces the evolution of the RPI4 Neon Diagnostics project from a simple diagnostic request to a robust, self-contained interactive dashboard.

## 🟢 Phase 1: Connection & Baseline
The journey began with establishing a stable SSH bridge to `rpi4`. We audited the system baseline:
- **Environment:** Debian Trixie (6.18 kernel) on aarch64.
- **Initial State:** Active services included `tor`, `go2rtc`, and `nginx`.
- **Goal:** Transform raw CLI output into high-signal visual diagnostics.

## 🔵 Phase 2: The Neon Pulse
We introduced the **Neon Aesthetic**—a high-contrast theme using Cyan (#00FFFF), Magenta (#FF00FF), and Green (#39FF14). 
- **Milestone:** Installed `graphviz` and drafted the first five `.dot` files: Networking, Health, Services, Chronology, and Config.
- **Result:** The first static PNGs were rendered, proving the visual concept.

## 🟡 Phase 3: Conditioning the Node
To move beyond a one-off script, we conditioned the host environment for persistence:
- **Security:** Opened port `8888` on `ufw` specifically for the LAN.
- **Persistence:** Created a `systemd` unit to manage the HTTP server and auto-refresh diagrams.
- **Integration:** Injected the diagnostic link into the `MOTD` so the dashboard is visible on every login.

## 🟠 Phase 4: Mission Control (The WASM Struggle)
The user requested interactivity. We integrated `d3-graphviz` to allow zooming and panning.
- **The Conflict:** We hit a "double-slash" WASM pathing error and browser extension interference (`fp_assemble_injection`).
- **The Pivot:** We shifted from a CDN-heavy approach to a **Self-Contained Architecture**, downloading the 1MB WASM binary directly to the RPI4.

## 🟣 Phase 5: Production & Polish
The final phase focused on structural integrity and "sparkle":
- **Organization:** Refactored the repo into `src/`, `assets/`, and `docs/`.
- **UI/UX:** Added neon flicker animations, a live debug console, and a 15-minute cron refresh cycle.
- **Final State:** A fully automated "Mission Control" dashboard that is both a tool and a visual centerpiece.

---
*Documented: 2026-05-15*

## 🏅 Phase 6: Hardening for Production
Based on advanced feedback, we transformed the prototype into a production-grade node:
- **Engine Swap:** Replaced Python with Nginx.
- **Deep Metrics:** Integrated `vcgencmd` to monitor firmware throttle states and core voltages.
- **Modern Scheduling:** Implemented Systemd Timers for diagram generation.
- **Automation:** Created an idempotent `install.sh` for one-command node conditioning.
