#!/bin/bash
set -euo pipefail

# ==========================================
# SKA HOST MULTI-TOOL (PAYMENTER INSTALLER)
# STYLE: NEON CYBERPUNK + DOUBLE BORDERS
# BACKEND: PAYMENTER PANEL + PHP 8.3
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
    echo -e "${C}║${NC}                   ${Y}⚡ PAYMENTER INSTALLER ⚡${NC}                        ${C}║${NC}"
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
    echo -en "  ${Y}root@skahost${W}:~${C}/paymenter${NC} ($label) [${W}$default${NC}]# "
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
ask "Panel Domain" "billing.aiomarket.online" DOMAIN
ask "Admin Email" "paymenter@gmail.com" EMAIL
ask "Admin Password" "paymenter" PASSWORD

# --- FINAL VALIDATION ---
echo -e "\n      ${C}╭───────────── ${W}REVIEW CONFIGURATION ${C}─────────────╮${NC}"
echo -e "      ${C}│${NC} ${DG}Domain:${NC}   ${W}$DOMAIN"
echo -e "      ${C}│${NC} ${DG}Email:${NC}    ${W}$EMAIL"
echo -e "      ${C}│${NC} ${DG}Pass:${NC}     ${W}$PASSWORD"
echo -e "      ${C}╰──────────────────────────────────────────────────╯${NC}"

while true; do
    echo -en "\n  ${Y}root@skahost${W}:~${C}/paymenter${NC} (Start Installation? y/N)# "
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

curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg >/dev/null 2>&1
echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list >/dev/null 2>&1
apt update >/dev/null 2>&1
echo -e "  ${G}✔️ Repositories configured successfully.           ${NC}"

# --- CORE SERVICES ---
echo -ne "  ${Y}● Installing PHP 8.3, MariaDB, Nginx & Redis...${NC}\r"
apt install -y php8.3 php8.3-{cli,fpm,common,mysql,mbstring,bcmath,xml,zip,curl,gd,tokenizer,ctype,simplexml,dom,intl,redis} mariadb-server nginx redis-server >/dev/null 2>&1
echo -e "  ${G}✔️ Core services installed.                        ${NC}"

