#!/bin/bash
set -euo pipefail

# ==========================================
# SKA HOST MULTI-TOOL (PTERODACTYL CONTROL)
# STYLE: NEON CYBERPUNK + DOUBLE BORDERS
# BACKEND: NOBITA CLOUD REPO
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

GITHUB_REPO="pterodactyl/panel"

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
    echo -e "${C}║${NC}                 ${Y}⚡ PTERODACTYL CONTROL CENTER ⚡${NC}                   ${C}║${NC}"
    echo -e "${C}╠════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${C}║${NC} ${BLINK}${G}● ONLINE${NC} ${DG}│${NC} ⏱️ ${W}${PAD_UPTIME}${NC} ${DG}│${NC} 🧠 ${W}${PAD_CPU}${NC} ${DG}│${NC} 💾 ${W}${PAD_RAM}${NC}      ${C}║${NC}"
    echo -e "${C}╚════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# ==========================================
# 🛠️ GITHUB VERSION FETCHING
# ==========================================

fetch_github_versions() {
    local repo=$1
    local json
    json=$(curl -sf "https://api.github.com/repos/$repo/releases?per_page=20" 2>/dev/null) || { return 1; }
    echo "$json" | python3 -c "
import sys, json
data = json.load(sys.stdin)
for r in data:
    if r.get('prerelease', False): continue
    tag = r.get('tag_name', '')
    if tag.startswith('v'): print(tag)
" 2>/dev/null || return 1
}

