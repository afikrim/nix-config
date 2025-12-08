{ pkgs, ... }:

let
  json = pkgs.formats.json { };
  copilotConfig = {
    banner = "never";
    model = "gpt-5.1-codex";
    render_markdown = true;
    screen_reader = false;
    theme = "light";
    trusted_folders = [
      "/Users/mekari/Code/Mekari/aziz/atfin-9221/implement-feature-flag-credit-card"
      "/Users/mekari/Code/Mekari/aziz/atfin-9301/correct-bank-statement-calculation-for-credit-card"
      "/Users/mekari/Code/Mekari/aziz/atfin-9371/implement-sync-call-to-create-journal-entries"
      "/Users/mekari/Code/Mekari/accounting_service"
      "/Users/mekari/Code/Mekari/aziz/atfin-9394/fix-toggling-for-cc-implementation"
      "/Users/mekari/Code/Mekari/aziz/atfin-9391/multiline-discount-product-track"
      "/Users/mekari/Code/Mekari/quickbook"
      "/Users/mekari/Code/Mekari/aziz/atfin-9408/add-accounting-to-cashbank-rbac"
      "/Users/mekari/Code/Mekari/aziz/atfin-9390/fix-reversal-calculation-bank-statement"
      "/Users/mekari/Code/Mekari/aziz/atfin-9406/implement-skip-at-on-at-consumer"
      "/Users/mekari/Code/Mekari/aziz/atfin-9346/adjust-rounding-jurnal-transaction-bank-statement"
      "/Users/mekari/Code/Mekari/aziz/atfin-9373/fix-cash-mapping-sync-call-je"
      "/Users/mekari/Code/Mekari/aziz/unitteststagingfi"
      "/Users/mekari/Code/Mekari/missing-at-arm"
      "/Users/mekari/Code/Mekari/aziz/atfin-9601/remove-zero-reversal"
      "/Users/mekari/Code/Mekari/aziz/atfin-9540/integration-testing-for-save-and-match"
      "/Users/mekari/Code/Mekari/aziz-atfin-9540-integration-testing-match-direct"
      "/Users/mekari/Code/Mekari/worktrees/aziz-atfin-9586-enhance-logging-match-process"
      "/Users/mekari/Code/Mekari/worktrees/aziz-atfin-9540-integration-testing-match-direct"
      "/Users/mekari/Code/Mekari/worktrees/aziz-atfin-9540-integration-testing-non-payment"
      "/Users/mekari/Code/Mekari/worktrees/aziz-atfin-9540-integration-testing-reconcile-combine-direct-match"
      "/Users/mekari/Code/Mekari/worktrees/aziz-atfin-9764-reconcile-archived-acc"
      "/Users/mekari/Code/Mekari/aziz/atfin-9655"
      "/Users/mekari"
    ];
    asked_setup_terminals = [ "vscode" ];
  };

  copilotMcp = {
    mcpServers = {
      "claude-code" = {
        type = "stdio";
        command = "${pkgs.claude-code}/bin/claude";
        args = [ "mcp" "serve" ];
        tools = [ "*" ];
        env = { };
      };
    };
  };
in
{
  home.file.".copilot/config.json".source =
    json.generate "copilot-config" copilotConfig;

  home.file.".copilot/mcp-config.json".source =
    json.generate "copilot-mcp-config" copilotMcp;
}
