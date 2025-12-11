#!/bin/bash

# ==============================================================================
# FlatCAM Beta Installer for Fedora (KDE/Wayland support)
# Author: Erick Ruiz (2025)
# Description: Automates the installation of FlatCAM Beta, applies compatibility
#              patches for Python 3.12, and fixes Dark Mode issues on Fedora KDE
# ==============================================================================

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# ------------------------------------------------------------------------------
# CONFIGURATION VARIABLES
# ------------------------------------------------------------------------------
PATCH_REPO_URL="https://github.com/kingKzK/FlatCAM-FedoraKDE-Installer.git"

FLATCAM_REPO_URL="https://bitbucket.org/marius_stanciu/flatcam_beta"
INSTALL_DIR="$HOME/FlatCAM_Beta"
TEMP_PATCH_DIR="/tmp/flatcam_patches_temp"

echo -e "${BLUE}=== Starting FlatCAM (Beta) Setup for Fedora ===${NC}"
echo -e "${BLUE}=== Wrappper & Patches by Erick Ruiz ===${NC}"

# ------------------------------------------------------------------------------
# 1. INSTALL SYSTEM DEPENDENCIES
# ------------------------------------------------------------------------------
echo -e "${GREEN}[1/7] Installing Fedora system dependencies...${NC}"
# Note: python3.12-devel and gdal-devel are critical for compilation
sudo dnf install -y python3.12 python3.12-devel git gcc gcc-c++ \
    redhat-rpm-config gdal-devel cairo-devel pkg-config \
    gobject-introspection-devel cairo-gobject-devel \
    python3-tkinter

# ------------------------------------------------------------------------------
# 2. CLONE FLATCAM REPOSITORY
# ------------------------------------------------------------------------------
if [ -d "$INSTALL_DIR" ]; then
    echo -e "${RED}Directory $INSTALL_DIR already exists. Cleaning up for fresh install...${NC}"
    rm -rf "$INSTALL_DIR"
fi

echo -e "${GREEN}[2/7] Cloning FlatCAM source code (\"old\" Beta Branch)...${NC}"
# Cloning the source code from the active Bitbucket repo
git clone "$FLATCAM_REPO_URL" "$INSTALL_DIR"

# ------------------------------------------------------------------------------
# 3. FETCH PATCHES FROM GITHUB
# ------------------------------------------------------------------------------
echo -e "${GREEN}[3/7] Downloading compatibility patches...${NC}"
# We clone your repo to a temp folder to extract the modified files
if [ -d "$TEMP_PATCH_DIR" ]; then
    rm -rf "$TEMP_PATCH_DIR"
fi
git clone "$PATCH_REPO_URL" "$TEMP_PATCH_DIR"

# ------------------------------------------------------------------------------
# 4. SETUP PYTHON ENVIRONMENT
# ------------------------------------------------------------------------------
echo -e "${GREEN}[4/7] Creating Python 3.12 Virtual Environment...${NC}"
cd "$INSTALL_DIR"
python3.12 -m venv .venv
source .venv/bin/activate

echo -e "${BLUE}   -> Upgrading pip core...${NC}"
pip install --upgrade pip setuptools wheel

# ------------------------------------------------------------------------------
# 5. INSTALL PYTHON REQUIREMENTS
# ------------------------------------------------------------------------------
echo -e "${GREEN}[5/7] Installing Python libraries (This may take a minute)...${NC}"

# We use the requirements.txt downloaded from YOUR repo, not the old one from FlatCAM
# This ensures gdal==3.11.5 and numpy<2 are used automatically.
if [ -f "$TEMP_PATCH_DIR/requirements.txt" ]; then
    pip install -r "$TEMP_PATCH_DIR/requirements.txt"
else
    echo -e "${RED}Error: requirements.txt not found in the patch repository!${NC}"
    exit 1
fi

# ------------------------------------------------------------------------------
# 6. APPLY CODE PATCHES
# ------------------------------------------------------------------------------
echo -e "${GREEN}[6/7] Applying code patches (Fixing Python 3.12 & Dark Mode)...${NC}"

# Patch 1: Main execution file (Visual fixes)
cp "$TEMP_PATCH_DIR/patches/FlatCAM.py" "$INSTALL_DIR/FlatCAM.py"

# Patch 2: Import fixes for tclCommands
# Note: Ensure your file in github is named 'tclCommands_init.py' inside the patches folder
cp "$TEMP_PATCH_DIR/patches/tclCommands_init.py" "$INSTALL_DIR/tclCommands/__init__.py"

# Clean up temp files
rm -rf "$TEMP_PATCH_DIR"

# ------------------------------------------------------------------------------
# 7. CREATE LAUNCHERS
# ------------------------------------------------------------------------------
echo -e "${GREEN}[7/7] Creating desktop shortcut...${NC}"

# Create internal run script
cat <<EOF > "$INSTALL_DIR/run_flatcam.sh"
#!/bin/bash
cd "$INSTALL_DIR"
source .venv/bin/activate
# Force fusion style to ensure icons are visible on Dark Mode
export QT_STYLE_OVERRIDE=fusion
# Suppress SyntaxWarnings from Python 3.12
python -W ignore FlatCAM.py
EOF

chmod +x "$INSTALL_DIR/run_flatcam.sh"

# Create .desktop file for system menu
mkdir -p ~/.local/share/applications
cat <<EOF > ~/.local/share/applications/flatcam.desktop
[Desktop Entry]
Version=1.0
Name=FlatCAM Beta
Comment=PCB CAM Software
Exec=$INSTALL_DIR/run_flatcam.sh
Icon=$INSTALL_DIR/assets/linux/icon.png
Terminal=false
Type=Application
Categories=Engineering;Electronics;Development;
EOF

echo -e "${GREEN}=== Installation Successful! ===${NC}"
echo -e "You can now launch 'FlatCAM Beta' from your application menu."
