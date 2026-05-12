{ config, lib, pkgs, guard-and-guide, ... }:

let
  cfg = config.programs.guard-and-guide;
  system = pkgs.stdenv.hostPlatform.system;
in {
  options.programs.guard-and-guide = {
    enable = lib.mkEnableOption "guard-and-guide AI agent hook tool";
    rules = lib.mkOption {
      type = lib.types.lines;
      default = ''
        version = 1

        [[rules]]
        matcher = "File"
        regex = '/\.env($|[^r])'
        message = "Access to .env files is prohibited. Ask the user to check or provide the values you need."

        [[rules]]
        matcher = "File"
        regex = '\.ssh/'
        message = "Access to SSH keys is prohibited. Ask the user to handle SSH-related operations."

        [[rules]]
        matcher = "File"
        regex = '\.aws/'
        message = "Access to AWS credentials is prohibited. Ask the user to check or provide AWS configuration."

        [[rules]]
        matcher = "File"
        regex = '\.git-credentials$|\.netrc$|\.npmrc$'
        message = "Access to credential files is prohibited. Ask the user to handle credentials."

        [[rules]]
        matcher = "File"
        regex = 'id_rsa|id_ed25519'
        message = "Access to private keys is prohibited. Ask the user to handle key-related operations."

        [[rules]]
        matcher = "File"
        regex = 'secrets|token'
        message = "Access to files containing secrets/tokens is prohibited. Ask the user to provide the values you need."

        [[rules]]
        matcher = "Write|Edit"
        regex = '\.lock$'
        message = "Lock files are read-only. Do not modify them directly."

        [[rules]]
        matcher = "Bash"
        regex = '\bgit\s+push\b'
        message = "Use of 'git push' is prohibited. Ask the user to execute it."

        [[rules]]
        matcher = "Bash"
        regex = '\bgit\s+add\s+(-A|--all|\.($|[ ;|&]))'
        message = "Do not git-add all files. Specify the files to add."

        [[rules]]
        matcher = "Bash"
        regex = '\bgit\s+checkout\b'
        message = "Use of 'git checkout' is prohibited. Use 'git switch' for branch switching and 'git restore' for file restoration instead."

        [[rules]]
        matcher = "Bash"
        regex = '\bgit\s+clean\b.*-[a-zA-Z]*f'
        message = "Use of 'git clean -f' is prohibited. It deletes untracked files irreversibly. Ask the user to execute it."

        [[rules]]
        matcher = "Bash"
        regex = '\bgit\s+branch\b.*\s-D\b'
        message = "Use of 'git branch -D' is prohibited. Use 'git branch -d' for safe deletion, or ask the user to force-delete."

        [[rules]]
        matcher = "Bash"
        regex = '\bgit\s+stash\b.*(drop|clear)\b'
        message = "Use of 'git stash drop/clear' is prohibited. Ask the user to execute it."

        [[rules]]
        matcher = "Bash"
        regex = '\b(env|printenv|export)\b'
        message = "Accessing environment variables is prohibited. Ask the user to check or set environment variables."

        [[rules]]
        matcher = "Bash"
        regex = '\.env\b'
        message = "Access to .env files via bash is prohibited. Ask the user to check or provide the values you need."

        [[rules]]
        matcher = "Bash"
        regex = '\.ssh/'
        message = "Access to SSH keys via bash is prohibited. Ask the user to handle SSH-related operations."

        [[rules]]
        matcher = "Bash"
        regex = '\.aws/'
        message = "Access to AWS credentials via bash is prohibited. Ask the user to check or provide AWS configuration."

        [[rules]]
        matcher = "Bash"
        regex = '\.git-credentials|\.netrc|\.npmrc'
        message = "Access to credential files via bash is prohibited. Ask the user to handle credentials."

        [[rules]]
        matcher = "Bash"
        regex = 'id_rsa|id_ed25519'
        message = "Access to private keys via bash is prohibited. Ask the user to handle key-related operations."
      '';
      description = "Content of ~/.config/guard-and-guide/rules.toml";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ guard-and-guide.packages.${system}.default ];
    xdg.configFile."guard-and-guide/rules.toml".text = cfg.rules;
  };
}
