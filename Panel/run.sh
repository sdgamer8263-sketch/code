#!/bin/bash
set -euo pipefail

# ==========================================
# SKA HOST MULTI-TOOL (PANEL INSTALLER)
# STYLE: NEON CYBERPUNK + DOUBLE BORDERS
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
# 🎬 ANIMATIONS & UI COMPONENTS
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
    local text="${C}  [SYS] Establishing secure connection to SKA HOST Panel Engine...${NC}"
    type_effect "$text" 0.02
    
    local chars="/-\|"
    echo -ne "  ${P}Authenticating: ${NC}"
    for i in {1..15}; do
        echo -ne "\b${G}${chars:i%4:1}${NC}"
        sleep 0.1
    done
    
    echo -e "\b${G}SUCCESS!${NC}"
    echo -ne "  ${C}Booting Installer Core [${NC}"
    for ((i = 0; i < 35; i++)); do
        echo -ne "${P}■${NC}"
        sleep 0.02
    done
    echo -e "${C}] 100%${NC}"
    sleep 0.3
}

# Main Dashboard UI (Fixed 70-Column Alignment)
show_dashboard() {
    clear
    
    local UPTIME=$(uptime -p | sed -e 's/up //' -e 's/ hours/h/' -e 's/ hour/h/' -e 's/ minutes/m/' -e 's/ minute/m/' -e 's/ days/d/' -e 's/ day/d/' -e 's/,//g') 
    local CPU_LOAD=$(top -bn1 | grep load | awk '{printf "%.2f", $(NF-2)}')
    local RAM_FREE=$(free -m | awk '/Mem:/ { printf("%.0f%%", $3/$2 * 100.0) }')
    
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
    echo -e "${C}║${NC}                  ${Y}⚡ SKA HOST DEPLOYMENT CORE ⚡${NC}                    ${C}║${NC}"
    echo -e "${C}╠════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${C}║${NC} ${BLINK}${G}● ONLINE${NC} ${DG}│${NC} ⏱️ ${W}${PAD_UPTIME}${NC} ${DG}│${NC} 🧠 ${W}${PAD_CPU}${NC} ${DG}│${NC} 💾 ${W}${PAD_RAM}${NC}      ${C}║${NC}"
    echo -e "${C}╚════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# ==========================================
# 🛠️ SUBMENUS & MODULES
# ==========================================

# Submenu: Feather Panel
feather_submenu() {
    while true; do
        show_dashboard
        echo -e "${DG}╭──────────────────── ${W}FEATHER PANEL MODULE ${DG}──────────────────────╮${NC}"
        echo -e "${DG}│${NC}                                                                    ${DG}│${NC}"
        echo -e "${DG}│${NC}      ${P}[1]${NC} 🦅 Feather Panel (Manual)                                 ${DG}│${NC}"
        echo -e "${DG}│${NC}      ${P}[2]${NC} ⚡ Feather Panel (Auto Install)                           ${DG}│${NC}"
        echo -e "${DG}│${NC}                                                                    ${DG}│${NC}"
        echo -e "${DG}├────────────────────────────────────────────────────────────────────┤${NC}"
        echo -e "${DG}│${NC}                         ${R}[0] 🔙 RETURN TO PANELS${NC}                  ${DG}│${NC}"
        echo -e "${DG}╰────────────────────────────────────────────────────────────────────╯${NC}"
        echo ""
        
        echo -en "  ${Y}root@skahost${W}:~${C}/panels/feather${NC}# "
        read -r fea_choice
        case $fea_choice in
            1) 
                echo -e "\n${C}  [SYS] Launching Feather Panel (Manual)...${NC}"
                bash <(curl -s https://raw.githubusercontent.com/sdgamer8263-sketch/code/main/Panel/fea/ufea.sh) ;;
            2) 
                echo -e "\n${C}  [SYS] Launching Feather Panel (Auto)...${NC}"
                bash <(curl -s https://raw.githubusercontent.com/sdgamer8263-sketch/code/main/Panel/fea/fea.sh) ;;
            0) return ;;
            *) echo -e "${R}  [!] Invalid option. Please try again.${NC}"; sleep 1; continue ;;
        esac

        echo -en "\n  ${Y}root@skahost${W}:~${DG}/sys/pause${NC} (Press ENTER) "
        read -r
    done
}

