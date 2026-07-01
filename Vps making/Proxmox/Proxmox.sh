#!/bin/bash
set -euo pipefail

# ==========================================
# SKA HOST MULTI-TOOL (VM MANAGER MODULE)
# STYLE: NEON CYBERPUNK + DOUBLE BORDERS
# BACKEND: PURE QEMU + PROXMOX
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

type_effect() {
    local text="$1"
    local speed="$2"
    for (( i=0; i<${#text}; i++ )); do
        echo -en "${text:$i:1}"
        sleep "$speed"
    done
    echo ""
}

boot_sequence() {
    clear
    echo -e "\n\n"
    local text="${C}  [SYS] Establishing secure connection to SKA HOST VM Engine...${NC}"
    type_effect "$text" 0.02
    
    local chars="/-\|"
    echo -ne "  ${P}Authenticating: ${NC}"
    for i in {1..15}; do
        echo -ne "\b${G}${chars:i%4:1}${NC}"
        sleep 0.1
    done
    
    echo -e "\b${G}SUCCESS!${NC}"
    echo -ne "  ${C}Booting Hypervisor Core [${NC}"
    for ((i = 0; i < 35; i++)); do
        echo -ne "${P}■${NC}"
        sleep 0.02
    done
    echo -e "${C}] 100%${NC}"
    sleep 0.3
}

show_dashboard() {
    clear
    
    # Compress uptime to fit nicely
    local UPTIME=$(uptime -p | sed -e 's/up //' -e 's/ hours/h/' -e 's/ hour/h/' -e 's/ minutes/m/' -e 's/ minute/m/' -e 's/ days/d/' -e 's/ day/d/' -e 's/,//g') 
    local CPU_LOAD=$(top -bn1 | grep load | awk '{printf "%.2f", $(NF-2)}')
    local RAM_FREE=$(free -m | awk '/Mem:/ { printf("%.0f%%", $3/$2 * 100.0) }')
    
    # Strict padding so the right border NEVER breaks
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
    echo -e "${C}║${NC}                   ${Y}⚡ VIRTUAL MACHINE ENGINE ⚡${NC}                     ${C}║${NC}"
    echo -e "${C}╠════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${C}║${NC} ${BLINK}${G}● ONLINE${NC} ${DG}│${NC} ⏱️ ${W}${PAD_UPTIME}${NC} ${DG}│${NC} 🧠 ${W}${PAD_CPU}${NC} ${DG}│${NC} 💾 ${W}${PAD_RAM}${NC}      ${C}║${NC}"
    echo -e "${C}╚════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# ==========================================
# 🛠️ BACKEND LOGIC & CONFIGURATION
# ==========================================

# Initialize paths and logging
VM_DIR="${VM_DIR:-$HOME/vms}"
PROXMOX_DIR="${PROXMOX_DIR:-$HOME/proxmox}"
LOG_FILE="$VM_DIR/vm_manager.log"
mkdir -p "$VM_DIR" "$PROXMOX_DIR"

CONFIG_FILE="$HOME/.vm_manager.conf"

save_config() {
    cat > "$CONFIG_FILE" <<EOF
# VM Manager Configuration
VM_DIR="$VM_DIR"
PROXMOX_DIR="$PROXMOX_DIR"
PROXMOX_HOST="${PROXMOX_HOST:-}"
PROXMOX_USER="${PROXMOX_USER:-}"
PROXMOX_REALM="${PROXMOX_REALM:-pam}"
PROXMOX_NODE="${PROXMOX_NODE:-}"
STORAGE="${STORAGE:-local}"
EOF
}

load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        source "$CONFIG_FILE"
    fi
}

log_message() {
    local level=$1
    local message=$2
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$level] $message" >> "$LOG_FILE"
}

# 🎨 Re-styled print_status for Cyberpunk Theme
print_status() {
    local type=$1
    local message=$2
    
    case $type in
        "INFO") echo -e "  ${C}[SYS]${NC} $message"; log_message "INFO" "$message" ;;
        "WARN") echo -e "  ${Y}[WARN]${NC} $message"; log_message "WARN" "$message" ;;
        "ERROR") echo -e "  ${R}[ERR]${NC} $message"; log_message "ERROR" "$message" ;;
        "SUCCESS") echo -e "  ${G}[OK]${NC} $message"; log_message "SUCCESS" "$message" ;;
        "INPUT") echo -e "  ${Y}root@skahost${W}:~${C}/vm-manager${NC}# $message" ;;
        *) echo "[$type] $message"; log_message "$type" "$message" ;;
    esac
}

