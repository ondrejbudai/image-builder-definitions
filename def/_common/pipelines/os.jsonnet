function(request, rpmRefs) {
      name: 'os',
      build: 'name:build',
      stages: [
        {
          type: 'org.osbuild.kernel-cmdline',
          options: {
            root_fs_uuid: '6e4ff95f-f662-45ee-a82a-bdf44a2d0b75',
            kernel_opts: 'ro no_timer_check console=ttyS0,115200n8 biosdevname=0 net.ifnames=0 rootflags=subvol=root',
          },
        },
        {
          type: 'org.osbuild.rpm',
          inputs: {
            packages: {
              type: 'org.osbuild.files',
              origin: 'org.osbuild.source',
              references: rpmRefs,
            },
          },
          options: {
            // gpgkeys: sources['org.osbuild.rpm'].keys.build,
            exclude: { docs: true },
            install_langs: ['en_US'],
          },
        },
        {
          type: 'org.osbuild.fix-bls',
          options: {
            prefix: '',
          },
        },
        {
          type: 'org.osbuild.locale',
          options: {
            language: 'en_US',
          },
        },
        {
          type: 'org.osbuild.hostname',
          options: {
            hostname: if std.objectHas(request.customizations, 'hostname') then request.customizations.hostname else 'localhost.localdomain',
          },
        },
        {
          type: 'org.osbuild.timezone',
          options: {
            zone: if std.objectHas(request.customizations, 'timezone') then request.customizations.timezone else 'localhost.localdomain',
          },
        },
        {
          type: 'org.osbuild.fstab',
          options: {
            filesystems: [
              {
                uuid: '6e4ff95f-f662-45ee-a82a-bdf44a2d0b75',
                vfs_type: 'btrfs',
                path: '/',
                options: 'subvol=root,compress=zstd:1',
              },
              {
                uuid: '0194fdc2-fa2f-4cc0-81d3-ff12045b73c8',
                vfs_type: 'ext4',
                path: '/boot',
                options: 'defaults',
              },
              {
                uuid: '7B77-95E7',
                vfs_type: 'vfat',
                path: '/boot/efi',
                options: 'defaults,uid=0,gid=0,umask=077,shortname=winnt',
                passno: 2,
              },
              {
                uuid: '6e4ff95f-f662-45ee-a82a-bdf44a2d0b75',
                vfs_type: 'btrfs',
                path: '/home',
                passno: 3,
                options: 'subvol=home,compress=zstd:1',
              },
            ],
          },
        },
        {
          type: 'org.osbuild.grub2',
          options: {
            root_fs_uuid: '6e4ff95f-f662-45ee-a82a-bdf44a2d0b75',
            boot_fs_uuid: '0194fdc2-fa2f-4cc0-81d3-ff12045b73c8',
            kernel_opts: 'ro no_timer_check console=ttyS0,115200n8 biosdevname=0 net.ifnames=0',
            legacy: 'i386-pc',
            uefi: {
              vendor: 'fedora',
              unified: true,
            },
            saved_entry: 'ffffffffffffffffffffffffffffffff-6.6.4-200.fc39.x86_64',
            write_cmdline: false,
            config: {
              default: 'saved',
            },
          },
        },
        {
          type: 'org.osbuild.systemd',
          options: {
            enabled_services: [
              'cloud-init.service',
              'cloud-config.service',
              'cloud-final.service',
              'cloud-init-local.service',
            ],
            default_target: 'multi-user.target',
          },
        },
        {
          type: 'org.osbuild.selinux',
          options: {
            file_contexts: 'etc/selinux/targeted/contexts/files/file_contexts',
          },
        },
      ],
    }
