## FearLab Agent Workflow

### Project
FearLab is an educational project for learning Git, PowerShell,
Linux, Docker, C#, CS2 plugin development and DevOps.

This repository is not the production FearProject.

### Communication
- Respond in Russian.
- Explain important engineering decisions.
- Prefer small, focused changes.
- Help the user understand the code, not just generate it.
- Explain unfamiliar commands before using them.

### Development workflow
- Inspect relevant files before making changes.
- Check the current Git state before editing.
- Work in the existing feature branch.
- Do not modify unrelated files.
- Before implementation, summarize the intended approach.
- After implementation, run relevant checks and report results.
- Never claim a test passed unless it was actually executed.
- Show the modified files and explain why each change was needed.

### Git
- Do not create commits, push branches or merge Pull Requests
  without explicit user approval.
- Do not rewrite Git history without approval.
- Do not modify the main branch directly.

### Safety
- Do not access real FearProject infrastructure.
- Never expose credentials, tokens or private keys.
- Do not deploy services or modify real servers.
- Ask before destructive commands.
- Treat real logs and player information as potentially sensitive.

### Code Review
- Check edge cases and incorrect inputs.
- Look for security problems and unintended behavior.
- Identify any tests that were not executed.
- Report remaining risks.