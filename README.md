# FlatCAM Beta - Fedora Installer & Patch Set

**Automated setup script to install FlatCAM Beta (8.994+) on modern Fedora Linux systems (Python 3.12+ / Wayland / KDE).**

![Python](https://img.shields.io/badge/Python-3.12-blue) ![Platform](https://img.shields.io/badge/Platform-Fedora_Linux-blue) ![License](https://img.shields.io/badge/License-MIT-green)

## 📋 Overview

FlatCAM is an essential open-source CAM software for PCB milling. However, the current Beta version (which includes significant improvements over stable releases) relies on deprecated libraries and older Python versions.

Running FlatCAM on a modern Fedora workstation presents several challenges:
1.  **Python 3.12+ Incompatibility:** The removal of the `imp` module breaks the original source code.
2.  **Dependency Hell:** Conflicts between system-level C++ libraries (GDAL, Cairo) and Python bindings.
3.  **Numpy 2.0 Breakage:** Recent updates to Numpy removed functions (`Inf`) used by FlatCAM.
4.  **Dark Mode Issues:** On KDE Plasma/Wayland, the interface renders incorrectly (black icons on dark backgrounds), making it unusable.

**This repository solves all these issues automatically.** It creates an isolated environment, hot-patches the source code, and creates a desktop entry.

---

## 🚀 Key Features

* **Automated Dependency Management:** Installs necessary system headers (`dnf`) and compiles Python bindings (`pip`) matching the system's GDAL version.
* **Source Code Hot-Patching:**
    * Replaces deprecated `find_module` calls with modern `importlib` (Python 3.12 fix).
    * Injects `QPalette` overrides to force a usable Light Theme on Dark Mode systems.
* **Version Pinning:** Ensures strict compatibility by pinning `numpy<2` and `gdal==[system_version]`.
* **Desktop Integration:** Generates a `.desktop` file and a launch script to execute the app with specific environment variables (`QT_STYLE_OVERRIDE`).

---

## 🛠️ Installation

### Prerequisites
* Fedora Linux (Tested on Fedora 43, KDE Plasma).
* `git` installed.

### Quick Start
Open your terminal and run:

```bash
# 1. Clone this repository
git clone [https://github.com/TU_USUARIO/FlatCAM-Fedora-Installer.git](https://github.com/TU_USUARIO/FlatCAM-Fedora-Installer.git)
cd FlatCAM-Fedora-Installer

# 2. Make the script executable
chmod +x install.sh

# 3. Run the installer
./install.sh
