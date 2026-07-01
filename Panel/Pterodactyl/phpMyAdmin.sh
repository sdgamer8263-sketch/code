#!/bin/bash
set -euo pipefail

# ==========================================
# SKA HOST MULTI-TOOL (PHPMYADMIN SETUP)
# STYLE: NEON CYBERPUNK + DOUBLE BORDERS
# BACKEND: NGINX + PHP-FPM + MARIADB
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
    local text="${C}  [SYS] Establishing secure connection to SKA HOST Database Core...${NC}"
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
    echo -e "${C}║${NC}                   ${Y}⚡ PHPMYADMIN INSTALLER ⚡${NC}                       ${C}║${NC}"
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
    echo -en "  ${Y}root@skahost${W}:~${C}/phpmyadmin${NC} ($label) [${W}$default${NC}]# "
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
ask "Panel Domain" "phpmyadmin.nobita.indevs.in" DOMAIN
ask "Admin Name"   "phpmyadmin" DB_NAME
ask "Admin User"   "phpmyadmin" DB_USER
ask "Admin Pass"   "phpmyadmin" DB_PASS

# --- FINAL VALIDATION ---
echo -e "\n      ${C}╭───────────── ${W}REVIEW CONFIGURATION ${C}─────────────╮${NC}"
echo -e "      ${C}│${NC} ${DG}Domain:${NC}   ${W}$DOMAIN"
echo -e "      ${C}│${NC} ${DG}Name:${NC}     ${W}$DB_NAME"
echo -e "      ${C}│${NC} ${DG}User:${NC}     ${W}$DB_USER"
echo -e "      ${C}│${NC} ${DG}Pass:${NC}     ${W}$DB_PASS"
echo -e "      ${C}╰──────────────────────────────────────────────────╯${NC}"

while true; do
    echo -en "\n  ${Y}root@skahost${W}:~${C}/phpmyadmin${NC} (Start Installation? y/N)# "
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

# --- OS DETECTION ---
echo -ne "  ${Y}● Detecting Operating System...${NC}\r"
source /etc/os-release
case "$ID" in
ubuntu|debian)
    echo -e "  ${G}✔️ OS Detected: ${W}$PRETTY_NAME${NC}                    "
    ;;
*)
    echo -e "  ${R}❌ Unsupported OS. Ubuntu/Debian required.${NC}"
    exit 1
    ;;
esac

# --- DEPENDENCIES ---
echo -ne "  ${Y}● Installing System Dependencies...${NC}\r"
apt update >/dev/null 2>&1
apt install -y wget tar nginx openssl php-fpm mariadb-server mariadb-client >/dev/null 2>&1
echo -e "  ${G}✔️ Dependencies installed.                         ${NC}"

# --- PHPMYADMIN INSTALLATION ---
echo -ne "  ${Y}● Downloading & Extracting phpMyAdmin...${NC}\r"
INSTALL_DIR="/var/www/phpmyadmin"
mkdir -p "$INSTALL_DIR/tmp"
cd "$INSTALL_DIR"

wget -qO phpMyAdmin.tar.gz https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-english.tar.gz
tar -xzf phpMyAdmin.tar.gz >/dev/null 2>&1
PMA_DIR=$(find . -maxdepth 1 -type d -name "phpMyAdmin-*-english" | head -n1)
mv "$PMA_DIR"/* . >/dev/null 2>&1
rm -rf "$PMA_DIR" phpMyAdmin.tar.gz

mkdir -p config
chmod o+rw config
cp config.sample.inc.php config/config.inc.php
chmod o+w config/config.inc.php

chown -R www-data:www-data *
chown -R www-data:www-data "$INSTALL_DIR"
chmod -R 755 "$INSTALL_DIR"
echo -e "  ${G}✔️ phpMyAdmin installed & configured.              ${NC}"

# --- DATABASE SETUP ---
echo -ne "  ${Y}● Configuring Database...${NC}\r"
mariadb -e "CREATE USER '${DB_USER}'@'127.0.0.1' IDENTIFIED BY '${DB_PASS}';" 2>/dev/null || true
mariadb -e "CREATE DATABASE ${DB_NAME};" 2>/dev/null || true
mariadb -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'127.0.0.1' WITH GRANT OPTION;" >/dev/null 2>&1
mariadb -e "FLUSH PRIVILEGES;" >/dev/null 2>&1
echo -e "  ${G}✔️ Database configured successfully.               ${NC}"

# --- SSL GENERATION ---
echo -ne "  ${Y}● Generating Self-Signed SSL Certificate...${NC}\r"
SSL_DIR="/etc/certs/phpMyAdmin"
mkdir -p "$SSL_DIR"
cd "$SSL_DIR"

openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 \
    -subj "/C=NA/ST=NA/L=NA/O=NA/CN=$DOMAIN" \
    -keyout privkey.pem -out fullchain.pem >/dev/null 2>&1
echo -e "  ${G}✔️ SSL Certificate generated.                      ${NC}"

# --- NGINX CONFIGURATION ---
echo -ne "  ${Y}● Configuring Nginx Server Block...${NC}\r"
PHP_SOCKET=$(find /run/php -name "php*-fpm.sock" | head -n1)

cat > /etc/nginx/sites-available/phpmyadmin.conf <<EOF
server {
    listen 80;
    server_name $DOMAIN;

    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name $DOMAIN;

    root $INSTALL_DIR;
    index index.php;

    client_max_body_size 100m;
    client_body_timeout 120s;

    sendfile off;

    ssl_certificate $SSL_DIR/fullchain.pem;
    ssl_certificate_key $SSL_DIR/privkey.pem;

    ssl_session_cache shared:SSL:10m;
    ssl_protocols TLSv1.2 TLSv1.3;

    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Robots-Tag none;
    add_header X-Frame-Options DENY;
    add_header Referrer-Policy same-origin;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:$PHP_SOCKET;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param PHP_VALUE "upload_max_filesize=100M\npost_max_size=100M";
        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
        fastcgi_intercept_errors off;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

ln -sf /etc/nginx/sites-available/phpmyadmin.conf /etc/nginx/sites-enabled/phpmyadmin.conf
nginx -t >/dev/null 2>&1
systemctl restart nginx >/dev/null 2>&1
echo -e "  ${G}✔️ Nginx configured and restarted.                 ${NC}"

# --- END REPORT ---
type_effect "\n${G}✅ phpMyAdmin Installation Complete!${NC}" 0.02

echo -e "\n${C}╔════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${C}║${NC}                   ${G}✅ DEPLOYMENT COMPLETE ✅${NC}                        ${C}║${NC}"
echo -e "${C}╠════════════════════════════════════════════════════════════════════╣${NC}"
echo -e "${C}║${NC}  ${DG}Panel URL :${NC} ${W}https://$DOMAIN${NC}"
echo -e "${C}║${NC}  ${DG}Database  :${NC} ${W}$DB_NAME${NC}"
echo -e "${C}║${NC}  ${DG}Username  :${NC} ${W}$DB_USER${NC}"
echo -e "${C}║${NC}  ${DG}Password  :${NC} ${W}$DB_PASS${NC}"
echo -e "${C}╚════════════════════════════════════════════════════════════════════╝${NC}"
echo -e "\n  ${G}Enjoy your new phpMyAdmin setup!${NC}"
echo -en "  ${Y}root@skahost${W}:~${DG}/sys/pause${NC} (Press ENTER to exit) "
read -r
echo ""
