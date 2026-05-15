#!/bin/bash
set -euo pipefail

# Find the base directory
BASE_DIR=$(dirname $(dirname $(realpath $0)))
CONFIG_FILE="$BASE_DIR/config.env"

if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo "Warning: config.env not found, using defaults."
    DIAG_DIR="$BASE_DIR"
    DOT_DIR="$DIAG_DIR/docs/diagrams"
    ASSET_DIR="$DIAG_DIR/assets"
    BG_COLOR="#0D0D0D"
    TEXT_COLOR="#00FFFF"
    BORDER_COLOR="#FF00FF"
    NODE_COLOR="#1A1A1A"
fi

mkdir -p "$DOT_DIR" "$ASSET_DIR"

# Helper to generate DOT content
gen_dot() {
    local file=$1
    local label=$2
    local color=$3
    local content=$4
    cat << EOD > "$DOT_DIR/$file"
digraph G {
    bgcolor="$BG_COLOR";
    node [style=filled, fillcolor="$NODE_COLOR", fontcolor="$TEXT_COLOR", color="$color", fontname="Monospace"];
    edge [color="$TEXT_COLOR", fontname="Monospace"];
    label="$label";
    labelloc="t"; fontcolor="$color"; fontname="Monospace";
    $content
}
EOD
}

# 1. Networking Pulse
gen_dot "networking.dot" "RPI4 NETWORKING PULSE" "#FFFF33" "
    node [shape=box, color=\"#FF00FF\"];
    eth0 [label=\"eth0\n192.168.1.165\"];
    gateway [label=\"Gateway\n192.168.1.254\", color=\"#FF3131\"];
    n64 [label=\"Neighbor\n192.168.1.64\"];
    eth0 -> gateway [label=\"default\"];
    eth0 -> n64;
"

# 2. Health Diagram
LOAD=$(uptime | awk -F"load average: " "{print \$2}" | cut -d, -f1)
TEMP=$(cat /sys/class/thermal/thermal_zone0/temp | awk "{print \$1/1000}")
MEM_USED=$(free -m | awk "/Mem:/ {print \$3}")
MEM_TOTAL=$(free -m | awk "/Mem:/ {print \$2}")
DISK_USAGE=$(df -h / | awk "/\// {print \$5}")

gen_dot "health.dot" "SYSTEM VITALS" "#00FFFF" "
    node [shape=circle, color=\"#FF00FF\"];
    cpu [label=\"CPU\nLoad: $LOAD\"];
    temp [label=\"Temp\n$TEMP C\", color=\"#39FF14\"];
    mem [label=\"RAM\n$MEM_USED/$MEM_TOTAL MB\"];
    disk [label=\"Disk\n$DISK_USAGE Used\"];
    cpu -> temp; cpu -> mem; cpu -> disk;
"

# 3. Services Diagram
gen_dot "services.dot" "ACTIVE ARMADA" "#39FF14" "
    node [shape=hexagon];
    nginx [label=\"nginx:80\"];
    tor [label=\"tor:9001\"];
    go2rtc [label=\"go2rtc:1984\"];
    pi [label=\"RPI4\", shape=doublecircle, color=\"#FFFF33\"];
    pi -> nginx; pi -> tor; pi -> go2rtc;
"

# 4. Power & Firmware (vcgencmd)
THROTTLED=$(sudo vcgencmd get_throttled | cut -d= -f2)
VOLTS=$(sudo vcgencmd measure_volts core | cut -d= -f2)
FREQ=$(sudo vcgencmd measure_clock arm | awk -F= "{print \$2/1000000 \" MHz\"}")

gen_dot "firmware.dot" "POWER & FIRMWARE PULSE" "#FF00FF" "
    node [shape=Mrecord, color=\"#00FFFF\"];
    power [label=\"Throttle State\n$THROTTLED\"];
    volts [label=\"Core Voltage\n$VOLTS\"];
    clock [label=\"Arm Clock\n$FREQ\"];
    pi_firm [label=\"VCGENCMD\", shape=doublecircle, color=\"#FFFF33\"];
    pi_firm -> power; pi_firm -> volts; pi_firm -> clock;
"

# 5. Chronology
UPTIME=$(uptime -p)
gen_dot "chronology.dot" "THE STORY SO FAR" "#FF00FF" "
    node [shape=plaintext];
    boot [label=\"Boot\"];
    stable [label=\"Stable: $UPTIME\"];
    now [label=\"Current Status\"];
    boot -> stable -> now;
"

# 6. Configuration
gen_dot "config.dot" "BLUEPRINT LAYOUT" "#FFFF33" "
    node [shape=folder];
    etc -> nginx; etc -> tor; etc -> ssh;
"

# 7. Service Flow
gen_dot "service_flow.dot" "MISSION CONTROL PIPELINE" "#00FFFF" "
    node [shape=note];
    systemd -> nginx -> browser;
    cron -> script -> diagrams;
"

# 8. Conditioning
gen_dot "conditioning_chain.dot" "HOST CONDITIONING CHAIN" "#FF00FF" "
    node [shape=cylinder];
    apt -> fw -> nginx -> motd;
"

# Render all
for f in "$DOT_DIR"/*.dot; do
    name=$(basename "$f" .dot)
    echo "Rendering $name..."
    dot -Tpng "$f" -o "$ASSET_DIR/$name.png"
    dot -Tsvg "$f" -o "$ASSET_DIR/$name.svg"
done
