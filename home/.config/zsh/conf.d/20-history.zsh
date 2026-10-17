# History
HISTFILE="$ZDOTDIR/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000

setopt EXTENDED_HISTORY        # save timestamp + duration
setopt INC_APPEND_HISTORY      # write each command immediately
setopt SHARE_HISTORY           # share across open sessions
setopt HIST_IGNORE_DUPS        # skip repeat of previous command
setopt HIST_IGNORE_ALL_DUPS    # drop older duplicate
setopt HIST_REDUCE_BLANKS      # trim whitespace
setopt HIST_VERIFY             # show !! expansion before running
setopt HIST_FIND_NO_DUPS       # skip dupes while searching

# history-substring-search: attributes only, readable on any palette
HISTORY_SUBSTRING_SEARCH_CASE_INSENSITIVE=1
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='underline,bold'
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='fg=red,underline'
