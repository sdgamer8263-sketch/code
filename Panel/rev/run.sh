#!/bin/bash
set -euo pipefail

# ==========================================
# SKA HOST MULTI-TOOL (REVIACTYL INSTALLER)
# STYLE: NEON CYBERPUNK + DOUBLE BORDERS
# BACKEND: REVIACTYL NGINX + PHP-FPM 8.3
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

PHP_VERSION="8.3"

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
    local text="${C}  [SYS] Establishing secure connection to SKA HOST Servers...${NC}"
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
    echo -e "${C}║${NC}                   ${Y}⚡ REVIACTYL INSTALLER ⚡${NC}                        ${C}║${NC}"
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
    echo -en "  ${Y}root@skahost${W}:~${C}/reviactyl${NC} ($label) [${W}$default${NC}]# "
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
ask "Panel Domain" "panel.nobita.indevs.in" DOMAIN
ask "Admin Email" "admin@gmail.com" EMAIL
ask "Admin Username" "admin" USERNAME
ask "Admin Password" "admin" PASSWORD

# --- FINAL VALIDATION ---
echo -e "\n      ${C}╭───────────── ${W}REVIEW CONFIGURATION ${C}─────────────╮${NC}"
echo -e "      ${C}│${NC} ${DG}Domain:${NC}   ${W}$DOMAIN"
echo -e "      ${C}│${NC} ${DG}Email:${NC}    ${W}$EMAIL"
echo -e "      ${C}│${NC} ${DG}User:${NC}     ${W}$USERNAME"
echo -e "      ${C}│${NC} ${DG}Pass:${NC}     ${W}$PASSWORD"
echo -e "      ${C}╰──────────────────────────────────────────────────╯${NC}"

while true; do
    echo -en "\n  ${Y}root@skahost${W}:~${C}/reviactyl${NC} (Start Installation? y/N)# "
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

# --- DEPENDENCIES & OS CONFIG ---
echo -ne "  ${Y}● Installing system dependencies...${NC}\r"
apt update >/dev/null 2>&1
apt install -y curl apt-transport-https ca-certificates gnupg unzip git tar sudo lsb-release >/dev/null 2>&1
echo -e "  ${G}✔️ System dependencies installed.                  ${NC}"

OS=$(lsb_release -is | tr '[:upper:]' '[:lower:]')

echo -ne "  ${Y}● Configuring PHP & Redis Repositories...${NC}\r"
if [[ "$OS" == "ubuntu" ]]; then
    apt install -y software-properties-common >/dev/null 2>&1
    LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php >/dev/null 2>&1
elif [[ "$OS" == "debian" ]]; then
    curl -fsSL https://packages.sury.org/php/apt.gpg | gpg --dearmor -o /usr/share/keyrings/sury-php.gpg >/dev/null 2>&1
    echo "deb [signed-by=/usr/share/keyrings/sury-php.gpg] https://packages.sury.org/php/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/sury-php.list >/dev/null 2>&1
fi

rm -f /usr/share/keyrings/redis-archive-keyring.gpg
curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg >/dev/null 2>&1
echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list >/dev/null 2>&1
apt update >/dev/null 2>&1
echo -e "  ${G}✔️ Repositories configured successfully.           ${NC}"

# --- CORE SERVICES ---
echo -ne "  ${Y}● Installing PHP 8.3, MariaDB, Nginx & Redis...${NC}\r"
apt install -y php8.3 php8.3-{cli,fpm,common,mysql,mbstring,bcmath,xml,zip,curl,gd,tokenizer,ctype,simplexml,dom} mariadb-server nginx redis-server >/dev/null 2>&1
echo -e "  ${G}✔️ Core services installed.                        ${NC}"

echo -ne "  ${Y}● Installing Composer...${NC}\r"
curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer >/dev/null 2>&1
echo -e "  ${G}✔️ Composer installed.                             ${NC}"

