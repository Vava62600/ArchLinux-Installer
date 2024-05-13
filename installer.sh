#!/bin/bash

# Fonction pour choisir la langue
choose_language() {
    language=$(zenity --list --title="Choisir la langue" --text="Choisir la langue :" --column="Code" --column="Langue" "1" "English" "2" "Français")
    if [ $? -eq 0 ]; then
        if [ $language -eq 1 ]; then
            echo "Language selected: English"
            # Configurer la langue en anglais
        elif [ $language -eq 2 ]; then
            echo "Langue sélectionnée : Français"
            # Configurer la langue en français
        fi
    else
        echo "Langue non sélectionnée."
    fi
}

# Fonction pour configurer le clavier
configure_keyboard() {
    layout=$(zenity --list --title="Configurer le clavier" --text="Configurer le clavier :" --column="Code" --column="Disposition" "1" "QWERTY" "2" "AZERTY")
    if [ $? -eq 0 ]; then
        if [ $layout -eq 1 ]; then
            echo "Keyboard layout selected: QWERTY"
            # Configurer le clavier en QWERTY
        elif [ $layout -eq 2 ]; then
            echo "Disposition du clavier sélectionnée : AZERTY"
            # Configurer le clavier en AZERTY
        fi
    else
        echo "Disposition du clavier non sélectionnée."
    fi
}

# Fonction pour configurer le réseau
configure_network() {
    option=$(zenity --list --title="Configurer le réseau" --text="Configurer le réseau :" --column="Code" --column="Option" "1" "Automatiquement" "2" "Manuellement" "3" "Ne pas configurer")
    if [ $? -eq 0 ]; then
        case $option in
            1)
                echo "Configuration du réseau automatique sélectionnée."
                ;;
            2)
                echo "Configuration du réseau manuelle sélectionnée."
                ;;
            3)
                echo "Vous avez choisi de ne pas configurer le réseau. Vous ne pourrez pas installer Arch Linux sans connexion Internet."
                ;;
        esac
    else
        echo "Option réseau non sélectionnée."
    fi
}

# Fonction pour créer les utilisateurs
create_users() {
    username=$(zenity --entry --title="Créer des utilisateurs" --text="Entrez le nom d'utilisateur :")
    password=$(zenity --password --title="Créer des utilisateurs" --text="Entrez le mot de passe pour $username :")
    root_password=$(zenity --password --title="Créer des utilisateurs" --text="Entrez le mot de passe pour root :")
    if [ $? -eq 0 ]; then
        # Créer l'utilisateur et définir le mot de passe
        useradd -m $username
        echo "$username:$password" | chpasswd
        echo "Utilisateur créé : $username"
        echo "Mot de passe pour root défini."
    else
        echo "Création d'utilisateur annulée."
    fi
}

# Fonction pour configurer l'horloge
configure_clock() {
    echo "Configurer l'horloge :"
    # Configurer l'horloge
    # Supposons que vous utilisiez timedatectl pour cela
    timedatectl set-timezone Europe/Paris
    echo "Horloge configurée sur le fuseau horaire Europe/Paris."
}

# Fonction pour détecter les disques
detect_disks() {
    echo "Détection des disques :"
    # Détecter les disques disponibles
    lsblk
}

# Fonction pour partitionner les disques
partition_disks() {
    echo "Partitionnement des disques :"
    # Afficher les disques disponibles et leurs tailles
    lsblk
    # Demander à l'utilisateur de choisir un disque
    disk=$(zenity --entry --title="Partitionner les disques" --text="Entrez le disque à partitionner (par exemple /dev/sda) :")
    if [ $? -eq 0 ]; then
        # Partitionner le disque selon les spécifications
        parted $disk mklabel gpt
        parted -a optimal $disk mkpart primary ext4 1MiB 30GiB
        parted -a optimal $disk mkpart primary linux-swap 30GiB 38GiB
        parted -a optimal $disk mkpart primary ext4 38GiB 100%
        parted $disk set 1 boot on
        parted $disk print
    else
        echo "Partitionnement annulé."
    fi
}

