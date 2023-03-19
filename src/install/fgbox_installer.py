#!/usr/bin/python3

import archinstall
from archinstall import User
import pathlib

# TODO: Migrate to config
ADDITIONAL_PACKAGES=[
    # X
    "xorg",
    "xorg-xinit",
    "xterm",

    # gfx
    "mesa",
    "xf86-video-intel",

    # audio
    "alsa-utils",
    "alsa-tools",
    "pulseaudio",

    # dev
    "vim",
    "python",

    # gaming for gamers
    "ttf-liberation",
    "steam",

    # virtualization (REMOVEME)
    "hyperv",
    "open-vm-tools",
    "qemu-guest-agent",
    "virtualbox-guest-utils-nox",

    # network
    "networkmanager",
]

if archinstall.arguments.get('help', None):
    archinstall.log(' - Optional filesystem type via --filesystem=<fs type>')
    archinstall.log(' - Optional systemd network via --network')
    archinstall.log()

archinstall.arguments['harddrive'] = archinstall.select_disk(archinstall.all_blockdevices())
if archinstall.arguments['harddrive']:
    archinstall.arguments['harddrive'].keep_partitions = False

    print(f"Formatting {archinstall.arguments['harddrive']} in ", end='')
    with archinstall.Filesystem(archinstall.arguments['harddrive'], archinstall.GPT) as fs:
        if archinstall.has_uefi() is False:
            mode = archinstall.MBR

        for drive in archinstall.arguments.get('harddrives', []):
            if archinstall.arguments.get('disk_layouts', {}).get(drive.path):
                with archinstall.Filesystem(drive, mode) as fs:
                    fs.load_layout(archinstall.arguments['disk_layouts'][drive.path])

mountpoint = archinstall.storage.get('MOUNT_POINT', '/mnt')
with archinstall.Installer(mountpoint) as installation:

    if archinstall.arguments.get('disk_layouts'):
        installation.mount_ordered_layout(archinstall.arguments['disk_layouts'])

    for partition in installation.partitions:
        if partition.mountpoint == installation.target + '/boot':
            if partition.size <= 0.19: # in GB
                raise archinstall.DiskError(
                        "The selected /boot partition in use is not large enough " 
                        "to properly install a boot loader. Please resize it to at "
                        "least 200MB and re-run the installation.")

    # to generate a fstab directory holder. Avoids an error on exit and at the same 
    # time checks the procedure
    target = pathlib.Path(f"{mountpoint}/etc/fstab")
    if not target.parent.exists():
        target.parent.mkdir(parents=True)

    installation.set_hostname(archinstall.arguments.get('hostname', 'arch-fgbox'))
    installation.add_bootloader(bootloader='grub-install')
    installation.enable_multilib_repository()
    installation.copy_iso_network_config(enable_services=True)
    installation.activate_time_synchronization()
    installation.add_additional_packages(ADDITIONAL_PACKAGES)
    installation.install_profile('minimal')
