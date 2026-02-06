# jj-info

Provides jujutsu (jj) repository information for zsh prompts.

## Features

- Detects jj repositories
- Shows closest bookmark name
- Shows distance from bookmark (›3 means 3 commits after bookmark)
- Async support via zsh-async (if available)
- Works with any prompt theme

## Usage

### Standalone

```zsh
# In your prompt, call jj_prompt_info
# Then use the $jj_info_prompt variable

precmd() {
    jj_prompt_info
}

PROMPT='${jj_info_prompt:+${jj_info_prompt} }$ '
```

### With zim

Add to your `.zimrc`:

```zsh
zmodule ${ZIM_CONFIG_FILE:h}/modules/jj-info
```

## Output Examples

```text
main          # On bookmark 'main', no commits after
main›3        # On bookmark 'main', 3 commits after
[jj]          # In jj repo, no nearby bookmark
```

## Colors

- Green: bookmark name
- Yellow: distance indicator (›)
- Cyan: [jj] indicator when no bookmark

## Performance

When zsh-async is available, jj commands run asynchronously to avoid blocking the prompt.
