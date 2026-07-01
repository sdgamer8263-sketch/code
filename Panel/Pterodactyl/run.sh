#!/bin/bash

# ==========================================
# SKA HOST MULTI-TOOL (PTERODACTYL PANEL)
# STYLE: NEON CYBERPUNK + DOUBLE BORDERS
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

GITHUB_REPO="pterodactyl/panel"
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
    echo -e "${C}║${NC}               ${Y}⚡ PTERODACTYL PANEL INSTALLER ⚡${NC}                    ${C}║${NC}"
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
    echo -en "  ${Y}root@skahost${W}:~${C}/pterodactyl${NC} ($label) [${W}$default${NC}]# "
    read input
    if [ -z "$input" ]; then
        eval "$var_name=\"$default\""
    else
        eval "$var_name=\"$input\""
    fi
}

ask_timeout() {
    local label=$1
    local default=$2
    local var_name=$3
    echo -en "  ${Y}root@skahost${W}:~${C}/pterodactyl${NC} ($label) [${W}$default${NC}]# "
    if ! read -t 10 input; then
        echo -e "\n  ${DG}  [SYS] Timeout — using default: ${W}$default${NC}"
        eval "$var_name=\"$default\""
        return
    fi
    if [ -z "$input" ]; then
        eval "$var_name=\"$default\""
    else
        eval "$var_name=\"$input\""
    fi
}

