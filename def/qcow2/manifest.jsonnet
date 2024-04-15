local disk = import '../_common/partials/disk.jsonnet';

// append a pipeline to convert the disk partial to qcow2
function(bundle) disk(bundle) {
  pipelines+: [
    {
      "name": "qemu",
      "build": "name:build",
      "stages": [
        {
          "type": "org.osbuild.qemu",
          "inputs": {
            "image": {
              "type": "org.osbuild.files",
              "origin": "org.osbuild.pipeline",
              "references": {
                "name:image": {
                  "file": "disk.img"
                }
              }
            }
          },
          "options": {
            "filename": "qemu.qcow2",
            "format": {
              "type": "qcow2",
              "compression": false,
              "compat": "1.1"
            }
          }
        }
      ]
    }
  ]
}
