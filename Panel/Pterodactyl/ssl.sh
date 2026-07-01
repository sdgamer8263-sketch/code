#!/bin/bash
set -euo pipefail

# ==========================================
# SKA HOST MULTI-TOOL (NGINX & SSL CONFIG)
# STYLE: NEON CYBERPUNK + DOUBLE BORDERS
# BACKEND: PTERODACTYL NGINX / CERTBOT
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
    local text="${C}  [SYS] Establishing secure connection to SKA HOST Web Engine...${NC}"
    type_effect "$text" 0.02
    
    local chars="/-\|"
    echo -ne "  ${P}Authenticating: ${NC}"
    for i in {1..15}; do
        echo -ne "\b${G}${chars:i%4:1}${NC}"
        sleep 0.1
    done
    
    echo -e "\b${G}SUCCESS!${NC}"
    echo -ne "  ${C}Booting Configurator Core [${NC}"
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
    echo -e "${C}║${NC}                 ${Y}⚡ NGINX & SSL CONFIGURATOR ⚡${NC}                     ${C}║${NC}"
    echo -e "${C}╠════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${C}║${NC} ${BLINK}${G}● ONLINE${NC} ${DG}│${NC} ⏱️ ${W}${PAD_UPTIME}${NC} ${DG}│${NC} 🧠 ${W}${PAD_CPU}${NC} ${DG}│${NC} 💾 ${W}${PAD_RAM}${NC}      ${C}║${NC}"
    echo -e "${C}╚════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# ==========================================
# 🛠️ BACKEND LOGIC FUNCTIONS
# ==========================================

prepare_environment() {
    if [ ! -d "/var/www/pterodactyl" ]; then
        echo -e "\n${R}  [!] Pterodactyl directory not found! (/var/www/pterodactyl)${NC}"
        return 1
    fi

    echo -ne "  ${Y}● Cleaning up old configurations...${NC}\r"
    rm -f /etc/nginx/sites-enabled/default
    rm -f /etc/nginx/sites-available/pterodactyl.conf
    rm -f /etc/nginx/sites-enabled/pterodactyl.conf
    cd /var/www/pterodactyl || return 1
    echo -e "  ${G}✔️ Old configurations removed.         ${NC}"
    return 0
}

test_and_restart_nginx() {
    echo -ne "  ${Y}● Testing Nginx Configuration...${NC}\r"
    
    # Symlink the config so Nginx actually reads it
    ln -sf /etc/nginx/sites-available/pterodactyl.conf /etc/nginx/sites-enabled/pterodactyl.conf
    
    if nginx -t >/dev/null 2>&1; then
        echo -e "  ${G}✔️ Nginx configuration is valid.       ${NC}"
        echo -ne "  ${Y}● Restarting Nginx Server...${NC}\r"
        systemctl restart nginx >/dev/null 2>&1
        echo -e "  ${G}✔️ Nginx Server restarted.             ${NC}"
        return 0
    else
        echo -e "  ${R}❌ Nginx configuration test failed! Please check logs.${NC}"
        return 1
    fi
}

# ==========================================
# ⚙️ MAIN SYSTEM LOOP
# ==========================================

boot_sequence

