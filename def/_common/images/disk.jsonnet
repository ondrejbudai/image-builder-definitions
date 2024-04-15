function(request) {
    module_platform_id: 'platform:f%s' % request.version,
    repositories: [
      {
        id: 'fedora',
        baseurl: 'https://rpmrepo.osbuild.org/v2/mirror/public/f39/f39-x86_64-fedora-20231109',
      },
    ],
    packages: {
        build: {
            include: [
                "btrfs-progs",
                "dnf",
                "dosfstools",
                "e2fsprogs",
                "grub2-pc",
                "policycoreutils",
                "python3-iniparse",
                "python3-pyyaml",
                "qemu-img",
                "rpm-ostree",
                "selinux-policy-targeted",
                "systemd",
                "tar",
                "xfsprogs",
                "xz",
            ],
        },
        os: {
            include: [
                "btrfs-progs",
                "dnf",
                "dosfstools",
                "e2fsprogs",
                "grub2-pc",
                "policycoreutils",
                "python3-iniparse",
                "python3-pyyaml",
                "qemu-img",
                "rpm-ostree",
                "selinux-policy-targeted",
                "systemd",
                "tar",
                "xfsprogs",
                "xz",
            ]
            + std.get(request.customizations, "packages", [])
            + if std.objectHas(request.customizations, "timezone") then ["chrony"] else [],
        }
    },

    // not plugged in, but useful for composer
    boot_mode: 'hybrid',
    mime_type: 'application/raw',
    partition_type: 'gpt',
    build_pipelines: ['build'],
    payload_pipelines: ['os'],
}
