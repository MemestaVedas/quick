#!/bin/bash

# Installation script for setting up a complete desktop environment
# Created based on user's configuration

# Function to print status messages
print_status() {
    echo -e "\n[*] $1..."
}

# Function to check if a command succeeded
check_success() {
    if [ $? -eq 0 ]; then
        echo "Success: $1"
    else
        echo "Error: $1 failed"
        exit 1
    fi
}

# Update system first
print_status "Updating system"
sudo pacman -Syu --noconfirm
check_success "System update"

# Install base packages
print_status "Installing base packages"
sudo pacman -S --noconfirm \
    git \
    zsh \
    neovim \
    kitty \
    nodejs \
    npm \
    sddm \
    pavucontrol \
    qt5-quickcontrols2 \
    qt5-graphicaleffects \
    qt5-svg \
    ntfs-3g \
    wofi \
    xclip \
    hyprpaper
check_success "Base package installation"

# Install AUR helper (yay)
print_status "Installing yay AUR helper"
if ! command -v yay &> /dev/null; then
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ..
    rm -rf yay
fi
check_success "Yay installation"

# Install AUR packages
print_status "Installing AUR packages"
yay -S --noconfirm \
    visual-studio-code-bin \
    hyprland-git

# Install fonts
print_status "Installing fonts"
sudo pacman -S --noconfirm \
    ttf-jetbrains-mono \
    ttf-nerd-fonts-symbols

# Setup Oh My Zsh
print_status "Setting up Oh My Zsh"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install Zsh plugins
print_status "Installing Zsh plugins"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# Setup NvChad
print_status "Setting up NvChad"
git clone https://github.com/NvChad/starter ~/.config/nvim

# Setup SDDM theme
print_status "Setting up SDDM theme"
sudo git clone https://github.com/MemestaVedas/luka-sddm /usr/share/sddm/themes/luka-sddm
sudo chmod -R u+rw /usr/share/sddm/themes/luka-sddm

# Create necessary config directories
print_status "Creating config directories"
mkdir -p ~/.config/{hypr,kitty,wofi}

# Configure SDDM
print_status "Configuring SDDM"
sudo tee /usr/lib/sddm/sddm.conf.d/default.conf > /dev/null << EOL
[Theme]
Current=luka-sddm
EOL

# Enable SDDM service
print_status "Enabling SDDM service"
sudo systemctl enable sddm

# Enable NetworkManager
print_status "Enabling NetworkManager"
sudo systemctl enable NetworkManager

# Create basic Hyprland config
print_status "Creating basic Hyprland config"
cat > ~/.config/hypr/hyprland.conf << EOL
# See https://wiki.hyprland.org/Configuring/Monitors/
monitor=,preferred,auto,auto

# Execute your favorite apps at launch
exec-once = hyprpaper
exec-once = waybar

# Source a file (multi-file configs)
# source = ~/.config/hypr/myColors.conf

# Set programs that you use
\$terminal = kitty
\$menu = wofi --show drun

# Some default env vars.
env = XCURSOR_SIZE,24

# For all categories, see https://wiki.hyprland.org/Configuring/Variables/
input {
    kb_layout = us
    follow_mouse = 1
    touchpad {
        natural_scroll = yes
    }
    sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
}

general {
    gaps_in = 5
    gaps_out = 20
    border_size = 2
    col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
    col.inactive_border = rgba(595959aa)
    layout = dwindle
}

decoration {
    rounding = 10
    blur = yes
    blur_size = 3
    blur_passes = 1
    blur_new_optimizations = on
}

animations {
    enabled = yes
    bezier = myBezier, 0.05, 0.9, 0.1, 1.05
    animation = windows, 1, 7, myBezier
    animation = windowsOut, 1, 7, default, popin 80%
    animation = border, 1, 10, default
    animation = fade, 1, 7, default
    animation = workspaces, 1, 6, default
}

dwindle {
    pseudotile = yes
    preserve_split = yes
}

master {
    new_is_master = true
}

gestures {
    workspace_swipe = off
}

# Example windowrule v1
# windowrule = float, ^(kitty)$
# Example windowrule v2
# windowrulev2 = float,class:^(kitty)$,title:^(kitty)$

# Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
bind = SUPER, RETURN, exec, \$terminal
bind = SUPER, Q, killactive, 
bind = SUPER, M, exit, 
bind = SUPER, E, exec, dolphin
bind = SUPER, V, togglefloating, 
bind = SUPER, R, exec, \$menu
bind = SUPER, P, pseudo, # dwindle
bind = SUPER, J, togglesplit, # dwindle

# Move focus with mainMod + arrow keys
bind = SUPER, left, movefocus, l
bind = SUPER, right, movefocus, r
bind = SUPER, up, movefocus, u
bind = SUPER, down, movefocus, d

# Switch workspaces with mainMod + [0-9]
bind = SUPER, 1, workspace, 1
bind = SUPER, 2, workspace, 2
bind = SUPER, 3, workspace, 3
bind = SUPER, 4, workspace, 4
bind = SUPER, 5, workspace, 5
bind = SUPER, 6, workspace, 6
bind = SUPER, 7, workspace, 7
bind = SUPER, 8, workspace, 8
bind = SUPER, 9, workspace, 9
bind = SUPER, 0, workspace, 10

# Move active window to a workspace with mainMod + SHIFT + [0-9]
bind = SUPER SHIFT, 1, movetoworkspace, 1
bind = SUPER SHIFT, 2, movetoworkspace, 2
bind = SUPER SHIFT, 3, movetoworkspace, 3
bind = SUPER SHIFT, 4, movetoworkspace, 4
bind = SUPER SHIFT, 5, movetoworkspace, 5
bind = SUPER SHIFT, 6, movetoworkspace, 6
bind = SUPER SHIFT, 7, movetoworkspace, 7
bind = SUPER SHIFT, 8, movetoworkspace, 8
bind = SUPER SHIFT, 9, movetoworkspace, 9
bind = SUPER SHIFT, 0, movetoworkspace, 10

# Scroll through existing workspaces with mainMod + scroll
bind = SUPER, mouse_down, workspace, e+1
bind = SUPER, mouse_up, workspace, e-1

# Move/resize windows with mainMod + LMB/RMB and dragging
bindm = SUPER, mouse:272, movewindow
bindm = SUPER, mouse:273, resizewindow
EOL

# Create basic kitty config
print_status "Creating basic kitty config"
cat > ~/.config/kitty/kitty.conf << EOL
font_family JetBrains Mono Nerd Font
bold_font auto
italic_font auto
bold_italic_font auto
font_size 12.0
background_opacity 0.85
EOL

# Set Zsh as default shell
print_status "Setting Zsh as default shell"
chsh -s $(which zsh)

print_status "Installation complete! Please reboot your system."
echo "After reboot:"
echo "1. Run 'p10k configure' to setup Powerlevel10k"
echo "2. Edit ~/.zshrc to enable the installed plugins"
echo "3. Configure Hyprland to your preferences"
