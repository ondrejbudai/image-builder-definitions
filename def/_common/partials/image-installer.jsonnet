function(bundle) {
  local sources = bundle.sources,
  local request = bundle.request,

  version: '2',
  pipelines:
    [
      local build = import '../pipelines/build.jsonnet';
      build(sources['org.osbuild.rpm'].refs.build),
    ]
    + [
      local os = import '../pipelines/os.jsonnet';
      os(request, sources['org.osbuild.rpm'].refs.os),
    ]
    + [
      {
        name: 'anaconda-tree',
        build: 'name:build',
        stages: [
          {
            type: 'org.osbuild.rpm',
            inputs: {
              packages: {
                type: 'org.osbuild.files',
                origin: 'org.osbuild.source',
                references: std.map(function(rpm) rpm["checksum"], sources['org.osbuild.rpm'].refs.anaconda),
              },
            },
            options: {
            // gpgkeys: sources['org.osbuild.rpm'].keys.build,
            },
          },
          {
            type: 'org.osbuild.buildstamp',
            options: {
              arch: 'x86_64',
              product: 'Fedora',
              version: '39',
              final: true,
              variant: '',
              bugurl: '',
            },
          },
          {
            type: 'org.osbuild.locale',
            options: {
              language: 'en_US.UTF-8',
            },
          },
          {
            type: 'org.osbuild.users',
            options: {
              users: {
                install: {
                  uid: 0,
                  gid: 0,
                  home: '/root',
                  shell: '/usr/libexec/anaconda/run-anaconda',
                  password: '',
                },
                root: {
                  password: '',
                },
              },
            },
          },
          {
            type: 'org.osbuild.anaconda',
            options: {
              'kickstart-modules': [
                'org.fedoraproject.Anaconda.Modules.Network',
                'org.fedoraproject.Anaconda.Modules.Payloads',
                'org.fedoraproject.Anaconda.Modules.Storage',
                'org.fedoraproject.Anaconda.Modules.Security',
                'org.fedoraproject.Anaconda.Modules.Timezone',
                'org.fedoraproject.Anaconda.Modules.Localization',
                'org.fedoraproject.Anaconda.Modules.Users',
              ],
            },
          },
          {
            type: 'org.osbuild.lorax-script',
            options: {
              path: '99-generic/runtime-postinstall.tmpl',
              basearch: 'x86_64',
              product: {
                name: '',
                version: '',
              },
            },
          },
          {
            type: 'org.osbuild.dracut',
            options: {
              kernel: [
                '6.5.6-300.fc39.x86_64',
              ],
              modules: [
                'bash',
                'systemd',
                'fips',
                'systemd-initrd',
                'modsign',
                'nss-softokn',
                'i18n',
                'convertfs',
                'network-manager',
                'network',
                'ifcfg',
                'url-lib',
                'drm',
                'plymouth',
                'crypt',
                'dm',
                'dmsquash-live',
                'kernel-modules',
                'kernel-modules-extra',
                'kernel-network-modules',
                'livenet',
                'lvm',
                'mdraid',
                'qemu',
                'qemu-net',
                'resume',
                'rootfs-block',
                'terminfo',
                'udev-rules',
                'dracut-systemd',
                'pollcdrom',
                'usrmount',
                'base',
                'fs-lib',
                'img-lib',
                'shutdown',
                'uefi-lib',
                'biosdevname',
                'anaconda',
                'rdma',
                'rngd',
                'multipath',
                'fcoe',
                'fcoe-uefi',
                'iscsi',
                'lunmask',
                'nfs',
              ],
              install: [
                '/.buildstamp',
              ],
            },
          },
          {
            type: 'org.osbuild.selinux.config',
            options: {
              state: 'permissive',
            },
          },
          {
            type: 'org.osbuild.kickstart',
            options: {
              path: '/usr/share/anaconda/interactive-defaults.ks',
              liveimg: {
                url: 'file:///run/install/repo/liveimg.tar.gz',
              },
            },
          },
        ],
      },
      {
        "name": "rootfs-image",
        "build": "name:build",
        "stages": [
          {
            "type": "org.osbuild.mkdir",
            "options": {
              "paths": [
                {
                  "path": "/LiveOS"
                }
              ]
            }
          },
          {
            "type": "org.osbuild.truncate",
            "options": {
              "filename": "/LiveOS/rootfs.img",
              "size": "4294967296"
            }
          },
          {
            "type": "org.osbuild.mkfs.ext4",
            "options": {
              "uuid": "2fe99653-f7ff-44fd-bea8-fa70107524fb",
              "label": "Anaconda"
            },
            "devices": {
              "device": {
                "type": "org.osbuild.loopback",
                "options": {
                  "filename": "LiveOS/rootfs.img"
                }
              }
            }
          },
          {
            "type": "org.osbuild.copy",
            "inputs": {
              "tree": {
                "type": "org.osbuild.tree",
                "origin": "org.osbuild.pipeline",
                "references": [
                  "name:anaconda-tree"
                ]
              }
            },
            "options": {
              "paths": [
                {
                  "from": "input://tree/",
                  "to": "mount://device/"
                }
              ]
            },
            "devices": {
              "device": {
                "type": "org.osbuild.loopback",
                "options": {
                  "filename": "LiveOS/rootfs.img"
                }
              }
            },
            "mounts": [
              {
                "name": "device",
                "type": "org.osbuild.ext4",
                "source": "device",
                "target": "/"
              }
            ]
          }
        ]
      },
      {
        "name": "efiboot-tree",
        "build": "name:build",
        "stages": [
          {
            "type": "org.osbuild.grub2.iso",
            "options": {
              "product": {
                "name": "Fedora",
                "version": "39"
              },
              "kernel": {
                "dir": "/images/pxeboot",
                "opts": [
                  "inst.stage2=hd:LABEL=Fedora-39-BaseOS-x86_64",
                  "inst.webui",
                  "inst.webui.remote"
                ]
              },
              "isolabel": "Fedora-39-BaseOS-x86_64",
              "architectures": [
                "X64"
              ],
              "vendor": "fedora"
            }
          }
        ]
      },
      {
        "name": "bootiso-tree",
        "build": "name:build",
        "stages": [
          {
            "type": "org.osbuild.mkdir",
            "options": {
              "paths": [
                {
                  "path": "/images"
                },
                {
                  "path": "/images/pxeboot"
                }
              ]
            }
          },
          {
            "type": "org.osbuild.copy",
            "inputs": {
              "tree": {
                "type": "org.osbuild.tree",
                "origin": "org.osbuild.pipeline",
                "references": [
                  "name:anaconda-tree"
                ]
              }
            },
            "options": {
              "paths": [
                {
                  "from": "input://tree/boot/vmlinuz-6.5.6-300.fc39.x86_64",
                  "to": "tree:///images/pxeboot/vmlinuz"
                },
                {
                  "from": "input://tree/boot/initramfs-6.5.6-300.fc39.x86_64.img",
                  "to": "tree:///images/pxeboot/initrd.img"
                }
              ]
            }
          },
          {
            "type": "org.osbuild.squashfs",
            "inputs": {
              "tree": {
                "type": "org.osbuild.tree",
                "origin": "org.osbuild.pipeline",
                "references": [
                  "name:rootfs-image"
                ]
              }
            },
            "options": {
              "filename": "images/install.img",
              "compression": {
                "method": "lz4"
              }
            }
          },
          {
            "type": "org.osbuild.isolinux",
            "inputs": {
              "data": {
                "type": "org.osbuild.tree",
                "origin": "org.osbuild.pipeline",
                "references": [
                  "name:anaconda-tree"
                ]
              }
            },
            "options": {
              "product": {
                "name": "Fedora",
                "version": "39"
              },
              "kernel": {
                "dir": "/images/pxeboot",
                "opts": [
                  "inst.stage2=hd:LABEL=Fedora-39-BaseOS-x86_64",
                  "inst.webui",
                  "inst.webui.remote"
                ]
              }
            }
          },
          {
            "type": "org.osbuild.truncate",
            "options": {
              "filename": "images/efiboot.img",
              "size": "20971520"
            }
          },
          {
            "type": "org.osbuild.mkfs.fat",
            "options": {
              "volid": "0194fdc2"
            },
            "devices": {
              "device": {
                "type": "org.osbuild.loopback",
                "options": {
                  "filename": "images/efiboot.img",
                  "size": 40960,
                  "lock": true
                }
              }
            }
          },
          {
            "type": "org.osbuild.copy",
            "inputs": {
              "root-tree": {
                "type": "org.osbuild.tree",
                "origin": "org.osbuild.pipeline",
                "references": [
                  "name:efiboot-tree"
                ]
              }
            },
            "options": {
              "paths": [
                {
                  "from": "input://root-tree/",
                  "to": "mount://-/"
                }
              ]
            },
            "devices": {
              "-": {
                "type": "org.osbuild.loopback",
                "options": {
                  "filename": "images/efiboot.img",
                  "size": 40960
                }
              }
            },
            "mounts": [
              {
                "name": "-",
                "type": "org.osbuild.fat",
                "source": "-",
                "target": "/"
              }
            ]
          },
          {
            "type": "org.osbuild.copy",
            "inputs": {
              "root-tree": {
                "type": "org.osbuild.tree",
                "origin": "org.osbuild.pipeline",
                "references": [
                  "name:efiboot-tree"
                ]
              }
            },
            "options": {
              "paths": [
                {
                  "from": "input://root-tree/EFI",
                  "to": "tree:///"
                }
              ]
            }
          },
          {
            "type": "org.osbuild.tar",
            "inputs": {
              "tree": {
                "type": "org.osbuild.tree",
                "origin": "org.osbuild.pipeline",
                "references": [
                  "name:os"
                ]
              }
            },
            "options": {
              "filename": "/liveimg.tar.gz"
            }
          },
          {
            "type": "org.osbuild.discinfo",
            "options": {
              "basearch": "x86_64",
              "release": "Fedora 39"
            }
          }
        ]
      },
      {
        "name": "bootiso",
        "build": "name:build",
        "stages": [
          {
            "type": "org.osbuild.xorrisofs",
            "inputs": {
              "tree": {
                "type": "org.osbuild.tree",
                "origin": "org.osbuild.pipeline",
                "references": [
                  "name:bootiso-tree"
                ]
              }
            },
            "options": {
              "filename": "installer.iso",
              "volid": "Fedora-39-BaseOS-x86_64",
              "sysid": "LINUX",
              "boot": {
                "image": "isolinux/isolinux.bin",
                "catalog": "isolinux/boot.cat"
              },
              "efi": "images/efiboot.img",
              "isohybridmbr": "/usr/share/syslinux/isohdpfx.bin",
              "isolevel": 3
            }
          },
          {
            "type": "org.osbuild.implantisomd5",
            "options": {
              "filename": "installer.iso"
            }
          }
        ]
      }
    ],
  sources: {
    'org.osbuild.curl': {
      items: sources['org.osbuild.rpm'].sources,
    },
  },
}
