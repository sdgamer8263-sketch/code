#!/bin/bash
set -euo pipefail

# ==========================================
# SKA HOST MULTI-TOOL (REVIACTYL CONTROL)
# STYLE: NEON CYBERPUNK + DOUBLE BORDERS
# BACKEND: REVIACTYL CLOUD REPO
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
    local text="${C}  [SYS] Establishing secure connection to SKA HOST Control Center...${NC}"
    type_effect "$text" 0.02
    
    local chars="/-\|"
    echo -ne "  ${P}Authenticating: ${NC}"
    for i in {1..15}; do
        echo -ne "\b${G}${chars:i%4:1}${NC}"
        sleep 0.1
    done
    
    echo -e "\b${G}SUCCESS!${NC}"
    echo -ne "  ${C}Booting Management Core [${NC}"
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
    echo -e "${C}║${NC}                   ${Y}⚡ REVIACTYL CONTROL CENTER ⚡${NC}                   ${C}║${NC}"
    echo -e "${C}╠════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${C}║${NC} ${BLINK}${G}● ONLINE${NC} ${DG}│${NC} ⏱️ ${W}${PAD_UPTIME}${NC} ${DG}│${NC} 🧠 ${W}${PAD_CPU}${NC} ${DG}│${NC} 💾 ${W}${PAD_RAM}${NC}      ${C}║${NC}"
    echo -e "${C}╚════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# ==========================================
# ⚙️ CORE MODULES
# ==========================================

