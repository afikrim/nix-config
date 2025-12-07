{ pkgs, ... }:

{
  programs.claude-code = {
    enable = true;

    mcpServers = {
      context7 = {
        type = "local";
        command = "${pkgs.nodejs_22}/bin/npx";
        args = [
          "-y"
          "@upstash/context7-mcp"
        ];
        env = {
          TAVILY_API_KEY = "\${TAVILY_API_KEY}";
        };
      };

      omnisearch = {
        type = "local";
        command = "${pkgs.nodejs_22}/bin/npx";
        args = [
          "-y"
          "mcp-omnisearch"
        ];
        env = {
          TAVILY_API_KEY = "\${TAVILY_API_KEY}";
          BRAVE_API_KEY = "\${BRAVE_API_KEY}";
        };
      };

      github = {
        type = "local";
        command = "${pkgs.nodejs_22}/bin/npx";
        args = [
          "-y"
          "@modelcontextprotocol/server-github"
        ];
        env = {
          GITHUB_PERSONAL_ACCESS_TOKEN = "\${GITHUB_PERSONAL_ACCESS_TOKEN}";
        };
      };
    };
  };
}