# Submenu: Jexactyl Panel and Dash
jexactyl_submenu() {
    while true; do
        show_dashboard
        echo -e "${DG}╭──────────────────── ${W}JEXACTYL PANEL MODULE ${DG}─────────────────────╮${NC}"
        echo -e "${DG}│${NC}                                                                    ${DG}│${NC}"
        echo -e "${DG}│${NC}      ${P}[1]${NC} 🦖 Jexactyl Panel                                         ${DG}│${NC}"
        echo -e "${DG}│${NC}      ${P}[2]${NC} 🦕 Jexapanel                                              ${DG}│${NC}"
        echo -e "${DG}│${NC}                                                                    ${DG}│${NC}"
        echo -e "${DG}├────────────────────────────────────────────────────────────────────┤${NC}"
        echo -e "${DG}│${NC}                         ${R}[0] 🔙 RETURN TO PANELS${NC}                  ${DG}│${NC}"
        echo -e "${DG}╰────────────────────────────────────────────────────────────────────╯${NC}"
        echo ""
        
        echo -en "  ${Y}root@skahost${W}:~${C}/panels/jexactyl${NC}# "
        read -r jex_choice
        case $jex_choice in
            1) 
                echo -e "\n${C}  [SYS] Launching Jexactyl Panel Setup...${NC}"
                bash <(curl -s https://raw.githubusercontent.com/sdgamer8263-sketch/code/main/Panel/Jexactyl/uJexactyl.sh) ;;
            2) 
                echo -e "\n${C}  [SYS] Launching Jexapanel Setup...${NC}"
                bash <(curl -s https://raw.githubusercontent.com/sdgamer8263-sketch/code/main/Panel/Jexapanel/Jp.sh) ;;
            0) return ;;
            *) echo -e "${R}  [!] Invalid option. Please try again.${NC}"; sleep 1; continue ;;
        esac

        echo -en "\n  ${Y}root@skahost${W}:~${DG}/sys/pause${NC} (Press ENTER) "
        read -r
    done
}

# Submenu: Panels
panels_submenu() {
    while true; do
        show_dashboard
        echo -e "${DG}╭──────────────────────── ${W}INSTALLATION MODULE ${DG}───────────────────────╮${NC}"
        echo -e "${DG}│${NC}                                                                    ${DG}│${NC}"
        echo -e "${DG}│${NC}   ${P}[1]${NC} Pterodactyl Panel        ${P}[6]${NC} Skyport Panel                   ${DG}│${NC}"
        echo -e "${DG}│${NC}   ${P}[2]${NC} Puffer Panel             ${P}[7]${NC} Airlink Panel (Jishnu Bhi)      ${DG}│${NC}"
        echo -e "${DG}│${NC}   ${P}[3]${NC} Reviactyl Panel          ${P}[8]${NC} Hydra Panel                     ${DG}│${NC}"
        echo -e "${DG}│${NC}   ${P}[4]${NC} Feather Panel Menu       ${P}[9]${NC} Oversee Panel                   ${DG}│${NC}"
        echo -e "${DG}│${NC}   ${P}[5]${NC} Jexactyl Panel Menu      ${P}[10]${NC} Darco Panel                    ${DG}│${NC}"
        echo -e "${DG}│${NC}                                                                    ${DG}│${NC}"
        echo -e "${DG}├────────────────────────────────────────────────────────────────────┤${NC}"
        echo -e "${DG}│${NC}                         ${R}[0] 🔙 RETURN TO MAIN${NC}                     ${DG}│${NC}"
        echo -e "${DG}╰────────────────────────────────────────────────────────────────────╯${NC}"
        echo ""
        
        echo -en "  ${Y}root@skahost${W}:~${C}/panels${NC}# "
        read -r panel_choice
        case $panel_choice in
            1) echo -e "\n${C}  [SYS] Launching Pterodactyl Installer...${NC}"; bash <(curl -s https://raw.githubusercontent.com/sdgamer8263-sketch/code/main/Panel/Pterodactyl/install.sh) ;;
            2) echo -e "\n${C}  [SYS] Launching Puffer Panel...${NC}"; bash <(curl -s https://raw.githubusercontent.com/sdgamer8263-sketch/code/main/Panel/PufferPanel/PufferPanel.sh) ;;
            3) echo -e "\n${C}  [SYS] Launching Reviactyl Panel...${NC}"; bash <(curl -s https://raw.githubusercontent.com/sdgamer8263-sketch/code/main/Panel/rev/install.sh) ;;
            4) feather_submenu; continue ;;
            5) jexactyl_submenu; continue ;;
            6) echo -e "\n${C}  [SYS] Launching Skyport Panel...${NC}"; bash <(curl -s https://raw.githubusercontent.com/sdgamer8263-sketch/Panel/main/Skyport/run.sh) ;;
            7) echo -e "\n${C}  [SYS] Launching Airlink Panel...${NC}"; bash <(curl -s https://airlink.jishnu.fun) ;;
            8) echo -e "\n${C}  [SYS] Launching Hydra Panel...${NC}"; bash <(curl -s https://raw.githubusercontent.com/sdgamer8263-sketch/code/main/Panel/Hydra/run.sh) ;;
            9) echo -e "\n${C}  [SYS] Launching Oversee Panel...${NC}"; bash <(curl -s https://raw.githubusercontent.com/sdgamer8263-sketch/code/main/Panel/Oversee/run.sh) ;;
            10) echo -e "\n${C}  [SYS] Launching Darco Panel...${NC}"; bash <(curl -s https://raw.githubusercontent.com/sdgamer8263-sketch/code/main/Panel/Darco/run.sh) ;;
            0) return ;;
            *) echo -e "${R}  [!] Invalid option. Please try again.${NC}"; sleep 1; continue ;;
        esac
        
        echo -en "\n  ${Y}root@skahost${W}:~${DG}/sys/pause${NC} (Press ENTER) "
        read -r
    done
}

