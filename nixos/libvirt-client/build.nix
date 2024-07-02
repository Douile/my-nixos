{ stdenv, lib }:
let
  fs = lib.fileset;
  sourceFiles = fs.unions [
    ./certificate_authority_certificate.pem
    ./host2_client_key.pem
    ./host2_client_certificate.pem
  ];
in

fs.trace sourceFiles

stdenv.mkDerivation {
  name = "libvirt-client-pki"
  src = fs.toSource {
    root = ./.;
    fileset = sourceFiles;
  };
}
#{
#  environment.etc."pki/CA/cacert.pem" = {
#    enable = true;
#    mode = "0444";
#    text = (builtins.readFile ./certificate_authority_certificate.pem);
#  };
#
#  environment.etc."pki/libvirt/private/clientkey.pem" = {
#    enable = true;
#    mode = "0400";
#    uid = 1000;
#    text = (builtins.readFile ./host2_client_key.pem);
#  };
#
#  environment.etc."pki/libvirt/clientcert.pem" = {
#    enable = true;
#    mode = "0400";
#    uid = 1000;
#    text = (builtins.readFile ./host2_client_certificate.pem);
#  };
#}
