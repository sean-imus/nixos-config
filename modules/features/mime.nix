{ ... }:
{
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/json" = "firefox.desktop";
      "application/pdf" = "firefox.desktop";
      "text/markdown" = "writer.desktop";
      "text/plain" = "writer.desktop";
      "text/x-markdown" = "writer.desktop";

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