show_progress() {
    local pid=$1
    local msg=$2
    local spin='-\|/'
    local i=0
    
    echo -n "  ${Y}● $msg ${NC}"
    while kill -0 "$pid" 2>/dev/null; do
        i=$(( (i+1) %4 ))
        printf "\r  ${Y}● $msg ${spin:$i:1}${NC}"
        sleep 0.1
    done
    printf "\r  ${G}✔️ $msg Done!      ${NC}\n"
}

# Core VM logic (Unchanged Backend)
configure_proxmox() {
    print_status "INFO" "Configuring Proxmox connection"
    read -p "$(print_status "INPUT" "Proxmox Host/IP (e.g., 192.168.1.100): ")" PROXMOX_HOST
    read -p "$(print_status "INPUT" "Proxmox Username (e.g., root@pam): ")" PROXMOX_USER
    read -p "$(print_status "INPUT" "Proxmox Password: ")" -s PROXMOX_PASS
    echo
    read -p "$(print_status "INPUT" "Proxmox Node name (e.g., pve): ")" PROXMOX_NODE
    read -p "$(print_status "INPUT" "Storage name (e.g., local-lvm): ")" STORAGE
    
    if command -v pvesh &>/dev/null; then
        if PASSWORD="$PROXMOX_PASS" pvesh get /nodes/$PROXMOX_NODE/status --no-header 2>/dev/null; then
            print_status "SUCCESS" "Proxmox connection successful"
        else
            print_status "ERROR" "Failed to connect to Proxmox"
            return 1
        fi
    fi
    save_config
}

check_image_lock() {
    local img_file=$1
    local vm_name=$2
    if lsof "$img_file" 2>/dev/null | grep -q qemu-system; then
        print_status "WARN" "Image file $img_file is already in use by another QEMU process"
        local pid=$(lsof "$img_file" 2>/dev/null | grep qemu-system | awk '{print $2}' | head -1)
        if [[ -n "$pid" ]]; then
            if ps -p "$pid" -o cmd= | grep -q "$vm_name"; then
                read -p "$(print_status "INPUT" "Kill existing process and restart? (y/N): ")" kill_choice
                if [[ "$kill_choice" =~ ^[Yy]$ ]]; then
                    kill "$pid"
                    sleep 2
                    if kill -0 "$pid" 2>/dev/null; then
                        kill -9 "$pid"
                        print_status "WARN" "Forcefully terminated process $pid"
                    fi
                    return 0
                else
                    return 1
                fi
            else
                print_status "ERROR" "Another QEMU instance is using this image"
                return 1
            fi
        fi
        return 1
    fi
    
    local lock_file="${img_file}.lock"
    if [[ -f "$lock_file" ]]; then
        print_status "WARN" "Lock file found: $lock_file"
        if [[ $(find "$lock_file" -mmin +5 2>/dev/null) ]]; then
            read -p "$(print_status "INPUT" "Remove stale lock file? (y/N): ")" remove_lock
            if [[ "$remove_lock" =~ ^[Yy]$ ]]; then
                rm -f "$lock_file"
                print_status "SUCCESS" "Removed stale lock file"
                return 0
            else
                return 1
            fi
        fi
        return 1
    fi
    return 0
}

