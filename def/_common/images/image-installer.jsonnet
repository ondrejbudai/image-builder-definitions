function(request) {
  module_platform_id: 'platform:f%s' % request.version,
  repositories: std.get(request, 'repositories', [
    // default repositories
    {
      id: 'fedora',
      baseurl: 'https://rpmrepo.osbuild.org/v2/mirror/public/f39/f39-x86_64-fedora-20231109',
    },
  ]),
  packages: {
    build: {
      include: [
        'btrfs-progs',
        'dnf',
        'dosfstools',
        'e2fsprogs',
        'grub2-pc',
        'policycoreutils',
        'python3-iniparse',
        'python3-pyyaml',
        'qemu-img',
        'rpm-ostree',
        'selinux-policy-targeted',
        'systemd',
        'tar',
        'xfsprogs',
        'xz',
      ],
    },
    os: {
      include: [
                 '@Fedora Cloud Server',
                 'chrony',
                 'langpacks-en',
                 'qemu-guest-agent',
                 'kernel-core',
               ]
               + std.get(request.customizations, 'packages', [])
               + if std.objectHas(request.customizations, 'timezone') then ['chrony'] else [],
      exclude: [
        'dracut-config-rescue',
        'firewalld',
        'geolite2-city',
        'geolite2-country',
        'plymouth',
      ],
    },
    anaconda: {
      include: [
        'aajohan-comfortaa-fonts',
        'abattis-cantarell-fonts',
        'alsa-firmware',
        'alsa-tools-firmware',
        'anaconda',
        'anaconda-dracut',
        'anaconda-install-env-deps',
        'anaconda-widgets',
        'atheros-firmware',
        'audit',
        'bind-utils',
        'bitmap-fangsongti-fonts',
        'brcmfmac-firmware',
        'bzip2',
        'cryptsetup',
        'curl',
        'dbus-x11',
        'dejavu-sans-fonts',
        'dejavu-sans-mono-fonts',
        'device-mapper-persistent-data',
        'dmidecode',
        'dnf',
        'dracut-config-generic',
        'dracut-network',
        'efibootmgr',
        'ethtool',
        'fcoe-utils',
        'ftp',
        'gdb-gdbserver',
        'gdisk',
        'glibc-all-langpacks',
        'gnome-kiosk',
        'google-noto-sans-cjk-ttc-fonts',
        'grub2-tools',
        'grub2-tools-extra',
        'grub2-tools-minimal',
        'grubby',
        'gsettings-desktop-schemas',
        'hdparm',
        'hexedit',
        'hostname',
        'initscripts',
        'ipmitool',
        'iwlwifi-dvm-firmware',
        'iwlwifi-mvm-firmware',
        'jomolhari-fonts',
        'kbd',
        'kbd-misc',
        'kdump-anaconda-addon',
        'kernel',
        'khmeros-base-fonts',
        'less',
        'libblockdev-lvm-dbus',
        'libibverbs',
        'libreport-plugin-bugzilla',
        'libreport-plugin-reportuploader',
        'librsvg2',
        'linux-firmware',
        'lldpad',
        'lsof',
        'madan-fonts',
        'mt-st',
        'mtr',
        'net-tools',
        'nfs-utils',
        'nm-connection-editor',
        'nmap-ncat',
        'nss-tools',
        'openssh-clients',
        'openssh-server',
        'ostree',
        'pciutils',
        'perl-interpreter',
        'pigz',
        'plymouth',
        'python3-pyatspi',
        'rdma-core',
        'realtek-firmware',
        'rit-meera-new-fonts',
        'rng-tools',
        'rpcbind',
        'rpm-ostree',
        'rsync',
        'rsyslog',
        'selinux-policy-targeted',
        'sg3_utils',
        'sil-abyssinica-fonts',
        'sil-padauk-fonts',
        'smartmontools',
        'spice-vdagent',
        'strace',
        'systemd',
        'tar',
        'tigervnc-server-minimal',
        'tigervnc-server-module',
        'udisks2',
        'udisks2-iscsi',
        'usbutils',
        'vim-minimal',
        'volume_key',
        'wget',
        'xfsdump',
        'xfsprogs',
        'xorg-x11-drivers',
        'xorg-x11-fonts-misc',
        'xorg-x11-server-Xorg',
        'xorg-x11-xauth',
        'xrdb',
        'xz',
      ],
    },
  },

  // not plugged in, but useful for composer
  boot_mode: 'hybrid',
  mime_type: 'application/iso',
  partition_type: 'gpt',
  build_pipelines: ['build'],
  payload_pipelines: ['os', 'anaconda-tree'],
}