# Fonction pour installer le système de base
install_base_system() {
    echo "Installation du système de base :"
    # Installer les paquets de base
    pacstrap /mnt base linux linux-firmware
}

# Fonction pour configurer les outils
configure_tools() {
    echo "Configuration des outils :"
    # Configurer les outils nécessaires
    # Par exemple, mettre à jour les dépôts et installer sudo
    pacman -Sy sudo --noconfirm
}

# Fonction pour installer GNOME
install_gnome() {
    echo "Installation de GNOME :"
    # Installer GNOME et les extensions
    pacstrap /mnt gnome gnome-tweaks gnome-shell-extensions --noconfirm
    # Activer Dash to Dock
    arch-chroot /mnt /bin/bash -c "gnome-extensions enable dash-to-dock@micxgx.gmail.com"
    # Configurer Dash to Dock
    arch-chroot /mnt /bin/bash -c "gsettings set org.gnome.shell.extensions.dash-to-dock dock-position BOTTOM"
    arch-chroot /mnt /bin/bash -c "gsettings set org.gnome.shell.extensions.dash-to-dock transparency-mode FIXED"
    arch-chroot /mnt /bin/bash -c "gsettings set org.gnome.shell.extensions.dash-to-dock background-opacity 0.8"
    arch-chroot /mnt /bin/bash -c "gsettings set org.gnome.shell.extensions.dash-to-dock unity-backlit-items true"
    arch-chroot /mnt /bin/bash -c "gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize-or-previews'"
    arch-chroot /mnt /bin/bash -c "gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 64"
    # Redémarrer GNOME Shell pour appliquer les modifications
    arch-chroot /mnt /bin/bash -c "busctl --user call org.gnome.Shell /org/gnome/Shell org.gnome.Shell Eval s 'Meta.restart(\"Restarting…\")'"
}

# Fonction pour installer d'autres logiciels
install_additional_software() {
    echo "Installer d'autres logiciels :"
    # Demander à l'utilisateur de choisir les logiciels à installer
    echo "Choisissez les logiciels à installer :"
    echo "Dans la Rubrique Développement"
    select dev_tool in "Git" "Oracle VM Virtualbox" "VS Code" "Quitter"; do
        case $dev_tool in
            "Git")
                echo "Installation de Git..."
                pacstrap /mnt git --noconfirm
                ;;
            "Oracle VM Virtualbox")
                echo "Installation de Oracle VM Virtualbox..."
                pacstrap /mnt virtualbox --noconfirm
                ;;
            "VS Code")
                echo "Installation de VS Code..."
                pacstrap /mnt code --noconfirm
                ;;
            "Quitter")
                break
                ;;
            *) echo "Option invalide. Veuillez choisir à nouveau.";;
        esac
    done
}

# Fonction pour installer GRUB
install_grub() {
    echo "Installation de GRUB :"
    # Installer GRUB sur le disque dur
    arch-chroot /mnt /bin/bash -c "pacman -S --noconfirm grub"
    arch-chroot /mnt /bin/bash -c "grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB"
    arch-chroot /mnt /bin/bash -c "grub-mkconfig -o /boot/grub/grub.cfg"
}

# Fonction pour nettoyer et redémarrer le système
clean_and_restart() {
    echo "Nettoyage et redémarrage du système :"
    # Nettoyer les caches et les applications inutiles
    arch-chroot /mnt /bin/bash -c "pacman -Sc --noconfirm"
    # Redémarrer le système
    echo "Le système va redémarrer..."
    umount -R /mnt
    reboot
}

# Exécuter les fonctions dans l'ordre
choose_language
configure_keyboard
configure_network
create_users
configure_clock
detect_disks
partition_disks
install_base_system
configure_tools
install_gnome
install_additional_software
install_grub
clean_and_restart
