fish_config theme choose catppuccin-frappe

# Set the default for ripgrep
set -gx FZF_DEFAULT_COMMAND "rg --files --hidden --follow --glob '!.git/*'"
set -gx FZF_DEFAULT_OPTS "--no-color"

set -gx EDITOR "nvim"

# Disable telemetry
set -gx DOTNET_CLI_TELEMETRY_OPTOUT "true"
set -gx FUNCTIONS_CORE_TOOLS_TELEMETRY_OPTOUT "true"

# Make sure we can find dotnet
set -gx DOTNET_ROOT "/opt/homebrew/opt/dotnet/libexec"

# Simple aliases for common features.
alias gg rg
alias mutt "mutt -m maildir -f ~/Maildir/"
alias v vi
alias vim vi

# Abbreviations!
abbr -a be 'bundle exec'
abbr -a bu 'bundle update'
abbr -a dn 'dotnet'
abbr -a dnb 'dotnet build --no-restore'
abbr -a dnc 'dotnet clean'
abbr -a dnr 'dotnet run --no-restore'
abbr -a dnrr 'dotnet restore'
abbr -a dnt 'dotnet test --no-restore'
abbr -a g git
abbr -a ga 'git add'
abbr -a gb 'git branch'
abbr -a gc 'git commit -v'
abbr -a gd 'git diff'
abbr -a gco 'git checkout'
abbr -a gdc 'git diff --cached'
abbr -a gl 'git l'
abbr -a ggp ggpush
abbr -a glg 'git hist'
abbr -a grc 'git rebase --continue'
abbr -a grm 'git rebase main'
abbr -a gss 'git ss'
abbr -a gw 'git switch'
abbr -a ygg 'sudo yggdrasilctl'

# Source in the various configurations
for conf in /opt/homebrew/share/chruby/chruby.fish /usr/local/share/chruby/chruby.fish ~/src/gem_home/share/gem_home/gem_home.fish
    if test -f $conf
        source $conf
    end
end

# Set the default ruby
chruby 4.0.1

# Ensure GPG_TTY is set to the current tty so gpg-agent works as expected.
set -x GPG_TTY (tty)

fish_add_path $HOME/bin
fish_add_path /opt/homebrew/bin /opt/homebrew/sbin
fish_add_path ~/.dotnet/tools/
fish_add_path $HOME/.cargo/bin

# Required for ruby
set -gx LDFLAGS "$LDFLAGS -L/opt/homebrew/opt/bison/lib -L/opt/homebrew/opt/libffi/lib -L/opt/homebrew/opt/readline/lib"
set -gx CPPFLAGS "$CPPFLAGS -I/opt/homebrew/opt/readline/include -I/opt/homebrew/opt/libffi/include"
set -gx PKG_CONFIG_PATH "/opt/homebrew/opt/readline/lib/pkgconfig:/opt/homebrew/opt/libffi/lib/pkgconfig"

starship init fish | source
zoxide init fish | source

# Only enable this on MacOS
if test (uname) = "Darwin"
    set -xg SHELL /opt/homebrew/bin/fish

    # Allow way more than 256 open files!
    ulimit -n 12288
end

if test -e $HOME/.config/fish/secret.fish
  source $HOME/.config/fish/secret.fish
end

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.fish 2>/dev/null || :

# bun
set --export BUN_INSTALL "$HOME/.bun"
fish_add_path $BUN_INSTALL/bin