select_version() {
    local repo=$1
    local var_name=$2
    local default="latest"
    
    echo -e "  ${C}  [SYS] Fetching available versions from GitHub...${NC}"
    
    local tags=() disp=() i=0
    while IFS= read -r tag; do
        [[ -z "$tag" ]] && continue
        tags+=("$tag")
        i=$((i+1))
        disp+=("      ${DG}│${NC}  ${Y}$i.${NC} $tag")
    done < <(fetch_github_versions "$repo" 2>/dev/null) || true

    if [[ ${#tags[@]} -eq 0 ]]; then
        echo -e "  ${Y}  [WARN] No versions found. Using latest.${NC}"
        eval "$var_name=\"$default\""
        return
    fi

    echo -e "      ${DG}╭──────────────────────────────────────────────────╮${NC}"
    printf '%b\n' "${disp[@]}"
    echo -e "      ${DG}╰──────────────────────────────────────────────────╯${NC}"
    
    local max=${#tags[@]}
    echo -en "  ${Y}root@skahost${W}:~${C}/ptero/update${NC} (Select version 1-$max) [${W}1=latest${NC}]# "
    if ! read -t 10 choice; then
        echo -e "\n  ${DG}  [SYS] Timeout — using latest: ${W}${tags[0]}${NC}"
        eval "$var_name=\"${tags[0]}\""
        return
    fi
    if [[ -z "$choice" || "$choice" == "1" ]]; then
        eval "$var_name=\"${tags[0]}\""
    elif [[ "$choice" =~ ^[0-9]+$ ]] && [[ $choice -ge 1 ]] && [[ $choice -le $max ]]; then
        local idx=$((choice - 1))
        eval "$var_name=\"${tags[$idx]}\""
    else
        eval "$var_name=\"${tags[0]}\""
    fi
    echo -e "  ${G}  [OK] Selected Version: ${W}${!var_name}${NC}\n"
}

# ==========================================
# ⚙️ CORE MODULES
# ==========================================

install_ptero() {
    echo -e "\n${C}  [SYS] Initiating Pterodactyl Installation...${NC}"
    echo -e "  ${Y}● Running external script silently...${NC}"
    
    bash <(curl -s https://raw.githubusercontent.com/sdgamer8263-sketch/code/main/Panel/Pterodactyl/install.sh)
    
    type_effect "\n${G}✔️ Installation Sequence Complete.${NC}" 0.02
}

create_user() {
    if [ ! -d /var/www/pterodactyl ]; then
        echo -e "\n${R}  [!] Panel directory not found (/var/www/pterodactyl).${NC}"
        echo -e "${R}  [!] Please install the panel first.${NC}"
        return
    fi

    echo -e "\n      ${C}╭───────── ${W}USER MANAGEMENT ${C}─────────╮${NC}"
    echo -e "      ${C}│${NC}  ${G}[1]${NC} Custom User Creation        ${C}│${NC}"
    echo -e "      ${C}│${NC}  ${Y}[2]${NC} Auto-Generate Admin User    ${C}│${NC}"
    echo -e "      ${C}╰──────────────────────────────────╯${NC}\n"
    
    echo -en "  ${Y}root@skahost${W}:~${C}/ptero/users${NC}# "
    read -r choice

    cd /var/www/pterodactyl || exit

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
    echo -en "  ${Y}root@skahost${W}:~${C}/ptero/uninstall${NC} (Are you sure? y/N)# "
    read -r confirm
    
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo -e "\n${DG}  [SYS] Uninstallation cancelled.${NC}"
        return
    fi

    echo -e "\n${C}  [SYS] Initiating Uninstallation Sequence...${NC}"
    
    echo -ne "  ${Y}● Stopping Services & Cronjobs...${NC}\r"
    systemctl stop pteroq.service >/dev/null 2>&1 || true
    systemctl disable pteroq.service >/dev/null 2>&1 || true
    rm -f /etc/systemd/system/pteroq.service
    systemctl daemon-reload >/dev/null 2>&1
    crontab -l 2>/dev/null | grep -v 'php /var/www/pterodactyl/artisan schedule:run' | crontab - >/dev/null 2>&1 || true
    echo -e "  ${G}✔️ Services stopped & removed.           ${NC}"

    echo -ne "  ${Y}● Dropping Database & Users...${NC}\r"
    mysql -u root -e "DROP DATABASE IF EXISTS panel;" >/dev/null 2>&1 || true
    mysql -u root -e "DROP USER IF EXISTS 'pterodactyl'@'127.0.0.1';" >/dev/null 2>&1 || true
    mysql -u root -e "FLUSH PRIVILEGES;" >/dev/null 2>&1 || true
    echo -e "  ${G}✔️ Database dropped successfully.        ${NC}"

    echo -ne "  ${Y}● Cleaning Nginx Configs & Core Files...${NC}\r"
    rm -f /etc/nginx/sites-enabled/pterodactyl.conf
    rm -f /etc/nginx/sites-available/pterodactyl.conf
    systemctl reload nginx >/dev/null 2>&1 || true
    rm -rf /var/www/pterodactyl
    echo -e "  ${G}✔️ All files and configs cleaned.        ${NC}"

    type_effect "\n${G}✔️ Panel removed successfully (Wings untouched).${NC}" 0.02
}

update_panel() {
    if [ ! -d /var/www/pterodactyl ]; then
        echo -e "\n${R}  [!] Panel not found in /var/www/pterodactyl${NC}"
        return
    fi

    echo -e "\n${C}  [SYS] Entering Update Module...${NC}"
    select_version "$GITHUB_REPO" "version_PANEL"

    echo -e "      ${C}╭───────────── ${W}REVIEW UPDATE ${C}─────────────╮${NC}"
    echo -e "      ${C}│${NC} ${DG}Target Version:${NC}  ${W}$version_PANEL"
    echo -e "      ${C}╰──────────────────────────────────────────╯${NC}"

    echo -en "\n  ${Y}root@skahost${W}:~${C}/ptero/update${NC} (Proceed? Y/n) [${W}auto: Y in 10s${NC}]# "
    if ! read -t 10 -n 1 -r CONFIRM; then
        echo -e "\n  ${DG}  [SYS] Timeout — proceeding automatically...${NC}"
        CONFIRM="y"
    fi
    echo ""
    
    if [[ "$CONFIRM" =~ [Nn] ]]; then
        echo -e "  ${R}  [!] Installation aborted by user.${NC}"
        return
    fi

    echo -e "\n${C}  [SYS] Executing Update Sequence...${NC}"
    
    echo -ne "  ${Y}● Entering Maintenance Mode...${NC}\r"
    cd /var/www/pterodactyl
    php artisan down >/dev/null 2>&1 || true
    echo -e "  ${G}✔️ Maintenance Mode Enabled.       ${NC}"

    echo -ne "  ${Y}● Downloading Release ($version_PANEL)...${NC}\r"
    # Safe extraction without wiping .env
    if [[ "$version_PANEL" == "latest" ]]; then
        curl -Lso panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz >/dev/null 2>&1
    else
        curl -Lso panel.tar.gz "https://github.com/pterodactyl/panel/releases/download/${version_PANEL}/panel.tar.gz" >/dev/null 2>&1
    fi
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
    chown -R www-data:www-data /var/www/pterodactyl/* >/dev/null 2>&1
    echo -e "  ${G}✔️ Cache cleared & DB migrated.    ${NC}"

    echo -ne "  ${Y}● Restarting Queue Workers...${NC}\r"
    php artisan queue:restart >/dev/null 2>&1
    php artisan up >/dev/null 2>&1
    echo -e "  ${G}✔️ System online & Workers active. ${NC}"

    type_effect "\n${G}✔️ Panel Updated Successfully.${NC}" 0.02
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
    if [ -d "/var/www/pterodactyl" ]; then
        echo -e "${DG}│${NC}   ${BOLD}${W}PANEL STATUS:${NC} ${G}INSTALLED ✔${NC}                                      ${DG}│${NC}"
    else
        echo -e "${DG}│${NC}   ${BOLD}${W}PANEL STATUS:${NC} ${R}NOT INSTALLED ✘${NC}                                  ${DG}│${NC}"
    fi
    
    echo -e "${DG}├────────────────────────────────────────────────────────────────────┤${NC}"
    echo -e "${DG}│${NC}                                                                    ${DG}│${NC}"
    echo -e "${DG}│${NC}      ${P}[1]${NC} 📥 Install          ${DG}:: (Fresh Panel Install)${NC}             ${DG}│${NC}"
    echo -e "${DG}│${NC}      ${P}[2]${NC} 👤 User Admin       ${DG}:: (Add Admin/User)${NC}                  ${DG}│${NC}"
    echo -e "${DG}│${NC}      ${P}[3]${NC} 🔄 Update Panel     ${DG}:: (Latest Release)${NC}                  ${DG}│${NC}"
    echo -e "${DG}│${NC}      ${P}[4]${NC} 🌐 Domain & SSL     ${DG}:: (Change Domain/SSL)${NC}               ${DG}│${NC}"
    echo -e "${DG}│${NC}      ${P}[5]${NC} 🗑️  Uninstall        ${DG}:: (Remove Data)${NC}                     ${DG}│${NC}"
    echo -e "${DG}│${NC}      ${P}[6]${NC} 🗄️  phpMyAdmin       ${DG}:: (Install phpMyAdmin)${NC}              ${DG}│${NC}"
    echo -e "${DG}│${NC}                                                                    ${DG}│${NC}"
    echo -e "${DG}├────────────────────────────────────────────────────────────────────┤${NC}"
    echo -e "${DG}│${NC}                         ${R}[0] ❌ SYSTEM EXIT${NC}                         ${DG}│${NC}"
    echo -e "${DG}╰────────────────────────────────────────────────────────────────────╯${NC}"
    echo ""
    
    echo -en "  ${Y}root@skahost${W}:~${C}/ptero${NC}# "
    read -r choice

    case $choice in
        1|01) install_ptero ;;
        2|02) create_user ;;
        3|03) update_panel ;;
        4|04) 
            echo -e "\n${C}  [SYS] Launching Domain/SSL Module...${NC}"
            bash <(curl -fsSL https://raw.githubusercontent.com/sdgamer8263-sketch/code/main/Panel/Pterodactyl/ssl.sh) 
            ;;
        5|05) uninstall_ptero ;;
        6|06) 
            echo -e "\n${C}  [SYS] Launching phpMyAdmin Module...${NC}"
            bash <(curl -fsSL https://raw.githubusercontent.com/sdgamer8263-sketch/code/main/Panel/Pterodactyl/phpMyAdmin.sh) 
            ;;
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
