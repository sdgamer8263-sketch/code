#!/bin/bash

# ==========================================
# SKA HOST MULTI-TOOL (V26.1 - DEV ENVIRONMENT)
# STYLE: NEON CYBERPUNK + DOUBLE BORDERS
# MODULES: NIX ENV + VM + PROXMOX
# ==========================================

# 🎨 Premium Colors (High-Intensity ANSI)
R='\033[1;91m'      # Bright Red
G='\033[1;92m'      # Bright Green
Y='\033[1;93m'      # Bright Yellow
B='\033[1;94m'      # Bright Blue
P='\033[1;95m'      # Bright Magenta
C='\033[1;96m'      # Bright Cyan
W='\033[1;97m'      # Bright White
DG='\033[1;90m'     # Dark Gray
BLINK='\033[5m'     # Blinking
NC='\033[0m'        # No Color

# ==========================================
# 🎬 ANIMATIONS & EFFECTS
# ==========================================

# Smooth Typing Effect
type_effect() {
    local text="$1"
    local speed="$2"
    for (( i=0; i<${#text}; i++ )); do
        echo -en "${text:$i:1}"
        sleep "$speed"
    done
    echo ""
}

# Cyberpunk Spinner Loading Screen
boot_sequence() {
    clear
    echo -e "\n\n"
    local text="${C}  [SYS] Establishing secure connection to SKA HOST servers...${NC}"
    type_effect "$text" 0.02
    
    local chars="/-\|"
    echo -ne "  ${P}Authenticating: ${NC}"
    for i in {1..15}; do
        echo -ne "\b${G}${chars:i%4:1}${NC}"
        sleep 0.1
    done
    
    echo -e "\b${G}SUCCESS!${NC}"
    echo -ne "  ${C}Booting Core Engine [${NC}"
    for ((i = 0; i < 35; i++)); do
        echo -ne "${P}■${NC}"
        sleep 0.02
    done
    echo -e "${C}] 100%${NC}"
    sleep 0.3
}

# ==========================================
# 🖥️ BANNERS & DASHBOARDS
# ==========================================

# Main Dashboard UI (Fixed Alignment & Dynamic Padding)
show_dashboard() {
    clear
    
    # Compress uptime to fit nicely (e.g. "1 days, 2 hours" -> "1d 2h")
    local UPTIME=$(uptime -p | sed -e 's/up //' -e 's/ hours/h/' -e 's/ hour/h/' -e 's/ minutes/m/' -e 's/ minute/m/' -e 's/ days/d/' -e 's/ day/d/' -e 's/,//g') 
    local CPU_LOAD=$(top -bn1 | grep load | awk '{printf "%.2f", $(NF-2)}')
    local RAM_FREE=$(free -m | awk '/Mem:/ { printf("%.0f%%", $3/$2 * 100.0) }')
    
    # Strict padding so the right border NEVER breaks
    printf -v PAD_UPTIME "UP: %-12s" "${UPTIME:0:12}"
    printf -v PAD_CPU "CPU: %-5s" "${CPU_LOAD}%"
    printf -v PAD_RAM "RAM: %-4s" "${RAM_FREE}"

    echo -e "${C}╔════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${C}║${NC}   ${C}███████╗██╗  ██╗ █████╗     ██╗  ██╗ ██████╗ ███████╗████████╗${NC}   ${C}║${NC}"
    echo -e "${C}║${NC}   ${B}██╔════╝██║ ██╔╝██╔══██╗    ██║  ██║██╔═══██╗██╔════╝╚══██╔══╝${NC}   ${C}║${NC}"
    echo -e "${C}║${NC}   ${P}███████╗█████╔╝ ███████║    ███████║██║   ██║███████╗   ██║   ${NC}   ${C}║${NC}"
    echo -e "${C}║${NC}   ${Y}╚════██║██╔═██╗ ██╔══██║    ██╔══██║██║   ██║╚════██║   ██║   ${NC}   ${C}║${NC}"
    echo -e "${C}║${NC}   ${G}███████║██║  ██╗██║  ██║    ██║  ██║╚██████╔╝███████║   ██║   ${NC}   ${C}║${NC}"
    echo -e "${C}║${NC}   ${W}╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝    ╚═╝  ╚═╝ ╚═════╝ ╚══════╝   ╚═╝   ${NC}   ${C}║${NC}"
    echo -e "${C}╠════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${C}║${NC}                   ${Y}⚡ DEVELOPMENT ENVIRONMENT ⚡${NC}                    ${C}║${NC}"
    echo -e "${C}╠════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${C}║${NC} ${BLINK}${G}● ONLINE${NC} ${DG}│${NC} ⏱️ ${W}${PAD_UPTIME}${NC} ${DG}│${NC} 🧠 ${W}${PAD_CPU}${NC} ${DG}│${NC} 💾 ${W}${PAD_RAM}${NC}      ${C}║${NC}"
    echo -e "${C}╚════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# ==========================================
# ⚙️ MAIN SYSTEM LOOP
# ==========================================

# Run Startup Animation
boot_sequence

while true; do
    show_dashboard
    
    # PERFECTLY ALIGNED 70-COLUMN MENU BOX
    echo -e "${DG}╭───────────────────── ${W}SELECT DEPLOYMENT MODULE ${DG}─────────────────────╮${NC}"
    echo -e "${DG}│${NC}                                                                    ${DG}│${NC}"
    echo -e "${DG}│${NC}      ${P}[1]${NC} 🔧 Environment Setup Tool                                 ${DG}│${NC}"
    echo -e "${DG}│${NC}      ${P}[2]${NC} 🖥️  Run Virtual Machine Installer (KVM)                  ${DG}│${NC}"
    echo -e "${DG}│${NC}      ${P}[3]${NC} 🖥️  Run Virtual Machine Installer (No KVM)               ${DG}│${NC}"
    echo -e "${DG}│${NC}      ${P}[4]${NC} ☁️  Proxmox Setup                                         ${DG}│${NC}"
    echo -e "${DG}│${NC}                                                                    ${DG}│${NC}"
    echo -e "${DG}├────────────────────────────────────────────────────────────────────┤${NC}"
    echo -e "${DG}│${NC}                         ${R}[0] ❌ SYSTEM EXIT${NC}                         ${DG}│${NC}"
    echo -e "${DG}╰────────────────────────────────────────────────────────────────────╯${NC}"
    echo ""
    
    echo -en "  ${Y}root@skahost${W}:~${C}/home${NC}# "
    read -r op
    
    case $op in
    
    # ---------------------------------------------------------
    # (1) Environment Setup TOOL
    # ---------------------------------------------------------
    1|01)
        echo -e "\n${C}  [SYS] Initializing Environment Tool Setup...${NC}"
        
        echo -e "  ${Y}● Cleaning up old files...${NC}"
        cd ~ || exit
        rm -rf myapp flutter
        
        # Ensure vm directory exists before cd
        mkdir -p vm && cd vm || exit
        
        if [ ! -d ".idx" ]; then
            echo -e "  ${G}✔️ Creating .idx directory...${NC}"
            mkdir .idx
            cd .idx || exit
            
            echo -e "  ${Y}● Generating dev.nix configuration...${NC}"
            cat <<EOF > dev.nix
{ pkgs, ... }: {
  channel = "stable-24.05";

  packages = with pkgs; [
    unzip
    openssh
    git
    qemu_kvm
    sudo
    cdrkit
    cloud-utils
    qemu
  ];

  env = {
    EDITOR = "nano";
  };

  idx = {
    extensions = [
      "Dart-Code.flutter"
      "Dart-Code.dart-code"
    ];

    workspace = {
      onCreate = { };
      onStart = { };
    };

    previews = {
      enable = false;
    };
  };
}
EOF
            
            type_effect "\n${G}✅ Tool setup complete!${NC}" 0.02
            echo -e "  ${C}╭──────────────────────────────────────────────────╮${NC}"
            echo -e "  ${C}│${NC} ${DG}Status:${NC}   ${G}Ready to use${NC}                         ${C}│${NC}"
            echo -e "  ${C}│${NC} ${DG}Location:${NC} ${Y}~/vm/.idx${NC}                            ${C}│${NC}"
            echo -e "  ${C}╰──────────────────────────────────────────────────╯${NC}"
        else
            echo -e "  ${Y}⚠️  Directory .idx already exists — skipping.${NC}"
        fi
        ;;
    
    # ---------------------------------------------------------
    # (2) Run VM1 Kvm
    # ---------------------------------------------------------
    2|02)
        echo -e "\n${C}  [SYS] Starting IDX VM (KVM) From GitHub...${NC}"
        echo -e "  ${Y}● Fetching remote script...${NC}"
        bash <(curl -s https://raw.githubusercontent.com/sdgamer8263-sketch/code/main/Vps/vm/vm.sh)
        ;;

    # ---------------------------------------------------------
    # (3) Run VM2 No KVM
    # ---------------------------------------------------------
    3|03)
        echo -e "\n${C}  [SYS] Starting VM (No KVM) From GitHub...${NC}"
        echo -e "  ${Y}● Fetching remote scripts...${NC}"
        bash <(curl -s https://raw.githubusercontent.com/sdgamer8263-sketch/code/main/Vps/idx/idx.sh)
        bash <(curl -s https://raw.githubusercontent.com/sdgamer8263-sketch/code/main/Vps/nonkvm/nonkvm.sh)
        ;;

    # ---------------------------------------------------------
    # (4) Proxmox Setup
    # ---------------------------------------------------------
    4|04)
        echo -e "\n${C}  [SYS] Starting Proxmox Setup From GitHub...${NC}"
        echo -e "  ${Y}● Fetching remote script...${NC}"
        bash <(curl -s https://raw.githubusercontent.com/sdgamer8263-sketch/code/main/Vps/Proxmox/Proxmox.sh)
        ;;  

    # ---------------------------------------------------------
    # (0) EXIT
    # ---------------------------------------------------------
    0|00|5|05)
        echo -e ""
        type_effect "${R}  [SYS] Terminating processes...${NC}" 0.03
        type_effect "${DG}  [SYS] Goodbye!${NC}" 0.05
        exit 0
        ;;
    
    *)
        echo -e "${R}  [!] Error: Command not recognized.${NC}"
        sleep 1
        continue
        ;;
    esac

    echo -e "\n${G}  [+] Sequence Completed!${NC}"
    
    # 🟢 TERMINAL PROMPT (PAUSE / WAIT)
    echo -en "  ${Y}root@skahost${W}:~${DG}/sys/pause${NC} (Press ENTER) "
    read -r
done
