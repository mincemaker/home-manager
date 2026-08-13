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


        def main():
            try:
                data = json.load(sys.stdin)
            except (json.JSONDecodeError, EOFError):
                print(json.dumps({"decision": "allow"}))
                return

            tool_call = data.get("toolCall", {})
            args = tool_call.get("args", {})
            command = args.get("CommandLine", "")

            if not command:
                print(json.dumps({"decision": "allow"}))
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
                print(json.dumps({"decision": "allow"}))
                return
            except FileNotFoundError:
                print("guard-and-guide not found in PATH", file=sys.stderr)
                print(json.dumps({"decision": "allow"}))
                return

            output = result.stdout.strip()
            if output:
                # guard-and-guide の deny 出力はすでに agy と同形式
                # {"decision": "deny", "reason": "..."}
                print(output)
            else:
                print(json.dumps({"decision": "allow"}))


        if __name__ == "__main__":
            main()
      '')

      # agy の PreToolUse フックから呼ばれる RTK (Rust Token Killer) ラッパー
      # コマンドを rtk 経由にリライトしてトークン削減を図る
      # 注意: rtk バイナリ自体は Homebrew 管理（nix 管理外）
      (pkgs.writers.writePython3Bin "rtk-hook-gemini" { } ''
        import json
        import subprocess
        import sys


        def main():
            try:
                data = json.loads(sys.stdin.read())
            except (json.JSONDecodeError, EOFError):
                print(json.dumps({"decision": "allow"}))
                return

            tool_call = data.get("toolCall", {})
            tool_name = tool_call.get("name", "")
            args = tool_call.get("args", {})
            cmd = args.get("CommandLine", "")

            if tool_name not in ("run_command", "run_shell_command"):
                print(json.dumps({"decision": "allow"}))
                return

            if not cmd or cmd.startswith("rtk "):
                print(json.dumps({"decision": "allow"}))
                return

            try:
                res = subprocess.run(
                    ["rtk", "hook", "check", cmd],
                    capture_output=True, text=True, timeout=10,
                )
                rewritten = res.stdout.strip()
            except (subprocess.TimeoutExpired, FileNotFoundError):
                # rtk が PATH にない環境（Linux 等）では graceful fail
                print(json.dumps({"decision": "allow"}))
                return

            if rewritten and rewritten != cmd:
                print(json.dumps({
                    "decision": "allow",
                    "overwrite": {"CommandLine": rewritten},
                }))
            else:
                print(json.dumps({"decision": "allow"}))


        if __name__ == "__main__":
            main()
      '')
    ];

    # ~/.gemini/config/hooks.json を modules/antigravity-cli/hooks.json へのシンボリックリンクとして管理
    # claude.nix の settings.json と同じ mkOutOfStoreSymlink パターン
    home.file.".gemini/config/hooks.json".source =
      mkOutOfStoreSymlink "${agyCfgDir}/hooks.json";
  };
}
