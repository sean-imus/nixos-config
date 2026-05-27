{ ... }:
{
  flake.modules.homeManager.notifications =
    { ... }:
    {
      services.mako = {
        enable = true;
        settings = {
          anchor = "top-right";
          background-color = "#00000088";
          text-color = "#ffffff";
          border-color = "#437306";
          border-radius = 12;
          border-size = 2;
          font = "Sans 11";
          height = 100;
          width = 400;
          margin = "15";
          padding = "5,15";
          max-visible = 5;
        };
      };
    };
}