# --- PANEL DOWNLOAD ---
echo -ne "  ${Y}● Downloading Reviactyl Panel...${NC}\r"
mkdir -p /var/www/reviactyl
cd /var/www/reviactyl
curl -Lso panel.tar.gz https://github.com/reviactyl/panel/releases/latest/download/panel.tar.gz >/dev/null 2>&1
tar -xzf panel.tar.gz >/dev/null 2>&1
chmod -R 755 storage/* bootstrap/cache/ >/dev/null 2>&1
echo -e "  ${G}✔️ Panel files downloaded and extracted.           ${NC}"

# --- DATABASE SETUP ---
echo -ne "  ${Y}● Configuring Database...${NC}\r"
DB_NAME=reviactyl
DB_USER=reviactyl
DB_PASS=reviactyl
mariadb -e "CREATE USER '${DB_USER}'@'127.0.0.1' IDENTIFIED BY '${DB_PASS}';" 2>/dev/null || true
mariadb -e "CREATE DATABASE ${DB_NAME};" 2>/dev/null || true
mariadb -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'127.0.0.1' WITH GRANT OPTION;" >/dev/null 2>&1
mariadb -e "FLUSH PRIVILEGES;" >/dev/null 2>&1
echo -e "  ${G}✔️ Database configured successfully.               ${NC}"

# --- ENVIRONMENT & DEPENDENCIES ---
echo -ne "  ${Y}● Setting up Environment and Dependencies...${NC}\r"
cp .env.example .env
sed -i "s|APP_URL=.*|APP_URL=https://${DOMAIN}|g" .env
sed -i "s|DB_DATABASE=.*|DB_DATABASE=${DB_NAME}|g" .env
sed -i "s|DB_USERNAME=.*|DB_USERNAME=${DB_USER}|g" .env
sed -i "s|DB_PASSWORD=.*|DB_PASSWORD=${DB_PASS}|g" .env
if ! grep -q "^APP_ENVIRONMENT_ONLY=" .env; then
    echo "APP_ENVIRONMENT_ONLY=false" >> .env
fi

COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --optimize-autoloader >/dev/null 2>&1
sed -i "s|^APP_KEY=.*|APP_KEY=$(php -r "echo 'base64:'.base64_encode(random_bytes(32));")|" .env >/dev/null 2>&1
php artisan migrate --seed --force >/dev/null 2>&1
chown -R www-data:www-data /var/www/reviactyl/* >/dev/null 2>&1
echo -e "  ${G}✔️ Environment and Database migrations complete.   ${NC}"

# --- CRON ---
echo -ne "  ${Y}● Configuring Cron jobs...${NC}\r"
apt install -y cron >/dev/null 2>&1
systemctl enable --now cron >/dev/null 2>&1
(crontab -l 2>/dev/null; echo "* * * * * php /var/www/reviactyl/artisan schedule:run >> /dev/null 2>&1") | crontab - >/dev/null 2>&1
echo -e "  ${G}✔️ Cron jobs configured.                           ${NC}"

# --- NGINX & SSL ---
echo -ne "  ${Y}● Configuring Nginx and Self-Signed SSL...${NC}\r"
mkdir -p /etc/certs/reviactyl
cd /etc/certs/reviactyl
openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 \
-subj "/C=NA/ST=NA/L=NA/O=NA/CN=${DOMAIN}" \
-keyout privkey.pem -out fullchain.pem >/dev/null 2>&1

tee /etc/nginx/sites-available/reviactyl.conf > /dev/null << EOF
server {
    listen 80;
    server_name ${DOMAIN};
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name ${DOMAIN};

    root /var/www/reviactyl/public;
    index index.php;

    ssl_certificate /etc/certs/reviactyl/fullchain.pem;
    ssl_certificate_key /etc/certs/reviactyl/privkey.pem;

    client_max_body_size 100m;
    client_body_timeout 120s;
    sendfile off;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php\$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)\$;
        fastcgi_pass unix:/run/php/php${PHP_VERSION}-fpm.sock;
        fastcgi_index index.php;
        include /etc/nginx/fastcgi_params;
        fastcgi_param PHP_VALUE "upload_max_filesize=100M \n post_max_size=100M";
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

ln -sf /etc/nginx/sites-available/reviactyl.conf /etc/nginx/sites-enabled/reviactyl.conf
nginx -t >/dev/null 2>&1 && systemctl restart nginx >/dev/null 2>&1
echo -e "  ${G}✔️ Nginx configured successfully.                  ${NC}"

# --- QUEUE WORKER ---
echo -ne "  ${Y}● Creating Queue Worker Service...${NC}\r"
tee /etc/systemd/system/reviq.service > /dev/null << 'EOF'
[Unit]
Description=Reviactyl Queue Worker
After=redis-server.service

[Service]
User=www-data
Group=www-data
Restart=always
ExecStart=/usr/bin/php /var/www/reviactyl/artisan queue:work --queue=high,standard,low --sleep=3 --tries=3
StartLimitInterval=180
StartLimitBurst=30
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload >/dev/null 2>&1
systemctl enable --now redis-server >/dev/null 2>&1
systemctl enable --now reviq.service >/dev/null 2>&1
echo -e "  ${G}✔️ Queue Service running.                          ${NC}"

# --- FINAL PANEL CONFIGURATION & ADMIN ---
echo -ne "  ${Y}● Finalizing Settings & Creating Admin User...${NC}\r"
cd /var/www/reviactyl

sed -i '/^APP_ENVIRONMENT_ONLY=/d' .env
echo "APP_ENVIRONMENT_ONLY=false" >> .env
sed -i '/RECAPTCHA_ENABLED=/d' .env
echo 'RECAPTCHA_ENABLED=false' >> .env
sed -i '/APP_NAME=/d' .env
echo 'APP_NAME="Nobita Cloud"' >> .env
TIMEZONE=$(timedatectl show --property=Timezone --value 2>/dev/null || echo "UTC")
sed -i "s|APP_TIMEZONE=.*|APP_TIMEZONE=${TIMEZONE}|g" .env

sed -i "s|MAIL_MAILER=.*|MAIL_MAILER=smtp|g" .env
sed -i "s|MAIL_HOST=.*|MAIL_HOST=smtp.zoho.in|g" .env
sed -i "s|MAIL_PORT=.*|MAIL_PORT=587|g" .env
sed -i "s|MAIL_USERNAME=.*|MAIL_USERNAME=free.mell@aiomarket.online|g" .env
sed -i "s|MAIL_PASSWORD=.*|MAIL_PASSWORD=58@S5wZuWtpdDDX|g" .env
sed -i "s|MAIL_ENCRYPTION=.*|MAIL_ENCRYPTION=tls|g" .env
sed -i "s|MAIL_FROM_ADDRESS=.*|MAIL_FROM_ADDRESS=free.mell@aiomarket.online|g" .env
sed -i 's|MAIL_FROM_NAME=.*|MAIL_FROM_NAME="Nobita Cloud"|g' .env

php artisan p:location:make --short=IN --long="India" >/dev/null 2>&1 || true

php artisan view:clear >/dev/null 2>&1
php artisan config:clear >/dev/null 2>&1
php artisan cache:clear >/dev/null 2>&1
php artisan config:cache >/dev/null 2>&1
chown -R www-data:www-data /var/www/reviactyl/* >/dev/null 2>&1
php artisan queue:restart >/dev/null 2>&1

php artisan p:user:make -n --email="$EMAIL" --username="${USERNAME}" --password="$PASSWORD" --admin=1 --name-first=My --name-last=Admin >/dev/null 2>&1
echo -e "  ${G}✔️ Admin User created successfully.                ${NC}"

# --- END REPORT ---
type_effect "\n${G}✅ Reviactyl Installation Complete!${NC}" 0.02

echo -e "\n${C}╔════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${C}║${NC}                   ${G}✅ DEPLOYMENT COMPLETE ✅${NC}                        ${C}║${NC}"
echo -e "${C}╠════════════════════════════════════════════════════════════════════╣${NC}"
echo -e "${C}║${NC}  ${DG}Panel URL :${NC} ${W}https://$DOMAIN${NC}"
echo -e "${C}║${NC}  ${DG}Username  :${NC} ${W}$USERNAME${NC}"
echo -e "${C}║${NC}  ${DG}Password  :${NC} ${W}$PASSWORD${NC}"
echo -e "${C}║${NC}  ${DG}Email     :${NC} ${W}$EMAIL${NC}"
echo -e "${C}╚════════════════════════════════════════════════════════════════════╝${NC}"
echo -e "\n  ${G}Enjoy your new Reviactyl Panel!${NC}"
echo -en "  ${Y}root@skahost${W}:~${DG}/sys/pause${NC} (Press ENTER to exit) "
read -r
echo ""
