{ pkgs, lib, ... }:

let
  dictEntries = [
    { filename = "SKK-JISYO.L";       src = "${pkgs.skkDictionaries.l}/share/skk/SKK-JISYO.L";                 encoding = 3; }
    { filename = "SKK-JISYO.jinmei";  src = "${pkgs.skkDictionaries.jinmei}/share/skk/SKK-JISYO.jinmei";       encoding = 3; }
  ];

  dictListPy = lib.concatMapStringsSep ",\n    " (d: ''
    {"filename": "${d.filename}", "enabled": True, "encoding": ${toString d.encoding}, "type": "traditional", "saveToUserDict": False}
  '') dictEntries;

  copyCmds = lib.concatMapStrings (d: ''
    cp -f "${d.src}" "$DICT_DIR/${d.filename}"
  '') dictEntries;
in {
  home.activation.macSKK = lib.hm.dag.entryAfter ["writeBoundary"] ''
    CONTAINER="$HOME/Library/Containers/net.mtgto.inputmethod.macSKK/Data"
    DICT_DIR="$CONTAINER/Documents/Dictionaries"

    if [ ! -d "$CONTAINER" ]; then
      echo "macSKK: コンテナが存在しません。macSKK を一度起動してから再ビルドしてください。"
    else
      mkdir -p "$DICT_DIR"
      rm -f "$DICT_DIR"/SKK-JISYO.*
      ${copyCmds}
      ${pkgs.python3}/bin/python3 << 'PYEOF'
import plistlib, os
plist_path = os.path.expanduser(
    "~/Library/Containers/net.mtgto.inputmethod.macSKK/Data/Library/Preferences/net.mtgto.inputmethod.macSKK.plist"
)
os.makedirs(os.path.dirname(plist_path), exist_ok=True)
data = {}
if os.path.exists(plist_path):
    with open(plist_path, "rb") as f:
        data = plistlib.load(f)
data["dictionaries"] = [
    ${dictListPy}
]
with open(plist_path, "wb") as f:
    plistlib.dump(data, f)
PYEOF
    fi
  '';
}
