# MSI Dragon Center For Linux

<div align="center">

<img src="assets/images/dragon.png" width="170" style="display: block; margin: 0 auto;">

A modern Flutter application for controlling MSI laptop features with a beautiful, intuitive interface.

[![Flutter](https://img.shields.io/badge/Flutter-3.0.0+-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0.0+-blue.svg)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

</div>


<div align="center" style="margin: 2rem 0">  
  <img src="https://github.com/user-attachments/assets/bc3c2dc8-9c44-4548-9d6b-9ab086a2fb63" width="45%" style="margin: 0.5rem">  
  <img src="https://github.com/user-attachments/assets/7ed1552b-3d1b-4ab1-af73-6cf60dea7c19" width="45%" style="margin: 0.5rem"> 
  <br>  
  <img src="https://github.com/user-attachments/assets/cf790dd4-8fa1-4e2c-91b6-5574acf34c35" width="45%" style="margin: 0.5rem">  
  <img src="https://github.com/user-attachments/assets/b3288dbf-8e7c-4812-93ea-d5123bdcd5b7" width="45%" style="margin: 0.5rem">  
</div>


## 📑 Table of Contents
- [Features](#-features)
- [Technical Architecture](#-technical-architecture)
  - [Core Components](#core-components)
  - [EC Communication](#ec-communication-architecture)
  - [Fan Control System](#fan-control-system)
- [Technical Implementation](#-technical-implementation)
  - [Fan Control](#fan-control-implementation)
  - [Configuration Management](#configuration-management)
  - [Key Features](#key-technical-features)
- [Prerequisites](#-prerequisites)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Project Structure](#-project-structure)
- [Contributing](#-contributing)
- [License](#-license)
- [Acknowledgments](#-acknowledgments)

## 🌟 Features

### 🎮 Fan Control
- Customizable fan speed profiles
- Auto and Advanced speed modes
- CPU generation-specific optimizations
- Real-time fan speed monitoring
- Temperature-based fan curve control
- Multiple fan zones support (CPU, GPU)

### ⚙️ System Configuration
- Universal and Custom profile support
- Persistent configuration storage
- Profile switching capabilities

### 🎨 Modern UI/UX
- Responsive design
- Intuitive controls
- Real-time monitoring dashboard

## 🛠️ Technical Architecture

### Core Components

```mermaid
graph TD
    subgraph Application Layer
        A[Dragon Center App]
        C[Config Manager]
        D[Fan Control]
        B[Setup Service]
    end

    subgraph Hardware Layer
        H[EC Helper]
        I[System Integration]
        J[Fan Profiles]
        K[Temperature Monitoring]
        L[Speed Control]
    end

    subgraph Storage Layer
        F[Shared Preferences]
        G[Configuration Files]
        M[Profile Storage]
    end

    A --> B
    A --> C
    A --> D
    
    B --> F
    C --> G
    D --> H
    
    D --> J
    D --> K
    D --> L
    
    C --> M
    
    class A,B,C,D app;
    class H,I,J,K,L hw;
    class F,G,M storage;
```

### EC Communication Architecture

```mermaid
graph LR
    subgraph Application
        A[Fan Control Service]
        B[Temperature Monitor]
        C[Battery Service]
    end

    subgraph EC Interface
        D[EC Helper]
        E[Register Manager]
        F[Error Handler]
    end

    subgraph Hardware Registers
        G[Fan Control Registers]
        H[Temperature Registers]
        I[Battery Control Registers]
    end

    A --> D
    B --> D
    C --> D

    D --> E
    E --> F

    E --> G
    E --> H
    E --> I
    
    class A,B,C app;
    class D,E,F interface;
    class G,H,I hw;
```

### Fan Control System

```mermaid
sequenceDiagram
    participant UI as User Interface
    participant FC as Fan Controller
    participant EC as EC Helper
    participant HW as Hardware

    Note over UI,HW: Fan Speed Update Process

    UI->>FC: Set Fan Speed
    activate FC
    FC->>FC: Validate Speed Range
    FC->>EC: Write Speed Value
    activate EC
    EC->>EC: Validate Register Access
    EC->>HW: Update Hardware Register
    activate HW
    HW-->>EC: Confirm Update
    deactivate HW
    EC-->>FC: Return Status
    deactivate EC
    FC-->>UI: Update Display
    deactivate FC

    Note over UI,HW: Temperature Monitoring Process

    loop Every 500ms
        HW->>EC: Temperature Update
        EC->>FC: Process Temperature
        FC->>FC: Calculate Required Speed
        FC->>EC: Adjust Speed if Needed
        EC->>HW: Update Fan Speed
    end
```

## 🔧 Technical Implementation

### Fan Control Implementation

#### Speed Control
- PWM-based control (0-100 range)
- RPM monitoring (0-5000 RPM)
- Temperature-based adjustment
- Profile-based management

#### Temperature Monitoring
- Real-time sensor reading (500ms intervals)
- Temperature thresholds:
  - Warning: 60°C
  - Critical: 80°C
- Automatic fan speed adjustment

### Configuration Management

```mermaid
graph LR
    A[User Input] --> B[Config Manager]
    B --> C[Validation]
    C --> D[Storage]
    D --> E[Profile]
    E --> F[Hardware]
```

### Key Technical Features

#### Hardware Communication
- Direct EC register access
- Low-level hardware control
- Real-time monitoring
- Hardware state validation

## 📋 Prerequisites

### Flutter Development Environment
- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Linux development tools:
  ```bash
  sudo apt update
  sudo apt install build-essential cmake ninja-build pkg-config libgtk-3-dev liblzma-dev
  ```

### System Requirements
- Linux system with MSI laptop
- Required system permissions for EC access
- D-Bus system service
- System tray support
- Hardware-specific drivers
- ACPI EC Driver ([acpi_ec](https://github.com/agnath18K/acpi_ec))


## 🚀 Installation

### 1. Install ACPI EC Driver

First, install the required ACPI EC driver:

```bash
# Clone the acpi_ec repository
git clone https://github.com/agnath18K/acpi_ec.git
cd acpi_ec

# Install build dependencies
sudo apt update
sudo apt install build-essential linux-headers-$(uname -r)

# Install the driver
sudo ./install.sh

# Add your user to the ec group (required for EC access)
sudo usermod -a -G ec $USER
```

**Note:** You'll need to log out and back in for the group changes to take effect.

### 2. Install Dragon Center

1. Clone the repository:
    ```bash
    git clone https://github.com/agnath18K/dragon_center_linux.git
    cd dragon_center_linux
    ```

2. Build and install the package:
    ```bash
    sudo dpkg -i debian/packages/dragoncenter_1.0.0_amd64.deb
    ```

3. Launch the application:
    ```bash
    sudo /usr/local/lib/dragoncenter/dragon
    ```

**Note:** Ensure all prerequisites are met before installation.

### Troubleshooting

If you encounter any issues with EC access:

1. Verify the acpi_ec driver is loaded:
```bash
lsmod | grep acpi_ec
```

2. Check driver status:
```bash
dmesg | grep acpi_ec
```

3. Verify device file permissions:
```bash
ls -l /dev/ec*
```

4. Check your group membership:
```bash
groups
```

## 🔧 Configuration

### Profile Types

#### Universal Profile
- Pre-configured settings
- Automatic temperature management

#### Custom Profile
- User-defined fan curves
- Temperature thresholds
- Custom monitoring options

### Advanced Settings

#### Fan Control
- Custom fan curves
- Temperature thresholds
- Minimum/maximum speeds


## 🏗️ Project Structure

```
lib/
├── core/
│   ├── presentation/    # UI components
│   │   ├── pages/      # Application pages
│   │   ├── widgets/    # Reusable widgets
│   │   └── themes/     # UI themes
│   ├── services/       # Business logic
│   │   ├── setup/      # Setup services
│   │   ├── fan/        # Fan control
│   │   └── system/     # System integration
│   └── utils/          # Helper functions
│       ├── ec/         # EC communication
│       ├── config/     # Configuration
│       └── logging/    # Logging system
├── models/             # Data models
│   ├── fan/           # Fan-related models
│   ├── system/        # System models
│   └── config/        # Configuration models
├── shared/            # Shared components
│   ├── widgets/       # Common widgets
│   ├── constants/     # Constants
│   └── types/         # Type definitions
└── main.dart          # Application entry point
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Development Guidelines

- Follow Flutter's style guide
- Add tests for new features
- Update documentation
- Maintain backward compatibility
- Handle errors gracefully

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- MSI for their laptop hardware
- Flutter team for the amazing framework
- All contributors who have helped shape this project
- Open-source community for inspiration and tools

---

<div align="center">
Made with ❤️ for MSI laptop users
</div>