while true; do
    show_dashboard
    
    # PERFECTLY ALIGNED 70-COLUMN MENU BOX
    echo -e "${DG}╭───────────────────── ${W}SELECT CONFIGURATION MODE ${DG}────────────────────╮${NC}"
    echo -e "${DG}│${NC}                                                                    ${DG}│${NC}"
    echo -e "${DG}│${NC}      ${G}[1]${NC} 🔒 Configure SSL / HTTPS      ${DG}:: (Manual Cert Paths)${NC}      ${DG}│${NC}"
    echo -e "${DG}│${NC}      ${R}[2]${NC} 🔓 Configure No SSL / HTTP   ${DG}:: (Insecure)${NC}             ${DG}│${NC}"
    echo -e "${DG}│${NC}      ${Y}[3]${NC} ⚡ Auto-Generate SSL        ${DG}:: (Certbot Setup)${NC}        ${DG}│${NC}"
    echo -e "${DG}│${NC}                                                                    ${DG}│${NC}"
    echo -e "${DG}├────────────────────────────────────────────────────────────────────┤${NC}"
    echo -e "${DG}│${NC}                         ${R}[0] ❌ SYSTEM EXIT${NC}                         ${DG}│${NC}"
    echo -e "${DG}╰────────────────────────────────────────────────────────────────────╯${NC}"
    echo ""
    
    echo -en "  ${Y}root@skahost${W}:~${C}/nginx${NC}# "
    read -r OPTION
    
    case $OPTION in
        
        # ---------------------------------------------------------
        # (1) MANUAL SSL CONFIGURATION
        # ---------------------------------------------------------
        1|01)
            echo -e "\n${C}  [SYS] Initializing Manual SSL Configuration...${NC}"
            
            echo -en "  ${Y}root@skahost${W}:~${C}/nginx/domain${NC} (e.g. panel.example.com)# "
            read -r DOMAIN
            
            prepare_environment || continue
            
            echo -e "\n      ${C}╭─────── ${W}CERTIFICATE PATH ${C}───────╮${NC}"
            echo -e "      ${C}│${NC}  ${G}[y]${NC} Let's Encrypt (Standard)   ${C}│${NC}"
            echo -e "      ${C}│${NC}  ${Y}[n]${NC} Custom (/etc/certs/panel)  ${C}│${NC}"
            echo -e "      ${C}╰────────────────────────────────╯${NC}\n"
            
            echo -en "  ${Y}root@skahost${W}:~${C}/nginx/cert-type${NC} (y/n)# "
            read -r SSLTYPE

            if [[ "$SSLTYPE" =~ ^[Yy]$ ]]; then
                FULLCHAIN="/etc/letsencrypt/live/${DOMAIN}/fullchain.pem"
                PRIVKEY="/etc/letsencrypt/live/${DOMAIN}/privkey.pem"
            else
                FULLCHAIN="/etc/certs/panel/fullchain.pem"
                PRIVKEY="/etc/certs/panel/privkey.pem"
            fi

            echo -ne "  ${Y}● Modifying APP_URL in .env to HTTPS...${NC}\r"
            sed -i "s|APP_URL=.*|APP_URL=https://${DOMAIN}|g" .env
            echo -e "  ${G}✔️ APP_URL set to HTTPS.                 ${NC}"

            echo -ne "  ${Y}● Generating Nginx Server Block...${NC}\r"
            cat > /etc/nginx/sites-available/pterodactyl.conf <<EOF
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

    ssl_certificate ${FULLCHAIN};
    ssl_certificate_key ${PRIVKEY};

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
        fastcgi_param HTTP_PROXY "";
        fastcgi_intercept_errors off;
        fastcgi_buffer_size 16k;
        fastcgi_buffers 4 16k;
        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF
            echo -e "  ${G}✔️ Server Block Generated.               ${NC}"
            
            if test_and_restart_nginx; then
                type_effect "\n${G}✔️ Setup Successfully Completed!${NC}" 0.02
                echo -e "  ${DG}▶ Panel URL: ${W}https://${DOMAIN}${NC}"
            fi
            ;;

        # ---------------------------------------------------------
        # (2) NO SSL / HTTP CONFIGURATION
        # ---------------------------------------------------------
        2|02)
            echo -e "\n${C}  [SYS] Initializing HTTP (No SSL) Configuration...${NC}"
            
            echo -en "  ${Y}root@skahost${W}:~${C}/nginx/domain${NC} (e.g. panel.example.com)# "
            read -r DOMAIN
            
            prepare_environment || continue
            
            echo -ne "  ${Y}● Modifying APP_URL in .env to HTTP...${NC}\r"
            sed -i "s|APP_URL=.*|APP_URL=http://${DOMAIN}|g" .env
            echo -e "  ${G}✔️ APP_URL set to HTTP.                  ${NC}"

            echo -ne "  ${Y}● Generating Nginx Server Block...${NC}\r"
            cat > /etc/nginx/sites-available/pterodactyl.conf <<EOF
server {
    listen 80;
    server_name ${DOMAIN};

    root /var/www/pterodactyl/public;
    index index.php;
    charset utf-8;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    client_max_body_size 100m;
    client_body_timeout 120s;
    sendfile off;

    location ~ \.php\$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)\$;
        fastcgi_pass unix:/run/php/php${PHP_VERSION}-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param PHP_VALUE "upload_max_filesize=100M \n post_max_size=100M";
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF
            echo -e "  ${G}✔️ Server Block Generated.               ${NC}"
            
            if test_and_restart_nginx; then
                type_effect "\n${G}✔️ Setup Successfully Completed!${NC}" 0.02
                echo -e "  ${DG}▶ Panel URL: ${W}http://${DOMAIN}${NC}"
            fi
            ;;

        # ---------------------------------------------------------
        # (3) AUTO SSL GENERATOR (CERTBOT)
        # ---------------------------------------------------------
        3|03)
            echo -e "\n${C}  [SYS] Initializing Auto-SSL (Certbot) Generator...${NC}"
            
            echo -en "  ${Y}root@skahost${W}:~${C}/nginx/domain${NC} (e.g. panel.example.com)# "
            read -r DOMAIN
            
            # Generate random email for Let's Encrypt
            EMAIL="ssl$(tr -dc a-z0-9 </dev/urandom | head -c6)@nobita.com"
            
            echo -ne "  ${Y}● Updating system repositories...${NC}\r"
            apt update -y >/dev/null 2>&1
            echo -e "  ${G}✔️ Repositories updated.                 ${NC}"

            echo -ne "  ${Y}● Installing Certbot dependencies...${NC}\r"
            apt install certbot python3-certbot-nginx -y >/dev/null 2>&1
            echo -e "  ${G}✔️ Certbot installed.                    ${NC}"
            
            echo -e "  ${C}  [SYS] Requesting SSL Certificate from Let's Encrypt...${NC}"
            
            # Run Certbot silently. If it fails, catch the error.
            if certbot --nginx -d "${DOMAIN}" --non-interactive --agree-tos -m "${EMAIL}" --redirect >/dev/null 2>&1; then
                type_effect "\n${G}✔️ SSL Installed Successfully!${NC}" 0.02
                echo -e "  ${G}✔️ HTTPS Redirection Enabled.${NC}"
                echo -e "  ${DG}▶ Panel URL: ${W}https://${DOMAIN}${NC}"
            else
                echo -e "\n${R}  [!] SSL Generation Failed.${NC}"
                echo -e "  ${Y}Please ensure your domain points to this server's IP address.${NC}"
            fi
            ;;

        # ---------------------------------------------------------
        # (0) EXIT
        # ---------------------------------------------------------
        0|00)
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

    echo -en "\n  ${Y}root@skahost${W}:~${DG}/sys/pause${NC} (Press ENTER) "
    read -r
done
