# Host Conditioning Report: RPI4 Diagnostic Node

This document details the refined environment conditioning using industry-standard reliability patterns.

## 1. Web Layer (Nginx)
Replaced the development Python server with **Nginx** for high-availability and zero port-deadlocks.
- **Port:** 8888
- **Configuration:** \`/etc/nginx/sites-available/rpi4-neon-diag\`
- **Feature:** Explicit MIME type handling for \`.dot\` files.

## 2. Persistence Layer (Systemd Timer)
Moved from cron to **Systemd Timers** for more robust scheduling and logging.
- **Service:** \`rpi4-neon-diag-generator.service\` (Oneshot)
- **Timer:** \`rpi4-neon-diag-generator.timer\` (Every 5 minutes)
- **Log Access:** \`journalctl -u rpi4-neon-diag-generator.service\`

## 3. Pi-Specific Metrics (vcgencmd)
Integrated firmware-level data to capture critical health events:
- **Core Voltage:** Real-time monitoring of the power rail.
- **Throttle State:** Detects under-voltage and thermal capping.
- **Clock Frequencies:** Monitors ARM core scaling.

## 4. Automation (install.sh)
Implemented an idempotent installation script in \`src/install.sh\` that can safely re-configure the node from scratch.

---
*Conditioning Grade: Production-Ready*
