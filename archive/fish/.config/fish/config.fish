# Fish Config

# kind of don't like this noise
set fish_greeting

alias please="sudo"
alias refresh="source ~/.config/fish/config.fish"

# moving around
alias ~config="cd ~/.config"
alias ~dotfiles="cd ~/.dotfiles"
alias ~lb="cd ~/.local/bin"
alias ~ssh="cd ~/.ssh"

alias ~code="cd ~/code"
alias ~pg="cd ~/code/playground"
alias ~gh="cd ~/code/github.com"
alias ~gho="cd ~/code/github.com/orgs"
alias ~ghp="cd ~/code/github.com/hicksca"

# just being lazy ... lol

alias g="git"

function md
    mkdir -p $argv[1]
    cd $argv[1]
end

function l
    if [ (ls $argv | wc -l) -lt 10 ]
        ls -1 $argv
    else
        ls $argv
    end
end


