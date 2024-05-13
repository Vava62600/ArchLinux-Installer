#!/bin/bash

# Fonction pour afficher une barre de progression
progress_bar() {
    local duration=$1
    local increment=0.2
    local elapsed=0
    local progress=0
    while ((elapsed < duration)); do
        ((elapsed += 1))
        ((progress = elapsed * 100 / duration))
        echo $progress
        sleep $increment
    done
}

# Fonction pour choisir la langue
choose_language() {
    echo "Choisir la langue :"
    progress_bar 5 &
    progress_pid=$!
    # Afficher les options de langue
    # Supposons que les options soient en anglais et en français pour cet exemple
    select lang in "English" "Français"; do
        case $lang in
            "English")
                echo "Language selected: English"
                # Configurer la langue en anglais
                ;;
            "Français")
                echo "Langue sélectionnée : Français"
                # Configurer la langue en français
                ;;
            *) echo "Invalid option. Please choose again.";;
        esac
        break
    done
    kill $progress_pid
}

# Fonction pour configurer le clavier
configure_keyboard() {
    echo "Configurer le clavier :"
    progress_bar 5 &
    progress_pid=$!
    # Afficher les options de configuration de clavier
    # Supposons que les options soient en QWERTY et en AZERTY pour cet exemple
    select layout in "QWERTY" "AZERTY"; do
        case $layout in
            "QWERTY")
                echo "Keyboard layout selected: QWERTY"
                # Configurer le clavier en QWERTY
                ;;
            "AZERTY")
                echo "Disposition du clavier sélectionnée : AZERTY"
                # Configurer le clavier en AZERTY
                ;;
            *) echo "Option invalide. Veuillez choisir à nouveau.";;
        esac
        break
    done
    kill $progress_pid
}

# Fonction pour configurer le réseau
configure_network() {
    echo "Configurer le réseau :"
    progress_bar 5 &
    progress_pid=$!
    # Demander à l'utilisateur de choisir une option pour configurer le réseau
    echo "Voulez-vous configurer le réseau automatiquement, manuellement ou ne pas le faire ?"
    select option in "Automatiquement" "Manuellement" "Ne pas configurer"; do
        case $option in
            "Automatiquement")
                echo "Configuration du réseau automatique sélectionnée."
                ;;
            "Manuellement")
                echo "Configuration du réseau manuelle sélectionnée."
                ;;
            "Ne pas configurer")
                echo "Vous avez choisi de ne pas configurer le réseau. Vous ne pourrez pas installer Arch Linux sans connexion Internet."
                ;;
            *) echo "Option invalide. Veuillez choisir à nouveau.";;
        esac
        break
    done
    kill $progress_pid
}

# Fonction pour créer les utilisateurs
create_users() {
    echo "Créer des utilisateurs :"
    progress_bar 5 &
    progress_pid=$!
    # Demander à l'utilisateur de créer des utilisateurs et des mots de passe
    read -p "Entrez le nom d'utilisateur : " username
    read -sp "Entrez le mot de passe pour $username : " password
    echo ""
    read -sp "Entrez le mot de passe pour root : " root_password
    echo ""
    # Créer l'utilisateur et définir le mot de passe
    useradd -m $username
    echo "$username:$password" | chpasswd
    echo "Utilisateur créé : $username"
    echo "Mot de passe pour root défini."
    kill $progress_pid
}

# Fonction pour configurer l'horloge
configure_clock() {
    echo "Configurer l'horloge :"
    progress_bar 5 &
    progress_pid=$!
    # Configurer l'horloge
    # Supposons que vous utilisiez timedatectl pour cela
    timedatectl set-timezone Europe/Paris
    echo "Horloge configurée sur le fuseau horaire Europe/Paris."
    kill $progress_pid
}

# Fonction pour détecter les disques
detect_disks() {
    echo "Détection des disques :"
    progress_bar 5 &
    progress_pid=$!
    # Détecter les disques disponibles
    lsblk
    kill $progress_pid
}

# Fonction pour partitionner les disques
partition_disks() {
    echo "Partitionnement des disques :"
    progress_bar 10 &
    progress_pid=$!
    # Afficher les disques disponibles et leurs tailles
    lsblk
    # Demander à l'utilisateur de choisir un disque
    read -p "Entrez le disque à partitionner (par exemple /dev/sda) : " disk
    # Partitionner le disque selon les spécifications
    parted $disk mklabel gpt
    parted -a optimal $disk mkpart primary ext4 1MiB 30GiB
    parted -a optimal $disk mkpart primary linux-swap 30GiB 38GiB
    parted -a optimal $disk mkpart primary ext4 38GiB 100%
    parted $disk set 1 boot on
    parted $disk print
    kill $progress_pid
}

# Fonction pour installer le système de base
install_base_system() {
    echo "Installation du système de base :"
    progress_bar 20 &
    progress_pid=$!
    # Installer les paquets de base
    pacstrap /mnt base linux linux-firmware
    kill $progress_pid
    echo "Installation du système de base terminée."
}

# Fonction pour configurer les outils
configure_tools() {
    echo "Configuration des outils :"
    progress_bar 5 &
    progress_pid=$!
    # Configurer les outils nécessaires
    # Par exemple, mettre à jour les dépôts et installer sudo
    pacman -Sy sudo --noconfirm
    kill $progress_pid
}

# Fonction pour installer GNOME
install_gnome() {
    echo "Installation de GNOME :"
    progress_bar 20 &
    progress_pid=$!
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
    kill $progress_pid
}

# Fonction pour installer d'autres logiciels
install_additional_software() {
    echo "Installer d'autres logiciels :"
    progress_bar 20 &
    progress_pid=$!
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
    kill $progress_pid
}

# Fonction pour installer GRUB
install_grub() {
    echo "Installation de GRUB :"
    progress_bar 20 &
    progress_pid=$!
    # Installer GRUB sur le disque dur
    arch-chroot /mnt /bin/bash -c "pacman -S --noconfirm grub"
    arch-chroot /mnt /bin/bash -c "grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB"
    arch-chroot /mnt /bin/bash -c "grub-mkconfig -o /boot/grub/grub.cfg"
    kill $progress_pid
}

# Fonction pour nettoyer et redémarrer le système
clean_and_restart() {
    echo "Nettoyage du système :"
    progress_bar 5 &
    progress_pid=$!
    # Nettoyer les caches et les applications inutiles
    arch-chroot /mnt /bin/bash -c "pacman -Sc --noconfirm"
    echo "Le nettoyage est terminé."
    kill $progress_pid

    # Demander à l'utilisateur s'il veut redémarrer
    read -p "Voulez-vous redémarrer le système maintenant ? (o/n) : " choice
    case "$choice" in 
        o|O) 
            echo "Redémarrage en cours..."
            umount -R /mnt
            reboot ;;
        n|N) 
            echo "Vous avez choisi de ne pas redémarrer le système." ;;
        *) 
            echo "Choix invalide. Le système ne sera pas redémarré." ;;
    esac
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
