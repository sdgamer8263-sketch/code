#!/bin/bash
set -euo pipefail

# ==========================================
# SKA HOST MULTI-TOOL (VM MANAGER - KVM)
# STYLE: NEON CYBERPUNK + DOUBLE BORDERS
# BACKEND: QEMU + KVM NATIVE
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
    local text="${C}  [SYS] Establishing secure connection to SKA HOST KVM Engine...${NC}"
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

# Main Dashboard UI (Fixed 70-Column Alignment)
show_dashboard() {
    clear
    
    # Compress uptime to fit nicely (e.g. "1 days, 2 hours" -> "1d 2h")
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
    echo -e "${C}║${NC}                  ${Y}⚡ KVM VIRTUAL MACHINE ENGINE ⚡${NC}                  ${C}║${NC}"
    echo -e "${C}╠════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${C}║${NC} ${BLINK}${G}● ONLINE${NC} ${DG}│${NC} ⏱️ ${W}${PAD_UPTIME}${NC} ${DG}│${NC} 🧠 ${W}${PAD_CPU}${NC} ${DG}│${NC} 💾 ${W}${PAD_RAM}${NC}      ${C}║${NC}"
    echo -e "${C}╚════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# 🎨 Re-styled print_status for Cyberpunk Theme
print_status() {
    local type=$1
    local message=$2
    
    case $type in
        "INFO") echo -e "  ${C}[SYS]${NC} $message" ;;
        "WARN") echo -e "  ${Y}[WARN]${NC} $message" ;;
        "ERROR") echo -e "  ${R}[ERR]${NC} $message" ;;
        "SUCCESS") echo -e "  ${G}[OK]${NC} $message" ;;
        "INPUT") echo -e "  ${Y}root@skahost${W}:~${C}/vm-manager${NC}# $message" ;;
        *) echo "[$type] $message" ;;
    esac
}


# ==========================================
# 🛠️ BACKEND LOGIC (UNCHANGED)
# ==========================================

check_image_lock() {
    local img_file=$1
    local vm_name=$2
    
    if lsof "$img_file" 2>/dev/null | grep -q qemu-system; then
        print_status "WARN" "Image file $img_file is already in use by another QEMU process"
        local pid=$(lsof "$img_file" 2>/dev/null | grep qemu-system | awk '{print $2}' | head -1)
        if [[ -n "$pid" ]]; then
            print_status "INFO" "Process ID using the image: $pid"
            if ps -p "$pid" -o cmd= | grep -q "$vm_name"; then
                print_status "INFO" "This appears to be the same VM already running"
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
            print_status "WARN" "Lock file appears stale (older than 5 minutes)"
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
        "number") if ! [[ "$value" =~ ^[0-9]+$ ]]; then print_status "ERROR" "Must be a number"; return 1; fi ;;
        "size") if ! [[ "$value" =~ ^[0-9]+[GgMm]$ ]]; then print_status "ERROR" "Must be a size with unit (e.g., 100G, 512M)"; return 1; fi ;;
        "port") if ! [[ "$value" =~ ^[0-9]+$ ]] || [ "$value" -lt 23 ] || [ "$value" -gt 65535 ]; then print_status "ERROR" "Must be a valid port number (23-65535)"; return 1; fi ;;
        "name") if ! [[ "$value" =~ ^[a-zA-Z0-9_-]+$ ]]; then print_status "ERROR" "VM name can only contain letters, numbers, hyphens, and underscores"; return 1; fi ;;
        "username") if ! [[ "$value" =~ ^[a-z_][a-z0-9_-]*$ ]]; then print_status "ERROR" "Username must start with a letter or underscore, and contain only letters, numbers, hyphens, and underscores"; return 1; fi ;;
    esac
    return 0
}

