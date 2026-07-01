#!/bin/bash
set -euo pipefail

# ==========================================
# SKA HOST MULTI-TOOL (WHMCS INSTALLER)
# STYLE: NEON CYBERPUNK + DOUBLE BORDERS
# BACKEND: NGINX + PHP 8.4 + IONCUBE
# ==========================================

export DEBIAN_FRONTEND=noninteractive

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
    local text="${C}  [SYS] Establishing secure connection to SKA HOST Billing Engine...${NC}"
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
    echo -e "${C}║${NC}                   ${Y}⚡ WHMCS BILLING INSTALLER ⚡${NC}                    ${C}║${NC}"
    echo -e "${C}╠════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${C}║${NC} ${BLINK}${G}● ONLINE${NC} ${DG}│${NC} ⏱️ ${W}${PAD_UPTIME}${NC} ${DG}│${NC} 🧠 ${W}${PAD_CPU}${NC} ${DG}│${NC} 💾 ${W}${PAD_RAM}${NC}      ${C}║${NC}"
    echo -e "${C}╚════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# ==========================================
# 🛠️ INTERACTIVE PROMPTS
# ==========================================

ask() {
    local label=$1
    local default=$2
    local var_name=$3
    echo -en "  ${Y}root@skahost${W}:~${C}/whmcs${NC} ($label) [${W}$default${NC}]# "
    read input
    if [ -z "$input" ]; then
        eval "$var_name=\"$default\""
    else
        eval "$var_name=\"$input\""
    fi
}

# ==========================================
# ⚙️ MAIN INSTALLATION LOGIC
# ==========================================

boot_sequence
show_dashboard

# --- DATA COLLECTION ---
ask "Billing Domain" "billing.example.com" DOMAIN
ask "Admin Email" "admin@example.com" ADMIN_EMAIL
ask "Admin Username" "admin" ADMIN_USER
ask "Admin Password" "SecurePass123" ADMIN_PASS
ask "Database Password" "DBPass123" DB_PASS

WEBROOT="/var/www/whmcs"
DB_HOST="localhost"
DB_NAME="whmcs"
DB_USER="whmcsuser"

# --- FINAL VALIDATION ---
echo -e "\n      ${C}╭───────────── ${W}REVIEW CONFIGURATION ${C}─────────────╮${NC}"
echo -e "      ${C}│${NC} ${DG}Domain:${NC}   ${W}$DOMAIN"
echo -e "      ${C}│${NC} ${DG}Email:${NC}    ${W}$ADMIN_EMAIL"
echo -e "      ${C}│${NC} ${DG}Admin:${NC}    ${W}$ADMIN_USER"
echo -e "      ${C}│${NC} ${DG}DB Name:${NC}  ${W}$DB_NAME"
echo -e "      ${C}╰──────────────────────────────────────────────────╯${NC}"

while true; do
    echo -en "\n  ${Y}root@skahost${W}:~${C}/whmcs${NC} (Start Installation? y/N)# "
    read -n 1 -r CONFIRM
    echo ""

    case $CONFIRM in
        [Yy]* )
            echo -e "\n${C}  [SYS] Proceeding to deployment...${NC}"
            break
            ;;
        [Nn]* )
            echo -e "\n${R}  [!] Installation aborted by user.${NC}"
            exit
            ;;
        * )
            echo -e "  ${R}  [!] Invalid input. Enter y or n.${NC}"
            ;;
    esac
done

# --- DEPENDENCIES & PACKAGES ---
echo -ne "  ${Y}● Installing system dependencies...${NC}\r"
apt update -y >/dev/null 2>&1
apt install -y wget curl unzip openssl ca-certificates >/dev/null 2>&1
echo -e "  ${G}✔️ System dependencies installed.                  ${NC}"

echo -ne "  ${Y}● Installing Nginx, MariaDB & PHP 8.4...${NC}\r"
apt install -y nginx mariadb-server php8.4 php8.4-fpm php8.4-cli php8.4-common php8.4-mysql php8.4-curl php8.4-xml php8.4-mbstring php8.4-gd php8.4-zip php8.4-intl php8.4-bcmath php8.4-soap >/dev/null 2>&1

systemctl enable nginx mariadb php8.4-fpm >/dev/null 2>&1
systemctl restart nginx mariadb php8.4-fpm >/dev/null 2>&1
echo -e "  ${G}✔️ Web server & PHP 8.4 configured.                ${NC}"

# --- IONCUBE LOADER ---
echo -ne "  ${Y}● Installing ionCube Loader...${NC}\r"
PHP_EXT_DIR=$(php8.4 -i 2>/dev/null | grep "^extension_dir" | awk '{print $NF}')
wget -q -O /tmp/ioncube.tar.gz "https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz"
tar xzf /tmp/ioncube.tar.gz -C /tmp >/dev/null 2>&1
cp "/tmp/ioncube/ioncube_loader_lin_8.4.so" "$PHP_EXT_DIR/" >/dev/null 2>&1
echo "zend_extension=ioncube_loader_lin_8.4.so" > /etc/php/8.4/mods-available/ioncube.ini
phpenmod -v 8.4 ioncube >/dev/null 2>&1
mv /etc/php/8.4/fpm/conf.d/20-ioncube.ini /etc/php/8.4/fpm/conf.d/00-ioncube.ini >/dev/null 2>&1 || true
mv /etc/php/8.4/cli/conf.d/20-ioncube.ini /etc/php/8.4/cli/conf.d/00-ioncube.ini >/dev/null 2>&1 || true
systemctl restart php8.4-fpm >/dev/null 2>&1
rm -rf /tmp/ioncube /tmp/ioncube.tar.gz
echo -e "  ${G}✔️ ionCube Loader installed successfully.          ${NC}"

