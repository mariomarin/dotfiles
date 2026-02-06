# jj-gitster

Extends the gitster prompt theme with jujutsu (jj) repository information.

## Features

- Automatically shows jj bookmark info in gitster prompt
- Appears between directory and git status
- No configuration needed
- Uses async updates via jj-info module

## Usage

### Option 1: Replace gitster with jj-gitster (Recommended)

In your `.zimrc`:

```zsh
# Replace:
# zmodule gitster

# With:
zmodule ${ZIM_CONFIG_FILE:h}/modules/jj-info
zmodule ${ZIM_CONFIG_FILE:h}/modules/jj-gitster
```

### Option 2: Manual Integration

Keep gitster and add jj-info manually to your prompt in `.zshrc`:

```zsh
# In .zshrc, after zim modules load
precmd() {
    jj_prompt_info
}

# Modify PROMPT to include jj info
PROMPT='${prompt_pwd}${jj_info_prompt:+ ${jj_info_prompt}} ${git_info}${editor_info}'
```

## Example Output

### In jj repository

```text
~/project main›2 on main [!1]
```

- `~/project` - directory (prompt-pwd)
- `main›2` - jj bookmark with 2 commits after (jj-info)
- `on main [!1]` - git status (git-info)

### In git-only repository

```text
~/project on main [!1]
```

No jj info shown - works like standard gitster.

## Requirements

- jj-info module (loaded first)
- gitster theme
- zsh-async (optional, for async updates)
