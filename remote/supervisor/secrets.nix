{
  config,
  lib,
  ...
}: {
  sops = {
    defaultSopsFile = ../secrets/supervisors.yaml;

    secrets.test.mode = "0444";

    secrets.wg0_private_key.mode = "0400";
    secrets.wg0_public_key.mode = "0400";
    
    secrets.authorized_keys.mode = "0440";

    secrets."step_intermediate_password" = {
      restartUnits = ["step-ca.service"];
      mode = "0440";
      owner = config.users.users.step-ca.name;
      group = config.users.users.step-ca.group;
    };

    secrets."step_root" = {
      restartUnits = ["step-ca.service"];
      mode = "0440";
      owner = config.users.users.step-ca.name;
      group = config.users.users.step-ca.group;
    };

    secrets."step_crt" = {
      restartUnits = ["step-ca.service"];
      mode = "0444";
      owner = config.users.users.step-ca.name;
      group = config.users.users.step-ca.group;
    };

    secrets."step_key" = {
      restartUnits = ["step-ca.service"];
      mode = "0440";
      owner = config.users.users.step-ca.name;
      group = config.users.users.step-ca.group;
    };
  };
}
