{ pkgs, ... }:

{
  programs.claude-code = {
    enable = true;

    mcpServers = {
      claude-code = {
        type = "stdio";
        command = "${pkgs.claude-code}/bin/claude";
        args = [ "mcp" "serve" ];
        env = { };
      };
    };
  };
}
