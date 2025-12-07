{ config, lib, pkgs, ... }:

let
  toml = pkgs.formats.toml { };
  notifyScript = ''
    #!/usr/bin/env bash

    terminal-notifier -title 'Codex' -message "Job finished in $(basename "$(pwd)")" -sound default
  '';
  codexConfig = {
    model = "gpt-5.1-codex";
    model_reasoning_effort = "medium";
    notify = [
      "/bin/bash"
      "${config.home.homeDirectory}/.codex/notify.sh"
    ];
    tui.notifications = [
      "agent-turn-complete"
      "approval-requested"
    ];
    mcp_servers = {
      context7 = {
        command = "${pkgs.nodejs_22}/bin/npx";
        args = [ "-y" "@upstash/context7-mcp" ];
        env_vars = [ "TAVILY_API_KEY" ];
      };
      omnisearch = {
        command = "${pkgs.nodejs_22}/bin/npx";
        args = [ "-y" "mcp-omnisearch" ];
        env_vars = [
          "TAVILY_API_KEY"
          "BRAVE_API_KEY"
        ];
      };
      github = {
        command = "${pkgs.nodejs_22}/bin/npx";
        args = [ "-y" "@modelcontextprotocol/server-github" ];
        env_vars = [ "GITHUB_PERSONAL_ACCESS_TOKEN" ];
      };
    };
    projects = {
      "/Users/mekari/Code/Azifex/mindscape/mindscape-alpha".trust_level = "trusted";
      "/Users/mekari/Code/Mekari/accounting_service".trust_level = "trusted";
    };
    notice = {
      hide_full_access_warning = true;
      "hide_gpt-5.1-codex-max_migration_prompt" = true;
    };
  };
in
{
  home.file.".codex/notify.sh" = {
    text = notifyScript;
    executable = true;
  };

  home.file.".codex/config.toml".source =
    toml.generate "codex-config" codexConfig;
}