validate_input() {
    local type=$1
    local value=$2
    case $type in
        "number")
            if ! [[ "$value" =~ ^[0-9]+$ ]]; then print_status "ERROR" "Must be a number"; return 1; fi ;;
        "size")
            if ! [[ "$value" =~ ^[0-9]+[GgMm]$ ]]; then print_status "ERROR" "Must be a size with unit (e.g., 100G, 512M)"; return 1; fi ;;
        "port")
            if ! [[ "$value" =~ ^[0-9]+$ ]] || [ "$value" -lt 23 ] || [ "$value" -gt 65535 ]; then print_status "ERROR" "Must be a valid port number (23-65535)"; return 1; fi ;;
        "name")
            if ! [[ "$value" =~ ^[a-zA-Z0-9_-]+$ ]]; then print_status "ERROR" "Name can only contain letters, numbers, hyphens, and underscores"; return 1; fi ;;
        "username")
            if ! [[ "$value" =~ ^[a-z_][a-z0-9_-]*$ ]]; then print_status "ERROR" "Invalid username format"; return 1; fi ;;
        "vmid")
            if ! [[ "$value" =~ ^[0-9]+$ ]] || [ "$value" -lt 100 ] || [ "$value" -gt 999999999 ]; then print_status "ERROR" "VMID must be a number between 100 and 999999999"; return 1; fi ;;
    esac
    return 0
}

check_dependencies() {
    local deps=("qemu-system-x86_64" "wget" "qemu-img" "lsof")
    local missing_deps=()
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then missing_deps+=("$dep"); fi
    done
    if ! command -v "cloud-localds" &> /dev/null; then
        if ! command -v "genisoimage" &> /dev/null; then missing_deps+=("cloud-image-utils"); fi
    fi
    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_status "ERROR" "Missing dependencies: ${missing_deps[*]}"
        print_status "INFO" "On Ubuntu/Debian, try: sudo apt install qemu-system cloud-image-utils wget lsof genisoimage"
        exit 1
    fi
}

cleanup() {
    if [ -f "user-data" ]; then rm -f "user-data"; fi
    if [ -f "meta-data" ]; then rm -f "meta-data"; fi
}

get_vm_list() {
    find "$VM_DIR" -name "*.conf" -exec basename {} .conf \; 2>/dev/null | sort
}

get_proxmox_vms() {
    if [[ -n "$PROXMOX_HOST" ]] && command -v pvesh &>/dev/null; then
        pvesh get /nodes/$PROXMOX_NODE/qemu --no-header 2>/dev/null | jq -r '.[].vmid' 2>/dev/null || echo ""
    fi
}

load_vm_config() {
    local vm_name=$1
    local config_file="$VM_DIR/$vm_name.conf"
    if [[ -f "$config_file" ]]; then
        unset VM_NAME OS_TYPE CODENAME IMG_URL HOSTNAME USERNAME PASSWORD
        unset DISK_SIZE MEMORY CPUS SSH_PORT GUI_MODE PORT_FORWARDS IMG_FILE SEED_FILE CREATED USE_BRIDGE BRIDGE_IF
        unset PROXMOX_VMID PROXMOX_ENABLED
        source "$config_file"
        return 0
    else
        print_status "ERROR" "Configuration for VM '$vm_name' not found"
        return 1
    fi
}

save_vm_config() {
    local config_file="$VM_DIR/$VM_NAME.conf"
    cat > "$config_file" <<EOF
VM_NAME="$VM_NAME"
OS_TYPE="$OS_TYPE"
CODENAME="$CODENAME"
IMG_URL="$IMG_URL"
HOSTNAME="$HOSTNAME"
USERNAME="$USERNAME"
PASSWORD="$PASSWORD"
DISK_SIZE="$DISK_SIZE"
MEMORY="$MEMORY"
CPUS="$CPUS"
SSH_PORT="$SSH_PORT"
GUI_MODE="$GUI_MODE"
PORT_FORWARDS="$PORT_FORWARDS"
IMG_FILE="$IMG_FILE"
SEED_FILE="$SEED_FILE"
CREATED="$CREATED"
USE_BRIDGE="${USE_BRIDGE:-false}"
BRIDGE_IF="${BRIDGE_IF:-br0}"
PROXMOX_VMID="${PROXMOX_VMID:-}"
PROXMOX_ENABLED="${PROXMOX_ENABLED:-false}"
EOF
    print_status "SUCCESS" "Configuration saved"
}

