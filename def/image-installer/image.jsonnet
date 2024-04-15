local image = import '../_common/images/image-installer.jsonnet';
function(request) image(request) {
  exports: ["bootiso"]
}
