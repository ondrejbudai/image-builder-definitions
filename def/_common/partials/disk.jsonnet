function(bundle) {
  local sources = bundle.sources,
  local request = bundle.request,

  version: '2',
  pipelines:
  [
    local build = import '../pipelines/build.jsonnet';
    build(sources['org.osbuild.rpm'].refs.build)
  ]
  + [
    {
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
              references: sources['org.osbuild.rpm'].refs.os,
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
    },
    {
      name: 'image',
      build: 'name:build',
      stages: [
        {
          type: 'org.osbuild.truncate',
          options: {
            filename: 'disk.img',
            size: '5368709120',
          },
        },
        {
          type: 'org.osbuild.sfdisk',
          options: {
            label: 'gpt',
            uuid: 'D209C89E-EA5E-4FBD-B161-B461CCE297E0',
            partitions: [
              {
                bootable: true,
                size: 2048,
                start: 2048,
                type: '21686148-6449-6E6F-744E-656564454649',
                uuid: 'FAC7F1FB-3E8D-4137-A512-961DE09A5549',
              },
              {
                size: 409600,
                start: 4096,
                type: 'C12A7328-F81F-11D2-BA4B-00A0C93EC93B',
                uuid: '68B2905B-DF3E-4FB3-80FA-49D1E773AA33',
              },
              {
                size: 1024000,
                start: 413696,
                type: '0FC63DAF-8483-4772-8E79-3D69D8477DE4',
                uuid: 'CB07C243-BC44-4717-853E-28852021225B',
              },
              {
                size: 9048031,
                start: 1437696,
                type: '0FC63DAF-8483-4772-8E79-3D69D8477DE4',
                uuid: '6264D520-3FB9-423F-8AB8-7A0A8E3D3562',
              },
            ],
          },
          devices: {
            device: {
              type: 'org.osbuild.loopback',
              options: {
                filename: 'disk.img',
                lock: true,
              },
            },
          },
        },
        {
          type: 'org.osbuild.mkfs.fat',
          options: {
            volid: '7B7795E7',
          },
          devices: {
            device: {
              type: 'org.osbuild.loopback',
              options: {
                filename: 'disk.img',
                start: 4096,
                size: 409600,
                lock: true,
              },
            },
          },
        },
        {
          type: 'org.osbuild.mkfs.ext4',
          options: {
            uuid: '0194fdc2-fa2f-4cc0-81d3-ff12045b73c8',
            label: 'boot',
          },
          devices: {
            device: {
              type: 'org.osbuild.loopback',
              options: {
                filename: 'disk.img',
                start: 413696,
                size: 1024000,
                lock: true,
              },
            },
          },
        },
        {
          type: 'org.osbuild.mkfs.btrfs',
          options: {
            uuid: '6e4ff95f-f662-45ee-a82a-bdf44a2d0b75',
            label: 'root',
            metadata: 'dup',
          },
          devices: {
            device: {
              type: 'org.osbuild.loopback',
              options: {
                filename: 'disk.img',
                start: 1437696,
                size: 9048031,
                lock: true,
              },
            },
          },
        },
        {
          type: 'org.osbuild.btrfs.subvol',
          options: {
            subvolumes: [
              {
                name: 'root',
              },
              {
                name: 'home',
              },
            ],
          },
          devices: {
            device: {
              type: 'org.osbuild.loopback',
              options: {
                filename: 'disk.img',
                start: 1437696,
                size: 9048031,
                lock: true,
              },
            },
          },
          mounts: [
            {
              name: 'volume',
              type: 'org.osbuild.btrfs',
              source: 'device',
              target: '/',
            },
          ],
        },
        {
          type: 'org.osbuild.copy',
          inputs: {
            'root-tree': {
              type: 'org.osbuild.tree',
              origin: 'org.osbuild.pipeline',
              references: [
                'name:os',
              ],
            },
          },
          options: {
            paths: [
              {
                from: 'input://root-tree/',
                to: 'mount://root/',
              },
            ],
          },
          devices: {
            boot: {
              type: 'org.osbuild.loopback',
              options: {
                filename: 'disk.img',
                start: 413696,
                size: 1024000,
              },
            },
            'boot.efi': {
              type: 'org.osbuild.loopback',
              options: {
                filename: 'disk.img',
                start: 4096,
                size: 409600,
              },
            },
            root: {
              type: 'org.osbuild.loopback',
              options: {
                filename: 'disk.img',
                start: 1437696,
                size: 9048031,
              },
            },
          },
          mounts: [
            {
              name: 'root',
              type: 'org.osbuild.btrfs',
              source: 'root',
              target: '/',
              options: {
                subvol: 'root',
                compress: 'zstd:1',
              },
            },
            {
              name: 'home',
              type: 'org.osbuild.btrfs',
              source: 'root',
              target: '/home',
              options: {
                subvol: 'home',
                compress: 'zstd:1',
              },
            },
            {
              name: 'boot',
              type: 'org.osbuild.ext4',
              source: 'boot',
              target: '/boot',
            },
            {
              name: 'boot.efi',
              type: 'org.osbuild.fat',
              source: 'boot.efi',
              target: '/boot/efi',
            },
          ],
        },
        {
          type: 'org.osbuild.grub2.inst',
          options: {
            filename: 'disk.img',
            platform: 'i386-pc',
            location: 2048,
            core: {
              type: 'mkimage',
              partlabel: 'gpt',
              filesystem: 'ext4',
            },
            prefix: {
              type: 'partition',
              partlabel: 'gpt',
              number: 2,
              path: '/grub2',
            },
          },
        },
      ],
    },
  ],
  sources: {
    'org.osbuild.curl': {
      items: sources['org.osbuild.rpm'].sources,
    },
  },
}
