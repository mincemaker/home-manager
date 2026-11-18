{ config, lib, pkgs, ... }:

let
  cfg = config.programs.agy-hooks;
  inherit (config.lib.file) mkOutOfStoreSymlink;
  agyCfgDir = "${config.home.homeDirectory}/.config/home-manager/modules/antigravity-cli";
in {
  options.programs.agy-hooks = {
    enable = lib.mkEnableOption "antigravity-cli (agy) hooks configuration";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      # agy の PreToolUse フックから呼ばれる guard-and-guide ラッパー
      # agy の JSON 形式を guard-and-guide の Gemini CLI 形式に変換する
      (pkgs.writers.writePython3Bin "guard-and-guide-agy" { } ''
        import json
        import subprocess
        import sys


        def deny(reason):
            print(json.dumps({"decision": "deny", "reason": reason}))


        def main():
            try:
                data = json.load(sys.stdin)
            except (json.JSONDecodeError, EOFError):
                deny("guard-and-guide-agy: invalid hook input")
                return

            tool_call = data.get("toolCall", {})
            args = tool_call.get("args", {})
            command = args.get("CommandLine", "")

            if not command:
                deny("guard-and-guide-agy: CommandLine is missing")
                return

            # guard-and-guide の Gemini CLI モードは run_shell_command を
            # Bash matcher として認識する。agy のツール名に関わらず常にこの値を使う。
            gag_input = json.dumps({
                "tool_name": "run_shell_command",
                "tool_input": {"command": command},
            })

            try:
                result = subprocess.run(
                    ["guard-and-guide", "--agent", "gemini-cli"],
                    input=gag_input,
                    capture_output=True,
                    text=True,
                    timeout=10,
                )
            except subprocess.TimeoutExpired:
                deny("guard-and-guide timed out")
                return
            except FileNotFoundError:
                deny("guard-and-guide not found in PATH")
                return

            output = result.stdout.strip()
            if output:
                # guard-and-guide の deny 出力はすでに agy と同形式
                # {"decision": "deny", "reason": "..."}
                print(output)
            elif result.returncode != 0:
                deny(f"guard-and-guide exited with {result.returncode}")
            else:
                print(json.dumps({"decision": "allow"}))


        if __name__ == "__main__":
            try:
                main()
            except Exception:
                deny("guard-and-guide-agy: unexpected hook input")
      '')
    ];

    # ~/.gemini/config/hooks.json を modules/antigravity-cli/hooks.json へのシンボリックリンクとして管理
    # claude.nix の settings.json と同じ mkOutOfStoreSymlink パターン
    home.file.".gemini/config/hooks.json".source =
      mkOutOfStoreSymlink "${agyCfgDir}/hooks.json";
  };
}