# Submenu: Mythical Dash Versions
mythical_submenu() {
    while true; do
        show_dashboard
        echo -e "${DG}╭──────────────────── ${W}MYTHICAL DASHBOARD MODULE ${DG}───────────────────╮${NC}"
        echo -e "${DG}│${NC}                                                                    ${DG}│${NC}"
        echo -e "${DG}│${NC}      ${P}[A]${NC} 🦄 Mythical Dash Version - 3.0                              ${DG}│${NC}"
        echo -e "${DG}│${NC}      ${P}[B]${NC} 🦄 Mythical Dash Version - 4.0                              ${DG}│${NC}"
        echo -e "${DG}│${NC}                                                                    ${DG}│${NC}"
        echo -e "${DG}├────────────────────────────────────────────────────────────────────┤${NC}"
        echo -e "${DG}│${NC}                         ${R}[0] 🔙 RETURN TO DASHBOARDS${NC}              ${DG}│${NC}"
        echo -e "${DG}╰────────────────────────────────────────────────────────────────────╯${NC}"
        echo ""
        
        echo -en "  ${Y}root@skahost${W}:~${C}/dash/mythical${NC}# "
        read -r dash_choice
        case $dash_choice in
            A|a) 
                echo -e "\n${C}  [SYS] Launching Mythical Dash v3.0...${NC}"
                bash <(curl -s https://raw.githubusercontent.com/sdgamer8263-sketch/Panel/main/Dashv3/udashv3.sh) ;;
            B|b) 
                echo -e "\n${C}  [SYS] Launching Mythical Dash v4.0...${NC}"
                bash <(curl -s https://raw.githubusercontent.com/sdgamer8263-sketch/Panel/main/dashv4/udashv4.sh) ;;
            0) return ;;
            *) echo -e "${R}  [!] Invalid option selected. Please try again.${NC}"; sleep 1; continue ;;
        esac

        echo -en "\n  ${Y}root@skahost${W}:~${DG}/sys/pause${NC} (Press ENTER) "
        read -r
    done
}

# Submenu: Dashboard
dashboard_submenu() {
    while true; do
        show_dashboard
        echo -e "${DG}╭──────────────────────── ${W}DASHBOARD MODULE ${DG}──────────────────────────╮${NC}"
        echo -e "${DG}│${NC}                                                                    ${DG}│${NC}"
        echo -e "${DG}│${NC}      ${P}[1]${NC} 🦄 Mythical Dashboard                                     ${DG}│${NC}"
        echo -e "${DG}│${NC}      ${P}[2]${NC} ☀️  Heliactyl Dashboard (Soon)                            ${DG}│${NC}"
        echo -e "${DG}│${NC}                                                                    ${DG}│${NC}"
        echo -e "${DG}├────────────────────────────────────────────────────────────────────┤${NC}"
        echo -e "${DG}│${NC}                         ${R}[0] 🔙 RETURN TO MAIN${NC}                    ${DG}│${NC}"
        echo -e "${DG}╰────────────────────────────────────────────────────────────────────╯${NC}"
        echo ""
        
        echo -en "  ${Y}root@skahost${W}:~${C}/dashboards${NC}# "
        read -r dash_menu_choice
        case $dash_menu_choice in
            1) mythical_submenu; continue ;;
            2) 
                echo -e "\n${C}  [SYS] Launching Heliactyl Setup...${NC}"
                bash <(curl -sL https://raw.githubusercontent.com/sdgamer8263-sketch/skost/main/run.sh) 
                ;;
            0) return ;;
            *) echo -e "${R}  [!] Invalid option. Please try again.${NC}"; sleep 1; continue ;;
        esac

        echo -en "\n  ${Y}root@skahost${W}:~${DG}/sys/pause${NC} (Press ENTER) "
        read -r
    done
}

