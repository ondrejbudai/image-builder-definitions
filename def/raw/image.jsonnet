local info = import '../_common/images/disk.jsonnet';
function(blueprint) info(blueprint) {
  exports: ["image"]
}