check_dependencies() {
    local deps=("qemu-system-x86_64" "wget" "cloud-localds" "qemu-img" "lsof")
    local missing_deps=()
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then missing_deps+=("$dep"); fi
    done
    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_status "ERROR" "Missing dependencies: ${missing_deps[*]}"
        print_status "INFO" "On Ubuntu/Debian, try: sudo apt install qemu-system cloud-image-utils wget lsof"
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

load_vm_config() {
    local vm_name=$1
    local config_file="$VM_DIR/$vm_name.conf"
    if [[ -f "$config_file" ]]; then
        unset VM_NAME OS_TYPE CODENAME IMG_URL HOSTNAME USERNAME PASSWORD
        unset DISK_SIZE MEMORY CPUS SSH_PORT GUI_MODE PORT_FORWARDS IMG_FILE SEED_FILE CREATED
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
EOF
    print_status "SUCCESS" "Configuration saved"
}

create_new_vm() {
    print_status "INFO" "Creating a new VM"
    
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
            if [[ -f "$VM_DIR/$VM_NAME.conf" ]]; then print_status "ERROR" "VM with name '$VM_NAME' already exists"; else break; fi
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
        read -p "$(print_status "INPUT" "Enable GUI mode? (y/N, default: n): ")" gui_input
        GUI_MODE=false
        gui_input="${gui_input:-n}"
        if [[ "$gui_input" =~ ^[Yy]$ ]]; then GUI_MODE=true; break
        elif [[ "$gui_input" =~ ^[Nn]$ ]]; then break
        else print_status "ERROR" "Please answer y or n"; fi
    done

    read -p "$(print_status "INPUT" "Additional port forwards (e.g., 8080:80): ")" PORT_FORWARDS

    IMG_FILE="$VM_DIR/$VM_NAME.img"
    SEED_FILE="$VM_DIR/$VM_NAME-seed.iso"
    CREATED="$(date)"

    setup_vm_image
    save_vm_config
}

setup_vm_image() {
    print_status "INFO" "Downloading and preparing image..."
    mkdir -p "$VM_DIR"
    
    if [[ -f "$IMG_FILE" ]]; then
        print_status "INFO" "Image file already exists. Skipping download."
    else
        print_status "INFO" "Downloading image from $IMG_URL..."
        if ! wget --progress=bar:force "$IMG_URL" -O "$IMG_FILE.tmp"; then
            print_status "ERROR" "Failed to download image from $IMG_URL"
            exit 1
        fi
        mv "$IMG_FILE.tmp" "$IMG_FILE"
    fi
    
    if ! qemu-img resize "$IMG_FILE" "$DISK_SIZE" 2>/dev/null; then
        print_status "WARN" "Failed to resize disk image. Creating new image with specified size..."
        rm -f "$IMG_FILE"
        qemu-img create -f qcow2 -F qcow2 -b "$IMG_FILE" "$IMG_FILE.tmp" "$DISK_SIZE" 2>/dev/null || \
        qemu-img create -f qcow2 "$IMG_FILE" "$DISK_SIZE"
        if [ -f "$IMG_FILE.tmp" ]; then mv "$IMG_FILE.tmp" "$IMG_FILE"; fi
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

    if ! cloud-localds "$SEED_FILE" user-data meta-data; then
        print_status "ERROR" "Failed to create cloud-init seed image"
        exit 1
    fi
    
    print_status "SUCCESS" "VM '$VM_NAME' created successfully."
    print_status "INFO" "Login with: username=$USERNAME, password=$PASSWORD"
    print_status "INFO" "SSH: ssh -p $SSH_PORT $USERNAME@localhost"
}

start_vm() {
    local vm_name=$1
    if load_vm_config "$vm_name"; then
        if ! check_image_lock "$IMG_FILE" "$vm_name"; then
            print_status "ERROR" "Cannot start VM: Image file is locked by another process"
            read -p "$(print_status "INPUT" "Force kill all QEMU processes using this image? (y/N): ")" force_kill
            if [[ "$force_kill" =~ ^[Yy]$ ]]; then
                pkill -f "qemu-system.*$IMG_FILE"; sleep 2
                if pgrep -f "qemu-system.*$IMG_FILE" >/dev/null; then pkill -9 -f "qemu-system.*$IMG_FILE"; fi
                print_status "SUCCESS" "Terminated processes using the image"
                rm -f "${IMG_FILE}.lock" 2>/dev/null
            else
                return 1
            fi
        fi
        
        if is_vm_running "$vm_name"; then
            print_status "WARN" "VM '$vm_name' is already running"
            read -p "$(print_status "INPUT" "Stop and restart? (y/N): ")" restart_choice
            if [[ "$restart_choice" =~ ^[Yy]$ ]]; then stop_vm "$vm_name"; sleep 2; else return 1; fi
        fi
        
        print_status "INFO" "Starting VM: $vm_name"
        print_status "INFO" "SSH: ssh -p $SSH_PORT $USERNAME@localhost"
        
        if [[ ! -f "$IMG_FILE" ]]; then print_status "ERROR" "VM image file not found: $IMG_FILE"; return 1; fi
        if [[ ! -f "$SEED_FILE" ]]; then print_status "WARN" "Seed file not found, recreating..."; setup_vm_image; fi
        
        local qemu_cmd=(
            qemu-system-x86_64 -enable-kvm -m "$MEMORY" -smp "$CPUS" -cpu host
            -drive "file=$IMG_FILE,format=qcow2,if=virtio"
            -drive "file=$SEED_FILE,format=raw,if=virtio"
            -boot order=c -device virtio-net-pci,netdev=n0
            -netdev "user,id=n0,hostfwd=tcp::$SSH_PORT-:22"
        )

        if [[ -n "$PORT_FORWARDS" ]]; then
            IFS=',' read -ra forwards <<< "$PORT_FORWARDS"
            for forward in "${forwards[@]}"; do
                IFS=':' read -r host_port guest_port <<< "$forward"
                qemu_cmd+=(-device "virtio-net-pci,netdev=n${#qemu_cmd[@]}")
                qemu_cmd+=(-netdev "user,id=n${#qemu_cmd[@]},hostfwd=tcp::$host_port-:$guest_port")
            done
        fi

        if [[ "$GUI_MODE" == true ]]; then
            qemu_cmd+=(-vga virtio -display gtk,gl=on); print_status "INFO" "Starting in GUI mode..."
        else
            qemu_cmd+=(-nographic -serial mon:stdio); print_status "INFO" "Press Ctrl+A then X to exit QEMU console"
        fi

        qemu_cmd+=(-device virtio-balloon-pci -object rng-random,filename=/dev/urandom,id=rng0 -device virtio-rng-pci,rng=rng0)

        print_status "INFO" "Starting QEMU..."
        if ! "${qemu_cmd[@]}"; then
            print_status "ERROR" "Failed to start VM."
            rm -f "${IMG_FILE}.lock" 2>/dev/null
            return 1
        fi
        print_status "INFO" "VM $vm_name has been shut down"
    fi
}

delete_vm() {
    local vm_name=$1
    print_status "WARN" "This will permanently delete VM '$vm_name' and all its data!"
    read -p "$(print_status "INPUT" "Are you sure? (y/N): ")" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if load_vm_config "$vm_name"; then
            if is_vm_running "$vm_name"; then print_status "WARN" "VM is currently running. Stopping it first..."; stop_vm "$vm_name"; sleep 2; fi
            rm -f "$IMG_FILE" "$SEED_FILE" "$VM_DIR/$vm_name.conf" "${IMG_FILE}.lock" 2>/dev/null
            print_status "SUCCESS" "VM '$vm_name' has been deleted"
        fi
    fi
}

show_vm_info() {
    local vm_name=$1
    if load_vm_config "$vm_name"; then
        echo -e "\n${C}╭──────────────────────── VM INFORMATION ────────────────────────╮${NC}"
        printf "${C}│${NC}  %-20s : %-41s ${C}│${NC}\n" "Name" "$vm_name"
        printf "${C}│${NC}  %-20s : %-41s ${C}│${NC}\n" "OS" "$OS_TYPE"
        printf "${C}│${NC}  %-20s : %-41s ${C}│${NC}\n" "Login" "$USERNAME / ****"
        printf "${C}│${NC}  %-20s : %-41s ${C}│${NC}\n" "Specs" "${CPUS} Core, ${MEMORY}MB RAM, $DISK_SIZE"
        printf "${C}│${NC}  %-20s : %-41s ${C}│${NC}\n" "Network" "User Mode (Port $SSH_PORT)"
        printf "${C}│${NC}  %-20s : %-41s ${C}│${NC}\n" "Port Forwards" "${PORT_FORWARDS:-None}"
        
        local state="Stopped"
        if is_vm_running "$vm_name"; then state="Running"; fi
        printf "${C}│${NC}  %-20s : %-41s ${C}│${NC}\n" "Status" "$state"
        echo -e "${C}╰──────────────────────────────────────────────────────────────╯${NC}\n"
    fi
}

is_vm_running() {
    local vm_name=$1
    if pgrep -f "qemu-system.*$vm_name" >/dev/null; then return 0; fi
    if load_vm_config "$vm_name" 2>/dev/null; then
        if pgrep -f "qemu-system.*$IMG_FILE" >/dev/null; then return 0; fi
    fi
    return 1
}

stop_vm() {
    local vm_name=$1
    if load_vm_config "$vm_name"; then
        if is_vm_running "$vm_name"; then
            print_status "INFO" "Stopping VM: $vm_name"
            pkill -f "qemu-system.*$IMG_FILE"; sleep 2
            if is_vm_running "$vm_name"; then
                print_status "WARN" "Forcing termination..."
                pkill -9 -f "qemu-system.*$IMG_FILE"; sleep 1
            fi
            rm -f "${IMG_FILE}.lock" 2>/dev/null
            if is_vm_running "$vm_name"; then print_status "ERROR" "Failed to stop VM"; return 1; else print_status "SUCCESS" "VM $vm_name stopped"; fi
        else
            print_status "INFO" "VM $vm_name is not running"
            rm -f "${IMG_FILE}.lock" 2>/dev/null
        fi
    fi
}

edit_vm_config() {
    local vm_name=$1
    if load_vm_config "$vm_name"; then
        print_status "INFO" "Editing VM: $vm_name"
        while true; do
            echo -e "\n${Y}  [1] Hostname     [4] SSH Port    [7] Memory"
            echo -e "  [2] Username     [5] GUI Mode    [8] CPU Count"
            echo -e "  [3] Password     [6] Ports       [9] Disk Size"
            echo -e "  [0] Back${NC}\n"
            
            read -p "$(print_status "INPUT" "Enter choice: ")" edit_choice
            
            case $edit_choice in
                1) read -p "$(print_status "INPUT" "New hostname: ")" HOSTNAME ;;
                2) read -p "$(print_status "INPUT" "New username: ")" USERNAME ;;
                3) read -p "$(print_status "INPUT" "New password: ")" PASSWORD ;;
                4) read -p "$(print_status "INPUT" "New SSH port: ")" SSH_PORT ;;
                5) read -p "$(print_status "INPUT" "GUI Mode (true/false): ")" GUI_MODE ;;
                6) read -p "$(print_status "INPUT" "Port Forwards: ")" PORT_FORWARDS ;;
                7) read -p "$(print_status "INPUT" "Memory (MB): ")" MEMORY ;;
                8) read -p "$(print_status "INPUT" "CPUs: ")" CPUS ;;
                9) read -p "$(print_status "INPUT" "Disk Size: ")" DISK_SIZE ;;
                0) return 0 ;;
                *) print_status "ERROR" "Invalid option"; continue ;;
            esac
            
            if [[ "$edit_choice" -eq 1 || "$edit_choice" -eq 2 || "$edit_choice" -eq 3 ]]; then
                print_status "INFO" "Updating cloud-init configuration..."
                setup_vm_image
            fi
            save_vm_config
        done
    fi
}

