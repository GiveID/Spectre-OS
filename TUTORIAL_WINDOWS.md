# Spectre OS Build Tutorial — Windows

You’re on Windows. The ISO build requires **Arch Linux**, so you need a Linux environment first. Here are two main approaches.

---

## Option A: WSL2 + Distrobox (recommended)

### 1. Enable WSL2

Open **PowerShell as Administrator** and run:

```powershell
wsl --install
```

Restart your PC when prompted.

### 2. Install Ubuntu (if needed)

```powershell
wsl --install -d Ubuntu
```

### 3. Install Distrobox and Arch

Open **Ubuntu** from the Start menu (or `wsl -d Ubuntu`), then run:

```bash
sudo apt update && sudo apt install -y curl
curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/install | sh -s -- --prefix ~/.local
```

Add Distrobox to your PATH (add to `~/.bashrc`):

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

Create an Arch container:

```bash
distrobox create -n arch -i archlinux
distrobox enter arch
```

You're now inside Arch Linux.

### 4. Build Spectre OS

Your Windows `C:` drive is at `/mnt/c/`. Copy Spectre and build:

```bash
cp -r /mnt/c/Users/poopm/Downloads/Spectre ~/Spectre
cd ~/Spectre

sudo pacman -Sy --noconfirm archiso
chmod +x build.sh
./build.sh
```

The build takes about 15–30 minutes. The ISO will be in `~/Spectre/output/`.

### 5. Copy ISO back to Windows

```bash
cp output/spectre-os-*.iso /mnt/c/Users/poopm/Downloads/
```

You'll find it in `C:\Users\poopm\Downloads\`.

---

## Option B: Virtual machine (simpler setup)

### 1. Install a VM

- **VirtualBox**: https://www.virtualbox.org/wiki/Downloads  
- **VMware Workstation Player**: https://www.vmware.com/products/workstation-player.html  

### 2. Download Arch ISO

From https://archlinux.org/download/ — get the x86_64 ISO.

### 3. Create VM and install Arch

- Create a new VM (64-bit Linux)
- RAM: at least 4 GB
- Disk: at least 20 GB
- Attach the Arch ISO as the CD/DVD drive
- Boot and follow the [Arch install guide](https://wiki.archlinux.org/title/Installation_guide) (base install only)

After install and reboot:

```bash
sudo pacman -Syu
sudo pacman -S base-devel git archiso
```

### 4. Transfer Spectre files into the VM

- Shared folder, or
- SCP (if SSH is enabled), or
- Download in the VM:  
  `git clone <your-spectre-repo-url> ~/Spectre`

### 5. Build

```bash
cd ~/Spectre
chmod +x build.sh
./build.sh
```

Copy the ISO out via shared folder or SCP.

---

## Option C: GitHub Actions (easiest — no local Linux)

Push the Spectre folder to a GitHub repo. The workflow file is already included (`.github/workflows/build-iso.yml`).

1. Push the Spectre folder to a new GitHub repository
2. Go to the repo → **Actions** → **Build Spectre ISO**
3. Click **Run workflow** → **Run workflow**
4. When it finishes (15–30 min), open the workflow run and download the **spectre-iso** artifact

No WSL or VM required.

---

## Writing the ISO to USB (Windows)

After you have the ISO:

1. **Rufus** (recommended): https://rufus.ie/  
   - Device: your USB drive  
   - Boot selection: the Spectre ISO  
   - Start

2. **balenaEtcher**: https://etcher.balena.io/  
   - Select the ISO → select USB → Flash  

3. **Command line (PowerShell as Administrator)**:
   ```powershell
   # Find your USB drive letter (e.g. E:)
   Get-Disk
   # WARNING: This ERASES the USB!
   # Replace X with your USB disk number
   Write-Volume -SourcePath "C:\path\to\spectre-os-*.iso" -DriveLetter E
   ```

---

## Quick reference

| Step        | Command / Action                                      |
|------------|--------------------------------------------------------|
| Get Arch   | WSL2 + Distrobox, or VM, or GitHub Actions             |
| Build ISO  | `./build.sh` inside Spectre folder (on Arch)           |
| Get ISO    | Copy from `output/` or download artifact               |
| Write USB  | Rufus, balenaEtcher, or `Write-Volume`                 |

If anything fails, rerun `./build.sh` and check the terminal output for errors.