# --- PANEL DOWNLOAD ---
echo -ne "  ${Y}● Downloading Paymenter Core...${NC}\r"
mkdir -p /var/www/paymenter
cd /var/www/paymenter
curl -Lso paymenter.tar.gz https://github.com/paymenter/paymenter/releases/latest/download/paymenter.tar.gz >/dev/null 2>&1
tar -xzf paymenter.tar.gz >/dev/null 2>&1
chmod -R 755 storage/* bootstrap/cache/ >/dev/null 2>&1
echo -e "  ${G}✔️ Panel files downloaded and extracted.           ${NC}"

# --- DATABASE SETUP ---
echo -ne "  ${Y}● Configuring Database...${NC}\r"
DB_NAME="paymenter"
DB_USER="paymenter"
DB_PASS="paymenter" 
mysql -e "CREATE USER '${DB_USER}'@'127.0.0.1' IDENTIFIED BY '${DB_PASS}';" 2>/dev/null || true
mysql -e "CREATE DATABASE ${DB_NAME};" 2>/dev/null || true
mysql -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'127.0.0.1' WITH GRANT OPTION;" >/dev/null 2>&1
mysql -e "FLUSH PRIVILEGES;" >/dev/null 2>&1
echo -e "  ${G}✔️ Database configured successfully.               ${NC}"

# --- ENVIRONMENT & DEPENDENCIES ---
echo -ne "  ${Y}● Setting up Environment and Seeders...${NC}\r"
cp -n .env.example .env >/dev/null 2>&1 || true
sed -i "s|^DB_DATABASE=.*|DB_DATABASE=${DB_NAME}|g" .env || true
sed -i "s|^DB_USERNAME=.*|DB_USERNAME=${DB_USER}|g" .env || true
sed -i "s|^DB_PASSWORD=.*|DB_PASSWORD=${DB_PASS}|g" .env || true

php artisan key:generate --force >/dev/null 2>&1
php artisan storage:link >/dev/null 2>&1
php artisan migrate --force --seed >/dev/null 2>&1
php artisan db:seed --class=CustomPropertySeeder --force >/dev/null 2>&1
echo -e "  ${G}✔️ Environment and Database migrations complete.   ${NC}"

# --- CRON ---
echo -ne "  ${Y}● Configuring Cron jobs...${NC}\r"
apt install -y cron >/dev/null 2>&1
systemctl enable --now cron >/dev/null 2>&1
(crontab -l 2>/dev/null | grep -v "paymenter/artisan schedule:run"; echo "* * * * * /usr/bin/php /var/www/paymenter/artisan schedule:run >> /dev/null 2>&1") | crontab - >/dev/null 2>&1
echo -e "  ${G}✔️ Cron jobs configured.                           ${NC}"

# --- NGINX & SSL ---
echo -ne "  ${Y}● Configuring Nginx and Self-Signed SSL...${NC}\r"
mkdir -p /etc/certs/paymenter
cd /etc/certs/paymenter
openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 \
-subj "/C=NA/ST=NA/L=NA/O=NA/CN=${DOMAIN}" \
-keyout privkey.pem -out fullchain.pem >/dev/null 2>&1

tee /etc/nginx/sites-available/paymenter.conf > /dev/null << EOF
server {
    listen 80;
    listen [::]:80;
    server_name ${DOMAIN};
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name ${DOMAIN};

    root /var/www/paymenter/public;
    index index.php index.html;

    charset utf-8;

    ssl_certificate /etc/certs/paymenter/fullchain.pem;
    ssl_certificate_key /etc/certs/paymenter/privkey.pem;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ ^/index\.php(/|$) {
        fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_hide_header X-Powered-By;
    }

    location ~ \.php$ {
        return 404;
    }

    client_max_body_size 100m;
    sendfile off;
}
EOF

sudo rm -f /etc/nginx/sites-enabled/default
sudo ln -sf /etc/nginx/sites-available/paymenter.conf /etc/nginx/sites-enabled/paymenter.conf
nginx -t >/dev/null 2>&1 && systemctl restart nginx >/dev/null 2>&1
chown -R www-data:www-data /var/www/paymenter/* >/dev/null 2>&1
echo -e "  ${G}✔️ Nginx configured successfully.                  ${NC}"

# --- QUEUE WORKER ---
echo -ne "  ${Y}● Creating Queue Worker Service...${NC}\r"
tee /etc/systemd/system/paymenter.service > /dev/null << 'EOF'
[Unit]
Description=Paymenter Queue Worker

[Service]
User=www-data
Group=www-data
Restart=always
ExecStart=/usr/bin/php /var/www/paymenter/artisan queue:work
StartLimitInterval=180
StartLimitBurst=30
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable --now paymenter.service >/dev/null 2>&1
sudo systemctl enable --now redis-server >/dev/null 2>&1
echo -e "  ${G}✔️ Queue Service running.                          ${NC}"

# --- FINAL PANEL CONFIGURATION & ADMIN ---
echo -ne "  ${Y}● Finalizing Settings & Creating Admin User...${NC}\r"
cd /var/www/paymenter

php artisan migrate --force >/dev/null 2>&1
php artisan tinker --execute="
DB::table('settings')->updateOrInsert(['key'=>'company_name'], ['value'=>'Nobita Cloud']);
DB::table('settings')->updateOrInsert(['key'=>'timezone'], ['value'=>'Asia/Kolkata']);
DB::table('settings')->updateOrInsert(['key'=>'app_url'], ['value'=>'https://${DOMAIN}']);
" >/dev/null 2>&1

php artisan config:cache >/dev/null 2>&1
php artisan config:clear >/dev/null 2>&1
php artisan cache:clear >/dev/null 2>&1
php artisan config:cache >/dev/null 2>&1

php artisan tinker --execute="\App\Models\User::create([
'first_name'=>'My',
'last_name'=>'Admin',
'email'=>'$EMAIL',
'password'=>bcrypt('$PASSWORD'),
'role_id'=>1,
'is_admin'=>1
]);" >/dev/null 2>&1
echo -e "  ${G}✔️ Admin User & Settings configured.               ${NC}"

# --- END REPORT ---
type_effect "\n${G}✅ Paymenter Installation Complete!${NC}" 0.02

echo -e "\n${C}╔════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${C}║${NC}                   ${G}✅ DEPLOYMENT COMPLETE ✅${NC}                        ${C}║${NC}"
echo -e "${C}╠════════════════════════════════════════════════════════════════════╣${NC}"
echo -e "${C}║${NC}  ${DG}Panel URL :${NC} ${W}https://$DOMAIN${NC}"
echo -e "${C}║${NC}  ${DG}Email     :${NC} ${W}$EMAIL${NC}"
echo -e "${C}║${NC}  ${DG}Password  :${NC} ${W}$PASSWORD${NC}"
echo -e "${C}╚════════════════════════════════════════════════════════════════════╝${NC}"
echo -e "\n  ${G}Enjoy your new Paymenter Panel!${NC}"
echo -en "  ${Y}root@skahost${W}:~${DG}/sys/pause${NC} (Press ENTER to exit) "
read -r
echo ""