resize_vm_disk() {
    local vm_name=$1
    if load_vm_config "$vm_name"; then
        if is_vm_running "$vm_name"; then print_status "ERROR" "Cannot resize disk while VM is running"; return 1; fi
        print_status "INFO" "Current disk size: $DISK_SIZE"
        read -p "$(print_status "INPUT" "Enter new disk size (e.g., 50G): ")" new_disk_size
        if validate_input "size" "$new_disk_size"; then
            if qemu-img resize "$IMG_FILE" "$new_disk_size"; then
                DISK_SIZE="$new_disk_size"; save_vm_config
                print_status "SUCCESS" "Disk resized successfully to $new_disk_size"
            else
                print_status "ERROR" "Failed to resize disk"
            fi
        fi
    fi
}

show_vm_performance() {
    local vm_name=$1
    if load_vm_config "$vm_name"; then
        if is_vm_running "$vm_name"; then
            local qemu_pid=$(pgrep -f "qemu-system.*$IMG_FILE")
            if [[ -n "$qemu_pid" ]]; then
                echo -e "\n${G}--- QEMU STATS ---${NC}"
                ps -p "$qemu_pid" -o pid,%cpu,%mem,sz,rss,vsz
                echo -e "\n${B}--- MEMORY ---${NC}"
                free -h
            fi
        fi
    fi
}