download_image() {
    local url="$1"
    local output_file="$2"
    print_status "INFO" "Downloading image from $url..."
    if wget --progress=bar:force --no-check-certificate -q --show-progress "$url" -O "$output_file.tmp"; then
        mv "$output_file.tmp" "$output_file"
        return 0
    fi
    print_status "WARN" "wget failed, trying curl..."
    if curl -L --progress-bar "$url" -o "$output_file.tmp"; then
        mv "$output_file.tmp" "$output_file"
        return 0
    fi
    print_status "WARN" "curl failed, trying simple download..."
    if wget --no-check-certificate -q "$url" -O "$output_file.tmp"; then
        mv "$output_file.tmp" "$output_file"
        return 0
    fi
    return 1
}

create_new_vm() {
    echo -e "\n${C}╭──────────────────────── OS SELECTION ────────────────────────╮${NC}"
    local os_options=()
    local i=1
    for os in "${!OS_OPTIONS[@]}"; do
        printf "${C}│${NC}  ${Y}%2d)${NC} %-58s ${C}│${NC}\n" "$i" "$os"
        os_options[$i]="$os"
        ((i++))
    done
    echo -e "${C}╰──────────────────────────────────────────────────────────────╯${NC}\n"
    
    while true; do
        read -p "$(print_status "INPUT" "Enter your choice (1-${#OS_OPTIONS[@]}): ")" choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le ${#OS_OPTIONS[@]} ]; then
            local os="${os_options[$choice]}"
            IFS='|' read -r OS_TYPE CODENAME IMG_URL DEFAULT_HOSTNAME DEFAULT_USERNAME DEFAULT_PASSWORD <<< "${OS_OPTIONS[$os]}"
            break
        else
            print_status "ERROR" "Invalid selection. Try again."
        fi
    done

    while true; do
        read -p "$(print_status "INPUT" "Enter VM name (default: $DEFAULT_HOSTNAME): ")" VM_NAME
        VM_NAME="${VM_NAME:-$DEFAULT_HOSTNAME}"
        if validate_input "name" "$VM_NAME"; then
            if [[ -f "$VM_DIR/$VM_NAME.conf" ]]; then
                print_status "ERROR" "VM with name '$VM_NAME' already exists"
            else
                break
            fi
        fi
    done

    while true; do
        read -p "$(print_status "INPUT" "Enter hostname (default: $VM_NAME): ")" HOSTNAME
        HOSTNAME="${HOSTNAME:-$VM_NAME}"
        if validate_input "name" "$HOSTNAME"; then break; fi
    done

    while true; do
        read -p "$(print_status "INPUT" "Enter username (default: $DEFAULT_USERNAME): ")" USERNAME
        USERNAME="${USERNAME:-$DEFAULT_USERNAME}"
        if validate_input "username" "$USERNAME"; then break; fi
    done

    while true; do
        read -s -p "$(print_status "INPUT" "Enter password (default: $DEFAULT_PASSWORD): ")" PASSWORD
        PASSWORD="${PASSWORD:-$DEFAULT_PASSWORD}"
        echo
        if [ -n "$PASSWORD" ]; then break; else print_status "ERROR" "Password cannot be empty"; fi
    done

    while true; do
        read -p "$(print_status "INPUT" "Disk size (default: 20G): ")" DISK_SIZE
        DISK_SIZE="${DISK_SIZE:-20G}"
        if validate_input "size" "$DISK_SIZE"; then break; fi
    done

    while true; do
        read -p "$(print_status "INPUT" "Memory in MB (default: 2048): ")" MEMORY
        MEMORY="${MEMORY:-2048}"
        if validate_input "number" "$MEMORY"; then break; fi
    done

    while true; do
        read -p "$(print_status "INPUT" "Number of CPUs (default: 2): ")" CPUS
        CPUS="${CPUS:-2}"
        if validate_input "number" "$CPUS"; then break; fi
    done

    while true; do
        read -p "$(print_status "INPUT" "SSH Port (default: 2222): ")" SSH_PORT
        SSH_PORT="${SSH_PORT:-2222}"
        if validate_input "port" "$SSH_PORT"; then
            if ss -tln 2>/dev/null | grep -q ":$SSH_PORT "; then
                print_status "ERROR" "Port $SSH_PORT is already in use"
            else
                break
            fi
        fi
    done

    while true; do
        read -p "$(print_status "INPUT" "Enable GUI mode? (y/N): ")" gui_input
        GUI_MODE=false
        gui_input="${gui_input:-n}"
        if [[ "$gui_input" =~ ^[Yy]$ ]]; then 
            GUI_MODE=true; break
        elif [[ "$gui_input" =~ ^[Nn]$ ]]; then
            break
        else
            print_status "ERROR" "Please answer y or n"
        fi
    done

    read -p "$(print_status "INPUT" "Use bridge networking? (requires sudo, y/N): ")" use_bridge
    USE_BRIDGE=false
    if [[ "$use_bridge" =~ ^[Yy]$ ]]; then
        USE_BRIDGE=true
        read -p "$(print_status "INPUT" "Bridge interface (default: br0): ")" BRIDGE_IF
        BRIDGE_IF="${BRIDGE_IF:-br0}"
    fi

    PROXMOX_ENABLED=false
    if [[ -n "$PROXMOX_HOST" ]]; then
        read -p "$(print_status "INPUT" "Create on Proxmox too? (y/N): ")" proxmox_create
        if [[ "$proxmox_create" =~ ^[Yy]$ ]]; then
            PROXMOX_ENABLED=true
            while true; do
                read -p "$(print_status "INPUT" "Proxmox VMID (100-999999999): ")" PROXMOX_VMID
                if validate_input "vmid" "$PROXMOX_VMID"; then
                    if command -v pvesh &>/dev/null; then
                        if pvesh get /nodes/$PROXMOX_NODE/qemu/$PROXMOX_VMID/status --no-header 2>/dev/null; then
                            print_status "ERROR" "VMID $PROXMOX_VMID already exists on Proxmox"
                        else
                            break
                        fi
                    else
                        break
                    fi
                fi
            done
        fi
    fi

    read -p "$(print_status "INPUT" "Additional port forwards (e.g., 8080:80): ")" PORT_FORWARDS

    IMG_FILE="$VM_DIR/$VM_NAME.img"
    SEED_FILE="$VM_DIR/$VM_NAME-seed.iso"
    CREATED="$(date)"

    setup_vm_image
    
    if [[ "$PROXMOX_ENABLED" == true ]]; then
        create_proxmox_vm
    fi
    save_vm_config
}

setup_vm_image() {
    print_status "INFO" "Downloading and preparing image..."
    mkdir -p "$VM_DIR"
    if [[ -f "$IMG_FILE" ]]; then
        print_status "INFO" "Image file already exists. Skipping download."
    else
        if ! download_image "$IMG_URL" "$IMG_FILE"; then
            print_status "ERROR" "Failed to download image"
            if [[ "$CODENAME" == "trixie" ]]; then
                print_status "INFO" "Trying alternative Debian 13 URL..."
                ALT_URL="https://cloud.debian.org/images/cloud/trixie/latest/debian-13-generic-amd64.qcow2"
                if download_image "$ALT_URL" "$IMG_FILE"; then IMG_URL="$ALT_URL"; else exit 1; fi
            else
                exit 1
            fi
        fi
    fi
    
    if ! qemu-img info "$IMG_FILE" 2>/dev/null | grep -q "file format:"; then
        print_status "WARN" "Image format detection failed, attempting conversion..."
        if qemu-img convert -f raw -O qcow2 "$IMG_FILE" "$IMG_FILE.converted" 2>/dev/null; then mv "$IMG_FILE.converted" "$IMG_FILE"; fi
    fi
    
    if ! qemu-img resize "$IMG_FILE" "$DISK_SIZE" 2>/dev/null; then
        print_status "WARN" "Failed to resize disk image. Creating new image with specified size..."
        rm -f "$IMG_FILE"
        qemu-img create -f qcow2 "$IMG_FILE" "$DISK_SIZE"
    fi

    cat > user-data <<EOF
#cloud-config
hostname: $HOSTNAME
ssh_pwauth: true
disable_root: false
users:
  - name: $USERNAME
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    password: $(openssl passwd -6 "$PASSWORD" | tr -d '\n')
chpasswd:
  list: |
    root:$PASSWORD
    $USERNAME:$PASSWORD
  expire: false
EOF

    cat > meta-data <<EOF
instance-id: iid-$VM_NAME
local-hostname: $HOSTNAME
EOF

    if command -v cloud-localds &> /dev/null; then
        cloud-localds