# --- DATABASE SETUP ---
echo -ne "  ${Y}● Configuring Database...${NC}\r"
mariadb -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME};" >/dev/null 2>&1
mariadb -e "CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';" >/dev/null 2>&1
mariadb -e "CREATE USER IF NOT EXISTS '${DB_USER}'@'127.0.0.1' IDENTIFIED BY '${DB_PASS}';" >/dev/null 2>&1
mariadb -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';" >/dev/null 2>&1
mariadb -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'127.0.0.1';" >/dev/null 2>&1
mariadb -e "FLUSH PRIVILEGES;" >/dev/null 2>&1
echo -e "  ${G}✔️ Database configured successfully.               ${NC}"

# --- WHMCS DOWNLOAD ---
echo -ne "  ${Y}● Downloading WHMCS Core Files...${NC}\r"
mkdir -p "$WEBROOT"
wget -q -O /tmp/whmcs.zip "https://files.catbox.moe/2ba11q.zip"
unzip -o -q /tmp/whmcs.zip -d "$WEBROOT" >/dev/null 2>&1
rm -f /tmp/whmcs.zip
echo -e "  ${G}✔️ WHMCS files downloaded & extracted.             ${NC}"

echo -ne "  ${Y}● Setting File Permissions...${NC}\r"
chown -R www-data:www-data "$WEBROOT" >/dev/null 2>&1
find "$WEBROOT" -type d -exec chmod 755 {} \; >/dev/null 2>&1
find "$WEBROOT" -type f -exec chmod 644 {} \; >/dev/null 2>&1
echo -e "  ${G}✔️ File permissions set.                           ${NC}"

# --- CRONTAB ---
echo -ne "  ${Y}● Configuring Cron jobs...${NC}\r"
(crontab -l 2>/dev/null | grep -v "/var/www/whmcs/crons/cron.php"; echo "*/5 * * * * /usr/bin/php -q /var/www/whmcs/crons/cron.php") | crontab - >/dev/null 2>&1
echo -e "  ${G}✔️ Cron jobs configured.                           ${NC}"

# --- NGINX CONFIGURATION ---
echo -ne "  ${Y}● Configuring Nginx Server Block...${NC}\r"
cat > /etc/nginx/sites-available/whmcs <<EOF
server {
    listen 80;
    server_name $DOMAIN;

    root $WEBROOT;
    index index.php index.html;

    client_max_body_size 100M;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php8.4-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

ln -sf /etc/nginx/sites-available/whmcs /etc/nginx/sites-enabled/whmcs >/dev/null 2>&1
rm -f /etc/nginx/sites-enabled/default >/dev/null 2>&1

nginx -t >/dev/null 2>&1 && systemctl restart nginx >/dev/null 2>&1
echo -e "  ${G}✔️ Nginx configured successfully.                  ${NC}"

CC_HASH=$(openssl rand -base64 128 | tr -d '\n\/+=' | cut -c 1-64)
IP=$(hostname -I | awk '{print $1}')

# --- END REPORT ---
type_effect "\n${G}✅ WHMCS Setup Complete!${NC}" 0.02

echo -e "\n${C}╔════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${C}║${NC}                   ${G}✅ DEPLOYMENT COMPLETE ✅${NC}                        ${C}║${NC}"
echo -e "${C}╠════════════════════════════════════════════════════════════════════╣${NC}"
echo -e "${C}║${NC}  ${DG}Panel URL  :${NC} ${W}http://$DOMAIN${NC}"
echo -e "${C}║${NC}  ${DG}Fallback   :${NC} ${W}http://$IP${NC}"
echo -e "${C}║${NC}"
echo -e "${C}║${NC}  ${DG}Admin User :${NC} ${W}$ADMIN_USER${NC}"
echo -e "${C}║${NC}  ${DG}Admin Pass :${NC} ${W}$ADMIN_PASS${NC}"
echo -e "${C}║${NC}  ${DG}Admin Mail :${NC} ${W}$ADMIN_EMAIL${NC}"
echo -e "${C}║${NC}"
echo -e "${C}║${NC}  ${DG}DB Name    :${NC} ${W}$DB_NAME${NC}"
echo -e "${C}║${NC}  ${DG}DB User    :${NC} ${W}$DB_USER${NC}"
echo -e "${C}║${NC}  ${DG}DB Pass    :${NC} ${W}$DB_PASS${NC}"
echo -e "${C}╚════════════════════════════════════════════════════════════════════╝${NC}"
echo -e "\n  ${G}Please visit your Domain/IP to complete the WHMCS Web Installation!${NC}"
echo -en "  ${Y}root@skahost${W}:~${DG}/sys/pause${NC} (Press ENTER to exit) "
read -r
echo ""
