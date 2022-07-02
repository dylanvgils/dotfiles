# Known issues
This page describes the known issues of this dotfiles repository.

## Autocomplete not working correctly
Due to an issue is you in the Dracula zsh theme the autocomplete maybe doesn't work correctly. For example:


To fix this issue revert to commit `d7626ad`, this can be done with the following command:

```bash
cd ./zsh/.local/share/zsh/themes
git checkout d7626ad9ed3fb1929082bd3d6815160d8e016247
```

For mor information see:
https://github.com/dracula/zsh/issues/46
