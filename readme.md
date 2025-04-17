# GitHub SSH Key Setup Script

Automate your SSH workflow for a ** GitHub identity** using this battle-tested shell script. No more repeated password prompts or broken Git configs—this script handles everything from key creation to connection verification, and appends the config without nuking your existing setup.

## What This Script Does

1. **Generates an SSH key** if one doesn't exist
2. **Appends** your SSH config with a unique host alias (without overwriting it)
3. **Starts the ssh-agent** and adds the key
4. **Verifies SSH connection** to GitHub with your alias
5. Provides a custom **clone command** at the end

## Usage

```bash
chmod +x ssh_setup.sh
./ssh_setup.sh \
  --email your_email@example.com \
  --alias github.com-personal
```

You can also specify a custom SSH directory:

```bash
./ssh_setup.sh \
  --email your_email@example.com \
  --alias github.com-personal \
  --key-dir /your/custom/.ssh
```

## Files and Configs Created

- `~/.ssh/id_rsa_<alias_suffix>` → Private key
- `~/.ssh/id_rsa_<alias_suffix>.pub` → Public key
- `~/.ssh/config` → SSH config (entry is appended, not overwritten)

### SSH Config Example (Appended)
```bash
Host github.com-personal
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_rsa_personal
```

## Output Example
```
==> Step 1: Preparing SSH directory at ~/.ssh
[status] SSH directory ready
==> Step 2: Generating SSH key for your_email@example.com
[status] SSH key generated at ~/.ssh/id_rsa_personal
==> Step 3: Appending SSH config for github.com-personal
[status] SSH config appended
==> Step 4: Starting ssh-agent and adding key
[status] ssh-agent running and key added
==> Step 5: Verifying SSH connection for github.com-personal
[status] SSH verification successful
✔ All steps completed. You can now clone with:
    git clone git@github.com-personal:username/repo.git
```

## Pro Tips
- Use descriptive alias names (e.g., `github.com-work`, `github.com-openai`)
- Backup your `.ssh` folder regularly
- Combine with `git config --local user.name` for full identity separation

## Requirements
- Bash
- ssh-keygen, ssh-agent, ssh-add
- GitHub account

## Quote of the Script
> "Guard your private key like it’s the last line of code before production."


© CurioCampus
