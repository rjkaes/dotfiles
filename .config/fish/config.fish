# Set the default for ripgrep
set -gx FZF_DEFAULT_COMMAND "rg --files --hidden --follow --glob '!.git/*'"
set -gx FZF_DEFAULT_OPTS "--no-color"

set -gx EDITOR "nvim"

# Disable telemtry
set -gx DOTNET_CLI_TELEMETRY_OPTOUT "true"
set -gx FUNCTIONS_CORE_TOOLS_TELEMETRY_OPTOUT "true"

# Simple aliases for common features.
alias gg rg
alias mutt "mutt -m maildir -f ~/Maildir/"
alias v vi
alias vim vi

# Abbreviations!
abbr -a be 'bundle exec'
abbr -a bu 'bundle update'
abbr -a dn 'dotnet'
abbr -a dnb 'dotnet build'
abbr -a dnr 'dotnet run'
abbr -a g git
abbr -a ga 'git add'
abbr -a gb 'git branch'
abbr -a gc 'git record'
abbr -a gcm 'git switch main'
abbr -a gco 'git checkout'
abbr -a gdc 'git diff --cached'
abbr -a ggp ggpush
abbr -a glg git lg
abbr -a gls git sl
abbr -a grc 'git rebase --continue'
abbr -a grm 'git rebase master'
abbr -a gss 'git ss'
abbr -a gst 'git stash'
abbr -a gup 'git pull --rebase'
abbr -a gw 'git switch'
abbr -a ygg 'sudo yggdrasilctl'

# Source in the various configurations
for conf in /opt/homebrew/share/chruby/chruby.fish /usr/local/share/chruby/chruby.fish ~/src/gem_home/share/gem_home/gem_home.fish
    if test -f $conf
        source $conf
    end
end

# Set the default ruby
chruby ruby-3.3

# Ensure GPG_TTY is set to the current tty so gpg-agent works as expected.
set -x GPG_TTY (tty)

# if test -f /usr/local/opt/node@8/bin/node
#     set -g fish_user_paths "/usr/local/opt/node@8/bin" $fish_user_paths
# end

contains $HOME/bin $fish_user_paths; or set -gp fish_user_paths $HOME/bin

## Force the path to ensure the ePublishing gems and the old version of Ruby is
## first in the path.  Vim does not inherit this path changes when `gem_home`
## and `chruby` are used.
##fish_add_path $HOME/src/epublishing/rails/.gem/ruby/2.6.7/bin $HOME/.gem/ruby/2.6.7/bin
#
#contains $HOME/.gem/ruby/2.6.7/bin $fish_user_paths; or set -gp fish_user_paths $HOME/.gem/ruby/2.6.7/bin
#contains $HOME/src/epublishing/rails/.gems/ruby/2.6.7/bin $fish_user_paths; or set -gp fish_user_paths $HOME/src/epublishing/rails/.gems/ruby/2.6.7/bin
#
##set -gx PATH $HOME/src/epublishing/rails/.gem/ruby/2.6.7/bin $HOME/.gem/ruby/2.6.7/bin $PATH

#fish_add_path "/usr/local/opt/node@12/bin" "/usr/local/sbin"
#set -gx PATH "/usr/local/opt/node@12/bin" "/usr/local/sbin" $PATH
contains /opt/homebrew/bin $fish_user_paths; or set -ga fish_user_paths /opt/homebrew/bin
contains /opt/homebrew/sbin $fish_user_paths; or set -ga fish_user_paths /opt/homebrew/sbin

fish_add_path ~/.dotnet/tools/

# set -gx RUBY_CONFIGURE_OPTS "--with-openssl-dir=(brew --prefix openssl@1.1)"

# Load up rust
contains $HOME/.cargo/bin; or set -ga fish_user_paths $HOME/.cargo/bin

# Required for ruby
set -gx LDFLAGS "$LDFLAGS -L/opt/homebrew/opt/bison/lib -L/opt/homebrew/opt/libffi/lib -L/opt/homebrew/opt/readline/lib"
set -gx CPPFLAGS "$CPPFLAGS -I/opt/homebrew/opt/readline/include -I/opt/homebrew/opt/libffi/include"
set -gx PKG_CONFIG_PATH "/opt/homebrew/opt/readline/lib/pkgconfig:/opt/homebrew/opt/libffi/lib/pkgconfig"

# set -x PATH /home/rjkaes/perl5/bin $PATH;
# set -q PERL5LIB; and set -x PERL5LIB /home/rjkaes/perl5/lib/perl5:$PERL5LIB;
# set -q PERL5LIB; or set -x PERL5LIB /home/rjkaes/perl5/lib/perl5;
# set -q PERL_LOCAL_LIB_ROOT; and set -x PERL_LOCAL_LIB_ROOT /home/rjkaes/perl5:$PERL_LOCAL_LIB_ROOT;
# set -q PERL_LOCAL_LIB_ROOT; or set -x PERL_LOCAL_LIB_ROOT /home/rjkaes/perl5;
# set -x PERL_MB_OPT --install_base\ \"/home/rjkaes/perl5\";
# set -x PERL_MM_OPT INSTALL_BASE=/home/rjkaes/perl5;

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
