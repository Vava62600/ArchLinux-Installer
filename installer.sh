#!/bin/bash

# Fonction pour sélectionner la langue
select_language() {
    locale=$(whiptail --menu "Select Language" 15 60 4 \
    "1" "English (US)" \
    "2" "Français (France)" \
    "3" "Español (España)" \
    "4" "Deutsch (Deutschland)" 3>&1 1>&2 2>&3)
    
    case $locale in
        1)
            echo "Selected Language: English (US)"
            export TEXTDOMAIN=arch-install-en_US
            ;;
        2)
            echo "Selected Language: Français (France)"
            export TEXTDOMAIN=arch-install-fr_FR
            ;;
        3)
            echo "Selected Language: Español (España)"
            export TEXTDOMAIN=arch-install-es_ES
            ;;
        4)
            echo "Selected Language: Deutsch (Deutschland)"
            export TEXTDOMAIN=arch-install-de_DE
            ;;
        *)
            echo "Invalid Language. Using default language."
            ;;
    esac
}

# Fonction pour tester la connectivité réseau
test_network() {
    # Tester la connectivité réseau
    ping -c 3 google.com
    if [ $? -eq 0 ]; then
        echo "Network Connectivity: OK"
    else
        echo "No Network Connectivity. Please check your internet connection."
        exit 1
    fi
}

# Fonction pour collecter les informations de l'utilisateur
collect_info() {
    # Demander le nom d'utilisateur
    username=$(whiptail --inputbox "Please enter a username :" 10 60 3>&1 1>&2 2>&3)
    
    # Demander le mot de passe de l'utilisateur
    password=$(whiptail --passwordbox "Please enter a password for user $username :" 10 60 3>&1 1>&2 2>&3)
    
    # Demander le nom de l'hôte
    hostname=$(whiptail --inputbox "Please enter the hostname :" 10 60 3>&1 1>&2 2>&3)
}

# Partitionnement du disque
partition_disk() {
    # Afficher la liste des disques disponibles
    lsblk -dplnx size -o name,size | grep -Ev "boot|rpmb|loop" | tac

    # Demander à l'utilisateur de choisir un disque
    selected_disk=$(whiptail --inputbox "Enter the disk to install Arch Linux (e.g., sda):" 10 60 3>&1 1>&2 2>&3)

    # Taille totale du disque
    total_size=$(lsblk -nlb -d -o size "/dev/$selected_disk" | awk '{print $1}')

    # Taille de chaque partition (en MiB)
    partition_size=$((total_size / 1024 / 1024))

    # Taille de la partition /
    root_size=$((20 * 1024)) # 20 Go en MiB

    # Taille de la partition /home
    home_size=$((partition_size - root_size))

    # Créer les partitions
    parted "/dev/$selected_disk" mklabel msdos
    parted "/dev/$selected_disk" mkpart primary ext4 1MiB "${root_size}MiB" # partition /
    parted "/dev/$selected_disk" mkpart primary ext4 "${root_size}MiB" 100% # partition /home ou autre

    # Formater les partitions
    mkfs.ext4 "/dev/${selected_disk}1" # partition /
    mkfs.ext4 "/dev/${selected_disk}2" # partition /home ou autre

    # Monter les partitions
    mount "/dev/${selected_disk}1" /mnt
    mkdir /mnt/home
    mount "/dev/${selected_disk}2" /mnt/home
}

# Fonction pour installer le système de base
install_base_system() {
    # Installer le système de base
    pacstrap /mnt base linux linux-firmware

    # Générer le fichier fstab
    genfstab -U /mnt >> /mnt/etc/fstab

    # Changer la racine du système
    arch-chroot /mnt /bin/bash -c "echo 'root:1234' | chpasswd"

    # Installer GRUB pour le secteur de démarrage
    pacman -Sy grub efibootmgr --noconfirm
    grub-install --target=x86_64-efi --efi-directory=/mnt --bootloader-id=grub
    grub-mkconfig -o /boot/grub/grub.cfg

    echo "Installation complete successfully."
}

# Fonction pour installer des paquets supplémentaires
install_additional_packages() {
    # Installer des paquets supplémentaires essentiels
    pacman -Sy sudo --noconfirm

    # Installer des paquets supplémentaires en fonction de l'interface graphique choisie (simulation)
    if whiptail --yesno "Do you want to install a graphical interface?" 10 60; then
        # Installez ici les paquets pour l'interface graphique choisie
        # Par exemple, pour GNOME :
        pacman -Sy gnome --noconfirm

        # Installer un thème préconfiguré pour GNOME (simulation)
        if [ "$gui_choice" == "gnome" ]; then
            # Installation du thème
            echo "Installing preconfigured theme for GNOME."
        fi
    fi

    # Installer d'autres paquets pour les applications de développement, multimédia, etc. (simulation)
    if whiptail --yesno "Do you want to install additional packages?" 10 60; then
        # Applications de développement
        pacman -Sy code git --noconfirm

        # Applications multimédia avec snapd (simulation)
        snap install spotify
        snap install rhythmbox
        snap install audacity
        snap install pulseaudio
    fi
}

# Fonction pour terminer l'installation
finish_installation() {
    # Mettre à jour tous les paquets et les caches
    pacman -Syu --noconfirm

    # Demander à l'utilisateur s'il souhaite redémarrer le système
    if whiptail --yesno "Installation complete. Do you want to reboot the system?" 10 60; then
        # Mettre à jour GRUB
        grub-mkconfig -o /boot/grub/grub.cfg

        # Démonter le disque sélectionné
        umount /mnt

        # Éjecter le DVD/USB
        eject

        # Redémarrer le système
        reboot
    fi
}

# Afficher un message d'accueil
whiptail --msgbox "Welcome to the Arch Linux Installation Assistant." 10 60

# Sélectionner la langue
select_language

# Tester la connectivité réseau
test_network

# Collecter les informations de l'utilisateur
collect_info

# Partitionner le disque
partition_disk

# Installer le système de base
install_base_system

# Installer des paquets supplémentaires
install_additional_packages

# Terminer l'installation
finish_installation
