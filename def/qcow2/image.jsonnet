local disk = import '../_common/images/disk.jsonnet';
function(request) disk(request) {
  exports: ["qcow2"]
}
