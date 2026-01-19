return {
  "ibhagwan/fzf-lua",
  opts = {
    files = {
      cmd = "fd --type f --hidden --exclude .git --exclude node_modules",
    },
    file_ignore_patterns = {
      "node_modules/",
      ".git/",
    },
  },
}