fix_vm_issues() {
    local vm_name=$1
    if load_vm_config "$vm_name"; then
        echo -e "  [1] Remove locks    [2] Recreate seed"
        echo -e "  [3] Recreate Config [4] Kill stuck procs"
        read -p "$(print_status "INPUT" "Choice: ")" fix_choice
        case $fix_choice in
            1) rm -f "${IMG_FILE}.lock" "${IMG_FILE}"*.lock 2>/dev/null; print_status "SUCCESS" "Locks removed" ;;
            2) rm -f "$SEED_FILE"; setup_vm_image ;;
            3) save_vm_config; print_status "SUCCESS" "Configuration recreated" ;;
            4) pkill -9 -f "qemu-system.*$IMG_FILE" 2>/dev/null; print_status "SUCCESS" "Killed stuck procs" ;;
        esac
    fi
}

# ==========================================
# ⚙️ MAIN SYSTEM LOOP
# ==========================================

trap cleanup EXIT
check_dependencies

VM_DIR="${VM_DIR:-$HOME/vms}"
mkdir -p "$VM_DIR"

declare -A OS_OPTIONS=(
    ["Ubuntu 22.04"]="ubuntu|jammy|https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img|ubuntu22|ubuntu|ubuntu"
    ["Ubuntu 24.04"]="ubuntu|noble|https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img|ubuntu24|ubuntu|ubuntu"
    ["Debian 11"]="debian|bullseye|https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-generic-amd64.qcow2|debian11|debian|debian"
    ["Debian 12"]="debian|bookworm|https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2|debian12|debian|debian"
    ["Debian 13"]="debian|trixie|https://cloud.debian.org/images/cloud/trixie/daily/latest/debian-13-generic-amd64-daily.qcow2|debian13|debian|debian"
    ["Fedora 40"]="fedora|40|https://download.fedoraproject.org/pub/fedora/linux/releases/40/Cloud/x86_64/images/Fedora-Cloud-Base-40-1.14.x86_64.qcow2|fedora40|fedora|fedora"
    ["CentOS Stream 9"]="centos|stream9|https://cloud.centos.org/centos/9-stream/x86_64/images/CentOS-Stream-GenericCloud-9-latest.x86_64.qcow2|centos9|centos|centos"
    ["AlmaLinux 9"]="almalinux|9|https://repo.almalinux.org/almalinux/9/cloud/x86_64/images/AlmaLinux-9-GenericCloud-latest.x86_64.qcow2|almalinux9|alma|alma"
    ["Rocky Linux 9"]="rockylinux|9|https://download.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-GenericCloud.latest.x86_64.qcow2|rocky9|rocky|rocky"
)

