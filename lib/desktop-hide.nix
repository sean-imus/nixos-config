names:
builtins.listToAttrs (
  map (name: {
    inherit name;
    value.text = "[Desktop Entry]\nHidden=true\n";
  }) (map (name: "applications/${name}.desktop") names)
)