# Submenu: VPS Control Panel
vps_submenu() {
    while true; do
        show_dashboard
        echo -e "${DG}╭────────────────────── ${W}VPS CONTROL PANEL MODULE ${DG}────────────────────╮${NC}"
        echo -e "${DG}│${NC}                                                                    ${DG}│${NC}"
        echo -e "${DG}│${NC}      ${P}[1]${NC} 🖥️  HVM Control Panel                                     ${DG}│${NC}"
        echo -e "${DG}│${NC}      ${P}[2]${NC} 🚀 New VPS Panel (Soon)                                   ${DG}│${NC}"
        echo -e "${DG}│${NC}                                                                    ${DG}│${NC}"
        echo -e "${DG}├────────────────────────────────────────────────────────────────────┤${NC}"
        echo -e "${DG}│${NC}                         ${R}[0] 🔙 RETURN TO MAIN${NC}                    ${DG}│${NC}"
        echo -e "${DG}╰────────────────────────────────────────────────────────────────────╯${NC}"
        echo ""
        
        echo -en "  ${Y}root@skahost${W}:~${C}/vps-control${NC}# "
        read -r vps_choice
        case $vps_choice in
            1) 
                echo -e "\n${C}  [SYS] Launching HVM Control Panel...${NC}"
                bash <(curl -sL https://raw.githubusercontent.com/sdgamer8263-sketch/Panel/main/Vpsctrl/HVM) 
                ;;
            2) 
                echo -e "\n${C}  [SYS] Launching New VPS Panel...${NC}"
                bash <(curl -sL https://raw.githubusercontent.com/sdgamer8263-sketch/skost/main/run.sh) 
                ;;
            0) return ;;
            *) echo -e "${R}  [!] Invalid option. Please try again.${NC}"; sleep 1; continue ;;
        esac

        echo -en "\n  ${Y}root@skahost${W}:~${DG}/sys/pause${NC} (Press ENTER) "
        read -r
    done
}

# ==========================================
# ⚙️ MAIN SYSTEM LOOP
# ==========================================

boot_sequence

while true; do
    show_dashboard
    
    # PERFECTLY ALIGNED 70-COLUMN MENU BOX
    echo -e "${DG}╭───────────────────── ${W}SELECT DEPLOYMENT MODULE ${DG}─────────────────────╮${NC}"
    echo -e "${DG}│${NC}                                                                    ${DG}│${NC}"
    echo -e "${DG}│${NC}      ${P}[1]${NC} 🖥️  Server Panels          ${P}[5]${NC} 🎛️  Control Panel        ${DG}│${NC}"
    echo -e "${DG}│${NC}      ${P}[2]${NC} 📊 Web Dashboards          ${P}[6]${NC} ⚙️  VPS Control Panel      ${DG}│${NC}"
    echo -e "${DG}│${NC}      ${P}[3]${NC} 💳 Payment Panel           ${P}[7]${NC} 💼 WHMC Panel              ${DG}│${NC}"
    echo -e "${DG}│${NC}      ${P}[4]${NC} 🚛 Convoy Panel                                           ${DG}│${NC}"
    echo -e "${DG}│${NC}                                                                    ${DG}│${NC}"
    echo -e "${DG}├────────────────────────────────────────────────────────────────────┤${NC}"
    echo -e "${DG}│${NC}                         ${R}[0] ❌ SYSTEM EXIT${NC}                         ${DG}│${NC}"
    echo -e "${DG}╰────────────────────────────────────────────────────────────────────╯${NC}"
    echo ""
    
    echo -en "  ${Y}root@skahost${W}:~${C}/home${NC}# "
    read -r main_choice

    case $main_choice in
        1) panels_submenu; continue ;;
        2) dashboard_submenu; continue ;;
        3) 
            echo -e "\n${C}  [SYS] Launching Payment Panel...${NC}"
            bash <(curl -s https://raw.githubusercontent.com/sdgamer8263-sketch/code/main/Panel/Paymenter/install.sh) 
            ;;
        4) 
            echo -e "\n${C}  [SYS] Launching Convoy Panel...${NC}"
            bash <(curl -s https://raw.githubusercontent.com/sdgamer8263-sketch/code/main/Panel/convoy/run.sh) 
            ;;
        5) 
            echo -e "\n${C}  [SYS] Launching Control Panel...${NC}"
            bash <(curl -s https://raw.githubusercontent.com/sdgamer8263-sketch/code/main/Panel/ctrl/run.sh) 
            ;;
        6) vps_submenu; continue ;;
        7)
            echo -e "\n${C}  [SYS] Launching WHMC Panel...${NC}"
            bash <(curl -s https://raw.githubusercontent.com/sdgamer8263-sketch/code/main/Panel/WHMC/install.sh)
            ;;
        0) 
            echo -e ""
            type_effect "${R}  [SYS] Terminating processes...${NC}" 0.03
            type_effect "${DG}  [SYS] Goodbye!${NC}" 0.05
            exit 0 
            ;;
        *) 
            echo -e "${R}  [!] Invalid selection. Try again.${NC}"
            sleep 1 
            continue
            ;;
    esac

    echo -en "\n  ${Y}root@skahost${W}:~${DG}/sys/pause${NC} (Press ENTER) "
    read -r
done
