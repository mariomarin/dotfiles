{ pkgs, inputs, ... }:

let
  xdg-open-svc = inputs.caarlos0-nur.packages.${pkgs.system}.xdg-open-svc;
in
{
  launchd.user.agents.xdg-open-svc = {
    serviceConfig = {
      Label = "com.caarlos0.xdg-open-svc";
      ProgramArguments = [ "${xdg-open-svc}/bin/xdg-open-svc" ];
      KeepAlive = true;
      RunAtLoad = true;
      ProcessType = "Background";
    };
  };
}
