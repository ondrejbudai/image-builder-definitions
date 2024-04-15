function(rpmRefs) {
  name: 'build',
  stages: [
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
  ],
}
