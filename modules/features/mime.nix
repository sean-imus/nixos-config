{ ... }:
{
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/pdf" = "firefox.desktop";
      "text/plain" = "writer.desktop";

      "image/avif" = "firefox.desktop";
      "image/bmp" = "firefox.desktop";
      "image/gif" = "firefox.desktop";
      "image/jpeg" = "firefox.desktop";
      "image/png" = "firefox.desktop";
      "image/svg+xml" = "firefox.desktop";
      "image/webp" = "firefox.desktop";
    };
  };
}
