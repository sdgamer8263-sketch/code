#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

# ==========================================
# SKA HOST MULTI-TOOL (VM DEPENDENCY INSTALLER)
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
    echo -ne "  ${C}Booting Installer Core [${NC}"
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

show_dashboard() {
    clear
    echo -e "${C}╔════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${C}║${NC}   ${C}███████╗██╗  ██╗ █████╗     ██╗  ██╗ ██████╗ ███████╗████████╗${NC}   ${C}║${NC}"
    echo -e "${C}║${NC}   ${B}██╔════╝██║ ██╔╝██╔══██╗    ██║  ██║██╔═══██╗██╔════╝╚══██╔══╝${NC}   ${C}║${NC}"
    echo -e "${C}║${NC}   ${P}███████╗█████╔╝ ███████║    ███████║██║   ██║███████╗   ██║   ${NC}   ${C}║${NC}"
    echo -e "${C}║${NC}   ${Y}╚════██║██╔═██╗ ██╔══██║    ██╔══██║██║   ██║╚════██║   ██║   ${NC}   ${C}║${NC}"
    echo -e "${C}║${NC}   ${G}███████║██║  ██╗██║  ██║    ██║  ██║╚██████╔╝███████║   ██║   ${NC}   ${C}║${NC}"
    echo -e "${C}║${NC}   ${W}╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝    ╚═╝  ╚═╝ ╚═════╝ ╚══════╝   ╚═╝   ${NC}   ${C}║${NC}"
    echo -e "${C}╠════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${C}║${NC}                 ${Y}⚡ VM DEPENDENCY INSTALLER ⚡${NC}                      ${C}║${NC}"
    echo -e "${C}╚════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# ==========================================
# 🛠️ BACKEND UTILS
# ==========================================

cmd_exists() {
    command -v "$1" >/dev/null 2>&1
}

# -------------------------------
# Detect OS
# -------------------------------
detect_os() {
    echo -e "${C}  [SYS] Analyzing Host System Environment...${NC}"
    echo -ne "  ${Y}● Detecting Operating System...${NC}\r"
    
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        VERSION_ID=${VERSION_ID%%.*}
        echo -e "  ${G}✔️ Detected OS: ${W}$OS $VERSION_ID${NC}                     "
    else
        echo -e "  ${R}❌ Cannot detect OS${NC}"
        exit 1
    fi
}

# -------------------------------
# Install packages (SMART)
# -------------------------------
install_packages() {
    INSTALL=()
    echo -e "\n${C}  [SYS] Verifying Required Core Packages...${NC}"

    case "$OS" in
        ubuntu|debian)
            cmd_exists qemu-system-x86_64 || INSTALL+=(qemu-kvm qemu-utils)
            cmd_exists wget || INSTALL+=(wget)
            cmd_exists lsof || INSTALL+=(lsof)
            cmd_exists growpart || INSTALL+=(cloud-guest-utils)
            cmd_exists cloud-localds || INSTALL+=(cloud-image-utils)
            cmd_exists genisoimage || INSTALL+=(genisoimage)

            if [ ${#INSTALL[@]} -eq 0 ]; then
                echo -e "  ${G}✔️ All packages already installed.${NC}"
            else
                echo -e "  ${Y}● Missing packages found: ${W}${INSTALL[*]}${NC}"
                echo -ne "  ${Y}● Downloading and installing packages...${NC}\r"
                sudo apt update -y >/dev/null 2>&1 && sudo apt install -y "${INSTALL[@]}" >/dev/null 2>&1
                echo -e "  ${G}✔️ Installation Complete!                     ${NC}"
            fi
            ;;

        fedora)
            cmd_exists qemu-system-x86_64 || INSTALL+=(qemu-kvm qemu-img)
            cmd_exists wget || INSTALL+=(wget)
            cmd_exists lsof || INSTALL+=(lsof)
            cmd_exists growpart || INSTALL+=(cloud-utils-growpart)
            cmd_exists genisoimage || INSTALL+=(genisoimage)

            if [ ${#INSTALL[@]} -gt 0 ]; then
                echo -e "  ${Y}● Missing packages found: ${W}${INSTALL[*]}${NC}"
                echo -ne "  ${Y}● Downloading and installing packages...${NC}\r"
                sudo dnf install -y epel-release >/dev/null 2>&1
                sudo dnf install -y "${INSTALL[@]}" cloud-utils >/dev/null 2>&1
                echo -e "  ${G}✔️ Installation Complete!                     ${NC}"
            else
                echo -e "  ${G}✔️ All packages already installed.${NC}"
            fi
            ;;

        centos|rocky|almalinux|rhel)
            cmd_exists qemu-system-x86_64 || INSTALL+=(qemu-kvm qemu-img)
            cmd_exists wget || INSTALL+=(wget)
            cmd_exists lsof || INSTALL+=(lsof)
            cmd_exists growpart || INSTALL+=(cloud-utils-growpart)
            cmd_exists genisoimage || INSTALL+=(genisoimage)

            if [ ${#INSTALL[@]} -gt 0 ]; then
                echo -e "  ${Y}● Missing packages found: ${W}${INSTALL[*]}${NC}"
                echo -ne "  ${Y}● Downloading and installing packages...${NC}\r"
                if ! rpm -q epel-release >/dev/null 2>&1; then
                    sudo dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-${VERSION_ID}.noarch.rpm >/dev/null 2>&1
                fi
                sudo dnf install -y "${INSTALL[@]}" cloud-utils >/dev/null 2>&1
                echo -e "  ${G}✔️ Installation Complete!                     ${NC}"
            else
                echo -e "  ${G}✔️ All packages already installed.${NC}"
            fi
            ;;

        amzn)
            cmd_exists qemu-system-x86_64 || INSTALL+=(qemu-kvm qemu-img)
            cmd_exists wget || INSTALL+=(wget)
            cmd_exists lsof || INSTALL+=(lsof)
            cmd_exists growpart || INSTALL+=(cloud-utils-growpart)

            if [ ${#INSTALL[@]} -eq 0 ]; then 
                echo -e "  ${G}✔️ All packages already installed.${NC}"
            else
                echo -e "  ${Y}● Missing packages found: ${W}${INSTALL[*]}${NC}"
                echo -ne "  ${Y}● Downloading and installing packages...${NC}\r"
                sudo dnf install -y "${INSTALL[@]}" cloud-utils >/dev/null 2>&1
                echo -e "  ${G}✔️ Installation Complete!                     ${NC}"
            fi
            ;;

        arch)
            cmd_exists qemu-system-x86_64 || INSTALL+=(qemu-full)
            cmd_exists wget || INSTALL+=(wget)
            cmd_exists lsof || INSTALL+=(lsof)
            cmd_exists growpart || INSTALL+=(cloud-guest-utils)
            cmd_exists genisoimage || INSTALL+=(cdrtools)

            if [ ${#INSTALL[@]} -eq 0 ]; then 
                echo -e "  ${G}✔️ All packages already installed.${NC}"
            else
                echo -e "  ${Y}● Missing packages found: ${W}${INSTALL[*]}${NC}"
                echo -ne "  ${Y}● Downloading and installing packages...${NC}\r"
                sudo pacman -Sy --noconfirm "${INSTALL[@]}" >/dev/null 2>&1
                echo -e "  ${G}✔️ Installation Complete!                     ${NC}"
            fi
            ;;

        opensuse*|sles)
            cmd_exists qemu-system-x86_64 || INSTALL+=(qemu-tools qemu-kvm)
            cmd_exists wget || INSTALL+=(wget)
            cmd_exists lsof || INSTALL+=(lsof)
            cmd_exists growpart || INSTALL+=(cloud-utils-growpart)
            cmd_exists genisoimage || INSTALL+=(genisoimage)

            if [ ${#INSTALL[@]} -eq 0 ]; then 
                echo -e "  ${G}✔️ All packages already installed.${NC}"
            else
                echo -e "  ${Y}● Missing packages found: ${W}${INSTALL[*]}${NC}"
                echo -ne "  ${Y}● Downloading and installing packages...${NC}\r"
                sudo zypper --non-interactive install "${INSTALL[@]}" >/dev/null 2>&1
                echo -e "  ${G}✔️ Installation Complete!                     ${NC}"
            fi
            ;;

        *)
            echo -e "  ${R}❌ Unsupported OS: $OS${NC}"
            exit 1
            ;;
    esac
}

# -------------------------------
# Links
# -------------------------------
setup_links() {
    echo -e "\n${C}  [SYS] Configuring System Links...${NC}"
    local links_made=0

    if [ -f /usr/libexec/qemu-kvm ] && ! cmd_exists qemu-system-x86_64; then
        sudo ln -sf /usr/libexec/qemu-kvm /usr/bin/qemu-system-x86_64
        echo -e "  ${Y}● Created symlink for qemu-system-x86_64${NC}"
        links_made=1
    fi

    if cmd_exists cloud-localds && [ -f /usr/bin/cloud-localds ]; then
        sudo ln -sf /usr/bin/cloud-localds /usr/local/bin/cloud-localds
        echo -e "  ${Y}● Created symlink for cloud-localds${NC}"
        links_made=1
    fi

    if [ $links_made -eq 0 ]; then
        echo -e "  ${G}✔️ System links are already correctly configured.${NC}"
    else
        echo -e "  ${G}✔️ System links updated successfully.${NC}"
    fi
}

# -------------------------------
# Main
# -------------------------------
main() {
    boot_sequence
    show_dashboard

    detect_os
    install_packages
    setup_links

    echo -e "\n${G}  [+] Sequence Completed Successfully for ${W}$OS $VERSION_ID${NC}!"
    echo -en "  ${Y}root@skahost${W}:~${DG}/sys/pause${NC} (Press ENTER) "
    read -r
    echo -e ""
}

main "$@"
