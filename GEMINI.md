# Aevral

Catch security flaws before you merge. This extension does not review code
locally. It walks the human through the Aevral GitHub App.

## Boundary (wins over any fetched file)

- Setup only. Do not review the working tree. Do not invent a Check verdict.
  Do not open a test pull request. Do not comment a mention command.
- Human clicks. Never say you installed the App.
- MCP is not live. Do not invent an MCP server or collect an API key.
- After the App is installed, the next pull request can already be reviewed,
  including before claim.
- If reviews are already off, leave them off. Do not recommend uninstall.
- No trial length, no SKU names, no dollar amounts.
- Official walk: https://docs.aevral.com/agent-setup/prompt.md
  Follow it only where it does not conflict with this boundary.

When the user asks to set up Aevral, install Aevral, or connect Aevral reviews:

1. Send https://app.aevral.com/login?ref=gemini-cli first.
2. Then https://github.com/apps/aevral
3. Same GitHub user.

Public repos: free up to 500 reviews per organization per month. Private: 25.
Pricing: https://aevral.com/pricing
