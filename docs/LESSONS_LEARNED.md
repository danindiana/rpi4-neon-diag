# Lessons Learned: RPI4 Neon Diagnostics Deployment

This project involved several non-trivial technical hurdles during the deployment of a Graphviz-based interactive diagnostic dashboard.

## 1. WASM Pathing & CDN Reliability
- **Issue:** The `d3-graphviz` library automatically attempts to fetch the WASM engine (`graphvizlib.wasm`) from a CDN. However, it often miscalculates the path, resulting in double-slash (`//`) errors and 400 Bad Requests.
- **Solution:** Transitioned to a **Self-Contained Architecture**. By hosting the WASM binary locally on the RPI4 and explicitly setting the `wasmFolder` in the JS initialization, we eliminated external dependencies and fixed the pathing error.

## 2. Browser Extension Interference
- **Issue:** Privacy and anti-fingerprinting extensions (like those throwing `fp_assemble_injection` errors) can interfere with global JavaScript variables and WASM execution in "Isolated Worlds."
- **Solution:** Implemented flexible global variable detection (`window["@hpcc-js/wasm"] || window["hpccWasm"]`) to ensure the renderer finds the engine even if the extension renames or wraps the global scope.

## 3. Systemd Service & Port Deadlocks
- **Issue:** Rapidly restarting the `python3 -m http.server` can leave the port in a `TIME_WAIT` state or leave "zombie" processes holding the port open, preventing the service from restarting (Error 98: Address already in use).
- **Solution:** Integrated a `sudo fuser -k 8888/tcp` cleanup step into the troubleshooting workflow and ensured the systemd service has proper `Restart` parameters.

## 4. UI/UX: Static vs. Interactive
- **Issue:** Interactive graphs require a "warm-up" period for the WASM engine.
- **Solution:** Retained a "Gallery" of pre-rendered PNGs for instant viewing, while providing a "Mission Control" live view for deep-dive interaction. Added an on-screen debug console to provide user feedback during the engine initialization phase.

---
*Technical Log: 2026-05-15*

## 5. Web Server Migration (Python to Nginx)
- **Issue:** Using a development server (`python3 -m http.server`) for a long-running dashboard led to port deadlocks and limited configuration options.
- **Solution:** Migrated to **Nginx**. This provides industrial reliability, handles multiple concurrent requests, and allows for explicit MIME-type handling for `.dot` files.
- **Permission Hurdle:** Nginx runs as `www-data`, which initially could not access the files in `/home/jeb/`. Corrected by adjusting the home directory permissions to `755`.

## 6. From Cron to Systemd Timers
- **Improvement:** Replaced traditional cron jobs with **Systemd Timers**. This provides unified logging in `journalctl`, cleaner lifecycle management, and precise execution tracking (OnUnitActiveSec).