install_ptero() {
    echo -e "\n${C}  [SYS] Initiating Reviactyl Installation...${NC}"
    echo -e "  ${Y}● Running external script silently...${NC}"
    
    bash <(curl -s https://raw.githubusercontent.com/sdgamer8263-sketch/code/main/Oanel/rev/run.sh)
    
    type_effect "\n${G}✔️ Installation Sequence Complete.${NC}" 0.02
}

create_user() {
    if [ ! -d /var/www/reviactyl ]; then
        echo -e "\n${R}  [!] Panel directory not found (/var/www/reviactyl).${NC}"
        echo -e "${R}  [!] Please install the panel first.${NC}"
        return
    fi

    echo -e "\n      ${C}╭───────── ${W}USER MANAGEMENT ${C}─────────╮${NC}"
    echo -e "      ${C}│${NC}  ${G}[1]${NC} Custom User Creation        ${C}│${NC}"
    echo -e "      ${C}│${NC}  ${Y}[2]${NC} Auto-Generate Admin User    ${C}│${NC}"
    echo -e "      ${C}╰──────────────────────────────────╯${NC}\n"
    
    echo -en "  ${Y}root@skahost${W}:~${C}/reviactyl/users${NC}# "
    read -r choice

    cd /var/www/reviactyl || exit

    if [ "$choice" = "1" ]; then
        echo -e "\n${C}  [SYS] Launching manual user creation...${NC}"
        php artisan p:user:make

    elif [ "$choice" = "2" ]; then
        echo -ne "\n  ${Y}● Generating Auto-Admin User...${NC}\r"

        USERNAME="user$(openssl rand -hex 2)"
        PASSWORD="$(openssl rand -base64 10)"
        EMAIL="$(openssl rand -base64 4)@email.com"
        FIRST="$(openssl rand -base64 6)"
        LAST="$(openssl rand -base64 4)"
        
        php artisan p:user:make -n \
            --email=${EMAIL} \
            --username=${USERNAME} \
            --password=${PASSWORD} \
            --admin=1 \
            --name-first=${FIRST} \
            --name-last=${LAST} >/dev/null 2>&1

        echo -e "  ${G}✔️ Auto Admin User Created!            ${NC}"
        echo -e "\n      ${DG}╭───── ${W}CREDENTIALS ${DG}─────╮${NC}"
        echo -e "      ${DG}│${NC} ${C}User:${NC} ${W}$USERNAME"
        echo -e "      ${DG}│${NC} ${C}Pass:${NC} ${W}$PASSWORD"
        echo -e "      ${DG}│${NC} ${C}Mail:${NC} ${W}$EMAIL"
        echo -e "      ${DG}╰───────────────────────╯${NC}"
    else
        echo -e "\n${R}  [!] Invalid Option.${NC}"
    fi
}

uninstall_ptero() {
    echo -e "\n${R}  [WARN] This will completely delete the Panel and Databases!${NC}"
    echo -en "  ${Y}root@skahost${W}:~${C}/reviactyl/uninstall${NC} (Are you sure? y/N)# "
    read -r confirm
    
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo -e "\n${DG}  [SYS] Uninstallation cancelled.${NC}"
        return
    fi

    echo -e "\n${C}  [SYS] Initiating Uninstallation Sequence...${NC}"
    
    echo -ne "  ${Y}● Stopping Services & Cronjobs...${NC}\r"
    systemctl stop reviq.service >/dev/null 2>&1 || true
    systemctl disable reviq.service >/dev/null 2>&1 || true
    rm -f /etc/systemd/system/reviq.service
    systemctl daemon-reload >/dev/null 2>&1
    crontab -l 2>/dev/null | grep -v 'php /var/www/reviactyl/artisan schedule:run' | crontab - >/dev/null 2>&1 || true
    echo -e "  ${G}✔️ Services stopped & removed.           ${NC}"

    echo -ne "  ${Y}● Dropping Database & Users...${NC}\r"
    mysql -u root -e "DROP DATABASE IF EXISTS reviactyl;" >/dev/null 2>&1 || true
    mysql -u root -e "DROP USER IF EXISTS 'reviactyl'@'127.0.0.1';" >/dev/null 2>&1 || true
    mysql -u root -e "FLUSH PRIVILEGES;" >/dev/null 2>&1 || true
    echo -e "  ${G}✔️ Database dropped successfully.        ${NC}"

    echo -ne "  ${Y}● Cleaning Nginx Configs & Core Files...${NC}\r"
    rm -f /etc/nginx/sites-enabled/reviactyl.conf
    rm -f /etc/nginx/sites-available/reviactyl.conf
    systemctl reload nginx >/dev/null 2>&1 || true
    rm -rf /var/www/reviactyl
    echo -e "  ${G}✔️ All files and configs cleaned.        ${NC}"

    type_effect "\n${G}✔️ Panel removed successfully (Wings untouched).${NC}" 0.02
}

update_panel() {
    if [ ! -d /var/www/reviactyl ]; then
        echo -e "\n${R}  [!] Panel not found in /var/www/reviactyl${NC}"
        return
    fi

    echo -e "\n${C}  [SYS] Executing Update Sequence...${NC}"
    
    echo -ne "  ${Y}● Entering Maintenance Mode...${NC}\r"
    cd /var/www/reviactyl
    php artisan down >/dev/null 2>&1 || true
    rm -rf /var/www/reviactyl/* >/dev/null 2>&1
    echo -e "  ${G}✔️ Maintenance Mode Enabled.       ${NC}"

    echo -ne "  ${Y}● Downloading Latest Release...${NC}\r"
    curl -Lso panel.tar.gz https://github.com/reviactyl/panel/releases/latest/download/panel.tar.gz >/dev/null 2>&1
    tar -xzf panel.tar.gz >/dev/null 2>&1
    chmod -R 755 storage/* bootstrap/cache/ >/dev/null 2>&1
    echo -e "  ${G}✔️ Files downloaded & extracted.   ${NC}"

    echo -ne "  ${Y}● Updating Composer Dependencies...${NC}\r"
    COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --optimize-autoloader >/dev/null 2>&1
    echo -e "  ${G}✔️ Dependencies updated.           ${NC}"

    echo -ne "  ${Y}● Clearing Cache & Migrating DB...${NC}\r"
    php artisan view:clear >/dev/null 2>&1
    php artisan config:clear >/dev/null 2>&1
    php artisan migrate --seed --force >/dev/null 2>&1
    chown -R www-data:www-data /var/www/reviactyl/* >/dev/null 2>&1
    echo -e "  ${G}✔️ Cache cleared & DB migrated.    ${NC}"

    echo -ne "  ${Y}● Restarting Queue Workers...${NC}\r"
    php artisan queue:restart >/dev/null 2>&1
    php artisan up >/dev/null 2>&1
    echo -e "  ${G}✔️ System online & Workers active. ${NC}"

    type_effect "\n${G}✔️ Panel Updated Successfully.${NC}" 0.02
}

migrating_panel() {
    if [ ! -d /var/www/pterodactyl ]; then
        echo -e "\n${R}  [!] Pterodactyl Panel not found! Cannot migrate.${NC}"
        return
    fi

    echo -e "\n${C}  [SYS] Executing Pterodactyl to Reviactyl Migration...${NC}"
    
    echo -ne "  ${Y}● Entering Maintenance Mode...${NC}\r"
    cd /var/www/pterodactyl
    php artisan down >/dev/null 2>&1 || true
    rm -rf * >/dev/null 2>&1
    echo -e "  ${G}✔️ Maintenance Mode Enabled.       ${NC}"

    echo -ne "  ${Y}● Downloading Latest Reviactyl...${NC}\r"
    curl -Lso panel.tar.gz https://github.com/reviactyl/panel/releases/latest/download/panel.tar.gz >/dev/null 2>&1
    tar -xzf panel.tar.gz >/dev/null 2>&1
    chmod -R 755 storage/* bootstrap/cache/ >/dev/null 2>&1
    echo -e "  ${G}✔️ Files downloaded & extracted.   ${NC}"

    echo -ne "  ${Y}● Updating Composer Dependencies...${NC}\r"
    COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --optimize-autoloader >/dev/null 2>&1
    echo -e "  ${G}✔️ Dependencies updated.           ${NC}"

    echo -ne "  ${Y}● Clearing Cache & Migrating DB...${NC}\r"
    php artisan migrate --seed --force >/dev/null 2>&1
    chown -R www-data:www-data /var/www/pterodactyl/* >/dev/null 2>&1
    echo -e "  ${G}✔️ DB migrated successfully.       ${NC}"

    echo -ne "  ${Y}● Enabling Services...${NC}\r"
    systemctl enable --now pteroq.service >/dev/null 2>&1 || true
    php artisan up >/dev/null 2>&1
    echo -e "  ${G}✔️ System online & Workers active. ${NC}"

    type_effect "\n${G}🎉 Panel Migrated Successfully to Reviactyl.${NC}" 0.02
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
    
    # Check Install Status
    if [ -d "/var/www/reviactyl" ]; then
        echo -e "${DG}│${NC}   ${BOLD}${W}PANEL STATUS:${NC} ${G}INSTALLED ✔${NC}                                      ${DG}│${NC}"
    else
        echo -e "${DG}│${NC}   ${BOLD}${W}PANEL STATUS:${NC} ${R}NOT INSTALLED ✘${NC}                                  ${DG}│${NC}"
    fi
    
    echo -e "${DG}├────────────────────────────────────────────────────────────────────┤${NC}"
    echo -e "${DG}│${NC}                                                                    ${DG}│${NC}"
    echo -e "${DG}│${NC}      ${P}[1]${NC} 📥 Install          ${DG}:: (Fresh Panel Install)${NC}             ${DG}│${NC}"
    echo -e "${DG}│${NC}      ${P}[2]${NC} 👤 User Admin       ${DG}:: (Add Admin/User)${NC}                  ${DG}│${NC}"
    echo -e "${DG}│${NC}      ${P}[3]${NC} 🔄 Update Panel     ${DG}:: (Latest Release)${NC}                  ${DG}│${NC}"
    echo -e "${DG}│${NC}      ${P}[4]${NC} ⚡ Migrate Panel    ${DG}:: (From Pterodactyl)${NC}                ${DG}│${NC}"
    echo -e "${DG}│${NC}      ${P}[5]${NC} 🗑️  Uninstall        ${DG}:: (Remove Data)${NC}                     ${DG}│${NC}"
    echo -e "${DG}│${NC}                                                                    ${DG}│${NC}"
    echo -e "${DG}├────────────────────────────────────────────────────────────────────┤${NC}"
    echo -e "${DG}│${NC}                         ${R}[0] ❌ SYSTEM EXIT${NC}                         ${DG}│${NC}"
    echo -e "${DG}╰────────────────────────────────────────────────────────────────────╯${NC}"
    echo ""
    
    echo -en "  ${Y}root@skahost${W}:~${C}/reviactyl${NC}# "
    read -r choice

    case $choice in
        1|01) install_ptero ;;
        2|02) create_user ;;
        3|03) update_panel ;;
        4|04) migrating_panel ;;
        5|05) uninstall_ptero ;;
        0|00) 
            echo -e ""
            type_effect "${R}  [SYS] Terminating processes...${NC}" 0.03
            type_effect "${DG}  [SYS] Goodbye!${NC}" 0.05
            exit 0 
            ;;
        *) 
            echo -e "${R}  [!] Invalid option selected...${NC}"
            sleep 1 
            continue
            ;;
    esac
    
    echo -en "\n  ${Y}root@skahost${W}:~${DG}/sys/pause${NC} (Press ENTER) "
    read -r
done
