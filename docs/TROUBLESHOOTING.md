# Troubleshooting Guide

A consolidated reference for maintaining and fixing the RPI4 Neon Diagnostics suite.

## 1. Dashboard Not Loading (192.168.1.165:8888)
- **Check Service:** `sudo systemctl status rpi4-neon-diagnostics.service`
- **Port Blocked:** If you see "Address already in use", run:
  `sudo fuser -k 8888/tcp`
  Then restart: `sudo systemctl restart rpi4-neon-diagnostics.service`
- **Firewall:** Ensure port 8888 is open: `sudo ufw status`

## 2. Blank Live Graph
- **Initialization:** Wait for the bottom debug console to say "Local Engine Ready." (WASM takes ~2-3 seconds to warm up).
- **Hard Refresh:** If the graph is missing after an update, press `Ctrl + F5` to clear the browser cache.
- **Extensions:** If you see `ReferenceError` in the browser console, try opening the dashboard in **Incognito Mode**. Some privacy extensions block WASM execution.

## 3. Diagrams Not Updating
- **Check Cron:** `crontab -l` should show the refresh task.
- **Manual Trigger:** Run the generator manually to check for errors:
  `~/rpi4_diagnostics_20260515/src/generate_diagrams.sh`

## 4. Resetting the Node
If the filesystem becomes inconsistent, you can force-sync from the GitHub Gold Master:
```bash
cd ~/rpi4_diagnostics_20260515
git fetch origin
git reset --hard origin/master
```

---
*Technical Support: danindiana/rpi4-neon-diag*