boot_sequence

while true; do
    show_dashboard
    
    local vms=($(get_vm_list))
    local vm_count=${#vms[@]}
    
    if [ $vm_count -gt 0 ]; then
        echo -e "${DG}╭─── ${W}LOCAL VMs DETECTED ${DG}───────────────────────────────────────────────╮${NC}"
        for i in "${!vms[@]}"; do
            local status="[OFFLINE]"
            local sc="${DG}"
            if is_vm_running "${vms[$i]}"; then
                status="[ONLINE] "
                sc="${G}"
            fi
            printf "${DG}│${NC}  ${P}%2d)${NC} %-45s ${sc}%-10s${NC} ${DG}│${NC}\n" $((i+1)) "${vms[$i]}" "$status"
        done
        echo -e "${DG}╰────────────────────────────────────────────────────────────────────╯${NC}"
        echo ""
    fi
    
    # PERFECTLY ALIGNED 70-COLUMN MENU BOX
    echo -e "${DG}╭───────────────────── ${W}VIRTUAL MACHINE MANAGER ${DG}──────────────────────╮${NC}"
    echo -e "${DG}│${NC}                                                                    ${DG}│${NC}"
    echo -e "${DG}│${NC}      ${P}[1]${NC} 🆕 Create New VM         ${P}[6]${NC} 🗑️  Delete VM                 ${DG}│${NC}"
    echo -e "${DG}│${NC}      ${P}[2]${NC} 🚀 Start VM              ${P}[7]${NC} 📈 Resize VM Disk             ${DG}│${NC}"
    echo -e "${DG}│${NC}      ${P}[3]${NC} 🛑 Stop VM               ${P}[8]${NC} 📊 Show VM Performance        ${DG}│${NC}"
    echo -e "${DG}│${NC}      ${P}[4]${NC} 📊 Show VM Info          ${P}[9]${NC} 🔧 Fix VM Issues              ${DG}│${NC}"
    echo -e "${DG}│${NC}      ${P}[5]${NC} ✏️  Edit VM Config                                         ${DG}│${NC}"
    echo -e "${DG}│${NC}                                                                    ${DG}│${NC}"
    echo -e "${DG}├────────────────────────────────────────────────────────────────────┤${NC}"
    echo -e "${DG}│${NC}                         ${R}[0] ❌ SYSTEM EXIT${NC}                         ${DG}│${NC}"
    echo -e "${DG}╰────────────────────────────────────────────────────────────────────╯${NC}"
    echo ""
    
    read -p "$(print_status "INPUT" "Select Task (0-9): ")" choice
    
    case $choice in
        1) create_new_vm ;;
        2) 
            if [ $vm_count -gt 0 ]; then
                read -p "$(print_status "INPUT" "Enter VM number to start: ")" vm_num
                if [[ "$vm_num" =~ ^[0-9]+$ ]] && [ "$vm_num" -ge 1 ] && [ "$vm_num" -le $vm_count ]; then start_vm "${vms[$((vm_num-1))]}"; fi
            fi ;;
        3) 
            if [ $vm_count -gt 0 ]; then
                read -p "$(print_status "INPUT" "Enter VM number to stop: ")" vm_num
                if [[ "$vm_num" =~ ^[0-9]+$ ]] && [ "$vm_num" -ge 1 ] && [ "$vm_num" -le $vm_count ]; then stop_vm "${vms[$((vm_num-1))]}"; fi
            fi ;;
        4) 
            if [ $vm_count -gt 0 ]; then
                read -p "$(print_status "INPUT" "Enter VM number to show info: ")" vm_num
                if [[ "$vm_num" =~ ^[0-9]+$ ]] && [ "$vm_num" -ge 1 ] && [ "$vm_num" -le $vm_count ]; then show_vm_info "${vms[$((vm_num-1))]}"; fi
            fi ;;
        5) 
            if [ $vm_count -gt 0 ]; then
                read -p "$(print_status "INPUT" "Enter VM number to edit: ")" vm_num
                if [[ "$vm_num" =~ ^[0-9]+$ ]] && [ "$vm_num" -ge 1 ] && [ "$vm_num" -le $vm_count ]; then edit_vm_config "${vms[$((vm_num-1))]}"; fi
            fi ;;
        6) 
            if [ $vm_count -gt 0 ]; then
                read -p "$(print_status "INPUT" "Enter VM number to delete: ")" vm_num
                if [[ "$vm_num" =~ ^[0-9]+$ ]] && [ "$vm_num" -ge 1 ] && [ "$vm_num" -le $vm_count ]; then delete_vm "${vms[$((vm_num-1))]}"; fi
            fi ;;
        7) 
            if [ $vm_count -gt 0 ]; then
                read -p "$(print_status "INPUT" "Enter VM number to resize disk: ")" vm_num
                if [[ "$vm_num" =~ ^[0-9]+$ ]] && [ "$vm_num" -ge 1 ] && [ "$vm_num" -le $vm_count ]; then resize_vm_disk "${vms[$((vm_num-1))]}"; fi
            fi ;;
        8) 
            if [ $vm_count -gt 0 ]; then
                read -p "$(print_status "INPUT" "Enter VM number for performance: ")" vm_num
                if [[ "$vm_num" =~ ^[0-9]+$ ]] && [ "$vm_num" -ge 1 ] && [ "$vm_num" -le $vm_count ]; then show_vm_performance "${vms[$((vm_num-1))]}"; fi
            fi ;;
        9) 
            if [ $vm_count -gt 0 ]; then
                read -p "$(print_status "INPUT" "Enter VM number to fix issues: ")" vm_num
                if [[ "$vm_num" =~ ^[0-9]+$ ]] && [ "$vm_num" -ge 1 ] && [ "$vm_num" -le $vm_count ]; then fix_vm_issues "${vms[$((vm_num-1))]}"; fi
            fi ;;
        0) 
            echo -e ""
            type_effect "${R}  [SYS] Terminating processes...${NC}" 0.03
            type_effect "${DG}  [SYS] Goodbye!${NC}" 0.05
            exit 0 
            ;;
        *) print_status "ERROR" "Invalid option" ;;
    esac
    
    echo -en "\n  ${Y}root@skahost${W}:~${DG}/sys/pause${NC} (Press ENTER) "
    read -r
done