fetch_github_versions() {
    local repo=$1
    local json
    json=$(curl -sf "https://api.github.com/repos/$repo/releases?per_page=20" 2>/dev/null) || {
        return 1
    }
    echo "$json" | python3 -c "
import sys, json
data = json.load(sys.stdin)
for r in data:
    if r.get('prerelease', False):
        continue
    tag = r.get('tag_name', '')
    if tag.startswith('v'):
        print(tag)
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
    echo -en "  ${Y}root@skahost${W}:~${C}/pterodactyl${NC} (Select version 1-$max) [${W}1=latest${NC}]# "
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
# ⚙️ MAIN INSTALLATION LOGIC
# ==========================================

boot_sequence
show_dashboard

# --- DATA COLLECTION ---
ask "Panel Domain" "panel.skahost.in" DOMAIN
ask "Admin Email" "admin@gmail.com" EMAIL
ask "Admin Username" "admin" USERNAME
ask_timeout "Admin Password" "admin" PASSWORD
select_version "$GITHUB_REPO" "version_PANEL"

# --- FINAL VALIDATION ---
echo -e "      ${C}╭───────────── ${W}REVIEW CONFIGURATION ${C}─────────────╮${NC}"
echo -e "      ${C}│${NC} ${DG}Domain:${NC}   ${W}$DOMAIN"
echo -e "      ${C}│${NC} ${DG}Email:${NC}    ${W}$EMAIL"
echo -e "      ${C}│${NC} ${DG}User:${NC}     ${W}$USERNAME"
echo -e "      ${C}│${NC} ${DG}Version:${NC}  ${W}$version_PANEL"
echo -e "      ${C}╰──────────────────────────────────────────────────╯${NC}"

while true; do
    echo -en "  ${Y}root@skahost${W}:~${C}/pterodactyl${NC} (Start Installation? y/N)# "
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
apt install -y curl apt-transport-https ca-certificates gnupg unzip git tar sudo lsb-release python3 >/dev/null 2>&1
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
curl -fsSL https://packages.redis.io/gpg | gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg >/dev/null 2>&1
echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/redis.list >/dev/null 2>&1
apt update >/dev/null 2>&1
echo -e "  ${G}✔️ Repositories configured successfully.           ${NC}"

# --- CORE SERVICES ---
echo -ne "  ${Y}● Installing PHP, MariaDB, Nginx & Redis...${NC}\r"
apt install -y php${PHP_VERSION} php${PHP_VERSION}-{cli,fpm,common,mysql,mbstring,bcmath,xml,zip,curl,gd,tokenizer,ctype,simplexml,dom} mariadb-server nginx redis-server >/dev/null 2>&1
echo -e "  ${G}✔️ Core services installed.                        ${NC}"

echo -ne "  ${Y}● Installing Composer...${NC}\r"
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer >/dev/null 2>&1
echo -e "  ${G}✔️ Composer installed.                             ${NC}"

# --- PANEL DOWNLOAD ---
echo -ne "  ${Y}● Downloading Pterodactyl Panel ($version_PANEL)...${NC}\r"
mkdir -p /var/www/pterodactyl
cd /var/www/pterodactyl
if [[ "$version_PANEL" == "latest" ]]; then
    curl -Lso panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz >/dev/null 2>&1
else
    curl -Lso panel.tar.gz "https://github.com/pterodactyl/panel/releases/download/${version_PANEL}/panel.tar.gz" >/dev/null 2>&1
fi
tar -xzf panel.tar.gz >/dev/null 2>&1
chmod -R 755 storage/* bootstrap/cache/ >/dev/null 2>&1
echo -e "  ${G}✔️ Panel files downloaded and extracted.           ${NC}"

# --- DATABASE SETUP ---
echo -ne "  ${Y}● Configuring Database...${NC}\r"
DB_NAME=panel
DB_USER=pterodactyl
DB_PASS=yourPassword
mariadb -e "CREATE USER '${DB_USER}'@'127.0.0.1' IDENTIFIED BY '${DB_PASS}';" 2>/dev/null || true
mariadb -e "CREATE DATABASE ${DB_NAME};" 2>/dev/null || true
mariadb -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'127.0.0.1' WITH GRANT OPTION;" >/dev/null 2>&1
mariadb -e "FLUSH PRIVILEGES;" >/dev/null 2>&1
echo -e "  ${G}✔️ Database configured successfully.               ${NC}"

# --- ENVIRONMENT & DEPENDENCIES ---
echo -ne "  ${Y}● Setting up Environment and Dependencies...${NC}\r"
if [ ! -f ".env.example" ]; then
    curl -Lo .env.example https://raw.githubusercontent.com/pterodactyl/panel/develop/.env.example >/dev/null 2>&1
fi
cp .env.example .env
sed -i "s|APP_URL=.*|APP_URL=https://${DOMAIN}|g" .env
sed -i "s|DB_DATABASE=.*|DB_DATABASE=${DB_NAME}|g" .env
sed -i "s|DB_USERNAME=.*|DB_USERNAME=${DB_USER}|g" .env
sed -i "s|DB_PASSWORD=.*|DB_PASSWORD=${DB_PASS}|g" .env
if ! grep -q "^APP_ENVIRONMENT_ONLY=" .env; then
    echo "APP_ENVIRONMENT_ONLY=false" >> .env
fi

COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --optimize-autoloader >/dev/null 2>&1
php artisan key:generate --force >/dev/null 2>&1
php artisan migrate --seed --force >/dev/null 2>&1
chown -R www-data:www-data /var/www/pterodactyl/* >/dev/null 2>&1
echo -e "  ${G}✔️ Environment and Database migrations complete.   ${NC}"

# --- CRON ---
echo -ne "  ${Y}● Configuring Cron jobs...${NC}\r"
apt install -y cron >/dev/null 2>&1
systemctl enable --now cron >/dev/null 2>&1
(crontab -l 2>/dev/null; echo "* * * * * php /var/www/pterodactyl/artisan schedule:run >> /dev/null 2>&1") | crontab - >/dev/null 2>&1
echo -e "  ${G}✔️ Cron jobs configured.                           ${NC}"

# --- NGINX & SSL ---
echo -ne "  ${Y}● Configuring Nginx and Self-Signed SSL...${NC}\r"
mkdir -p /etc/certs/panel
openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 \
    -subj "/C=NA/ST=NA/L=NA/O=NA/CN=${DOMAIN}" \
    -keyout /etc/certs/panel/privkey.pem -out /etc/certs/panel/fullchain.pem >/dev/null 2>&1

tee /etc/nginx/sites-available/pterodactyl.conf > /dev/null << EOF
server {
    listen 80;
    server_name ${DOMAIN};
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name ${DOMAIN};

    root /var/www/pterodactyl/public;
    index index.php;

    ssl_certificate /etc/certs/panel/fullchain.pem;
    ssl_certificate_key /etc/certs/panel/privkey.pem;

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

ln -sf /etc/nginx/sites-available/pterodactyl.conf /etc/nginx/sites-enabled/pterodactyl.conf
nginx -t >/dev/null 2>&1 && systemctl restart nginx >/dev/null 2>&1
echo -e "  ${G}✔️ Nginx configured successfully.                  ${NC}"

# --- QUEUE WORKER ---
echo -ne "  ${Y}● Creating Queue Worker Service...${NC}\r"
tee /etc/systemd/system/pteroq.service > /dev/null << 'EOF'
[Unit]
Description=Pterodactyl Queue Worker
After=redis-server.service

[Service]
User=www-data
Group=www-data
Restart=always
ExecStart=/usr/bin/php /var/www/pterodactyl/artisan queue:work --queue=high,standard,low --sleep=3 --tries=3
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload >/dev/null 2>&1
systemctl enable --now redis-server >/dev/null 2>&1
systemctl enable --now pteroq.service >/dev/null 2>&1
echo -e "  ${G}✔️ Queue Service running.                          ${NC}"

# --- FINAL PANEL CONFIGURATION & ADMIN ---
echo -ne "  ${Y}● Finalizing Settings & Creating Admin User...${NC}\r"
cd /var/www/pterodactyl

sed -i '/^APP_ENVIRONMENT_ONLY=/d' .env
echo "APP_ENVIRONMENT_ONLY=false" >> .env
sed -i '/RECAPTCHA_ENABLED=/d' .env
echo 'RECAPTCHA_ENABLED=false' >> .env
sed -i '/APP_NAME=/d' .env
echo 'APP_NAME="SKA HOST"' >> .env
TIMEZONE=$(timedatectl show --property=Timezone --value 2>/dev/null || echo "UTC")
sed -i "s|APP_TIMEZONE=.*|APP_TIMEZONE=${TIMEZONE}|g" .env

sed -i "s|MAIL_MAILER=.*|MAIL_MAILER=smtp|g" .env
sed -i "s|MAIL_HOST=.*|MAIL_HOST=smtp.gmail.in|g" .env
sed -i "s|MAIL_PORT=.*|MAIL_PORT=587|g" .env
sed -i "s|MAIL_USERNAME=.*|MAIL_USERNAME=skahost|g" .env
sed -i "s|MAIL_PASSWORD=.*|MAIL_PASSWORD=0000000000000|g" .env
sed -i "s|MAIL_ENCRYPTION=.*|MAIL_ENCRYPTION=tls|g" .env
sed -i "s|MAIL_FROM_ADDRESS=.*|MAIL_FROM_ADDRESS=skahost@gmail.com|g" .env
sed -i 's|MAIL_FROM_NAME=.*|MAIL_FROM_NAME="SKA HOST"|g' .env

php artisan p:location:make --short=IN --long="India" >/dev/null 2>&1 || true

php artisan view:clear >/dev/null 2>&1
php artisan config:clear >/dev/null 2>&1
php artisan cache:clear >/dev/null 2>&1
php artisan config:cache >/dev/null 2>&1
chown -R www-data:www-data /var/www/pterodactyl/* >/dev/null 2>&1
php artisan queue:restart >/dev/null 2>&1

php artisan p:user:make -n --email="$EMAIL" --username="${USERNAME}" --password="$PASSWORD" --admin=1 --name-first=My --name-last=Admin >/dev/null 2>&1
echo -e "  ${G}✔️ Admin User created successfully.                ${NC}"

# --- END REPORT ---
echo -e "\n${C}╔════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${C}║${NC}                   ${G}✅ DEPLOYMENT COMPLETE ✅${NC}                        ${C}║${NC}"
echo -e "${C}╠════════════════════════════════════════════════════════════════════╣${NC}"
echo -e "${C}║${NC}  ${DG}Panel URL :${NC} ${W}https://$DOMAIN${NC}"
echo -e "${C}║${NC}  ${DG}Username  :${NC} ${W}$USERNAME${NC}"
echo -e "${C}║${NC}  ${DG}Password  :${NC} ${W}$PASSWORD${NC}"
echo -e "${C}║${NC}  ${DG}Email     :${NC} ${W}$EMAIL${NC}"
echo -e "${C}╚════════════════════════════════════════════════════════════════════╝${NC}"
echo -e "\n  ${G}Enjoy your new Pterodactyl Panel!${NC}"
echo -en "  ${Y}root@skahost${W}:~${DG}/sys/pause${NC} (Press ENTER to exit) "
read -r
echo ""
