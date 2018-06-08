#!/usr/bin/env bash

[[ ! -z "$BREW_APP_INSTALL_DIR" ]] || export BREW_APP_INSTALL_DIR="$HOME/Applications"
mkdir -p "$BREW_APP_INSTALL_DIR"

install_homebrew() {
  command -v brew || /usr/bin/env ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
}

prep_homebrew() {
  echo 'export PATH=/usr/local/bin:/usr/local/sbin:/usr/local/opt:$PATH' >> $HOME/.bash_profile
  brew update
  brew cleanup
  brew cask cleanup
  brew doctor
}

setup_brew_taps() {
  brew tap caskroom\/versions
  brew tap homebrew\/services
  brew tap caskroom\/fonts
  brew tap brona\/iproute2mac
  brew tap universal-ctags\/universal-ctags
  brew tap discoteq\/discoteq
  brew tap msoap\/tools
  brew tap pivotal\/tap
}

install_apps_from_cask() {
  # New mac os - high sierra may have trouble installing virtualbox
  # Follow this link to fix that - https://developer.apple.com/library/content/technotes/tn2459/_index.html
  # This could also be because the security ad privacy settings in mac is not allowing virttualbox to install stuff from oracle
  # Allowing that could fix the problem too
  command -v virtualbox || brew cask install --appdir="$BREW_APP_INSTALL_DIR" virtualbox
  brew cask install --appdir="$BREW_APP_INSTALL_DIR" \
    java \
    atom \
    vagrant \
    tcl \
    font-inconsolata \
    kindle \
    minikube \
    minishift
}

install_packages_from_brew() {
  brew install \
    gcc \
    curl \
    zeromq \
    coreutils \
    findutils \
    gnu-tar \
    gnu-sed \
    gawk \
    gnutls \
    gnu-indent \
    gnu-getopt \
    pgrep \
    ngrep \
    sgrep \
    tree \
    pstree \
    moreutils \
    cmake \
    tmux \
    readline \
    openssl \
    git \
    git-extras \
    mercurial \
    python \
    ruby \
    node \
    golang \
    mysql \
    postgres \
    redis \
    rabbitmq \
    ncurses \
    autoconf \
    automake \
    libtool \
    mytop \
    pg_top \
    dnstop \
    passenger \
    iftop \
    imagemagick \
    ag \
    ack \
    diff-so-fancy \
    colordiff \
    diffutils \
    maven \
    maven-shell \
    maven-completion \
    tig \
    python3 \
    lua@5.1 \
    luajit \
    bash \
    autoenv \
    rbenv \
    jenv \
    goenv \
    pyenv \
    pyenv-virtualenv \
    nvm \
    awscli \
    tcptrace \
    iproute2mac \
    mtr \
    jq \
    mycli \
    pgcli \
    krb5 \
    ansible \
    fio \
    docker \
    docker-machine \
    kubectl \
    spark \
    bash-completion@2 \
    ctags \
    git-quick-stats \
    flock \
    ipcalc \
    nmap \
    iftop \
    nethogs \
    vnstat \
    multitail \
    modd \
    shell2http \
    vegeta \
    springboot \
    dep

  brew install homebrew\/dupes\/grep --with-default-names
  brew install nginx --with-passenger
  brew install reattach-to-user-namespace --with-wrap-pbcopy-and-pbpaste
  brew install --HEAD universal-ctags
}

install_extras_from_brew() {
  brew cask install --appdir="$BREW_APP_INSTALL_DIR" iterm2
}

post_brew_package_installation() {
  mkdir -p "$HOME/lib"
  echo "alias bci='brew cask install --appdir=$BREW_APP_INSTALL_DIR'" >> $HOME/.bash_profile
  echo 'export PATH="$HOME/bin:$PATH"' >> $HOME/.bash_profile
  echo 'export PATH="$(brew --prefix)/opt/docker@1.11/bin:$(brew --prefix)/opt/coreutils/libexec/gnubin:$(brew --prefix)/opt/findutils/libexec/gnubin:$(brew --prefix)/opt/gnu-tar/libexec/gnubin:$(brew --prefix)/opt/gnu-sed/libexec/gnubin:$(brew --prefix)/opt/sqlite/bin:$(brew --prefix)/opt/curl/bin:$(brew --prefix)/bin:$(brew --prefix)/sbin:$(brew --prefix)/opt:$(brew --prefix)/share:$PATH"' >> $HOME/.bash_profile
  echo 'export MANPATH="$(brew --prefix)/opt/coreutils/libexec/gnuman:$(brew --prefix)/opt/findutils/libexec/gnuman:$(brew --prefix)/opt/gnu-tar/libexec/gnuman:$(brew --prefix)/opt/gnu-sed/libexec/gnuman:$MANPATH"' >> $HOME/.bash_profile
  echo '. $(brew --prefix)/opt/autoenv/activate.sh' >> $HOME/.bash_profile
  echo 'if which pyenv-virtualenv-init > /dev/null; then eval "$(pyenv init -)" && eval "$(pyenv virtualenv-init -)"; fi' >> $HOME/.bash_profile
  [[ -x $(brew --prefix)/bin/nvm ]] || ln -s "$(brew --prefix)/opt/nvm" "$(brew --prefix)/bin/nvm"
  mkdir -p $HOME/.nvm
  echo 'export NVM_DIR="$HOME/.nvm"' >> $HOME/.bash_profile
  echo '. "$(brew --prefix)/opt/nvm/nvm.sh"' >> $HOME/.bash_profile
  echo 'eval "$(rbenv init -)"' >> $HOME/.bash_profile
  echo 'export PATH="$HOME/.jenv/bin:$PATH"' >> $HOME/.bash_profile
  echo 'eval "$(jenv init -)"' >> $HOME/.bash_profile
  echo 'eval "$(goenv init -)"' >> $HOME/.bash_profile
  echo 'for completion_file in $(brew --prefix)/etc/bash_completion.d/*; do . "$completion_file"; done' >> $HOME/.bash_profile
  . $HOME/.bash_profile && kubectl completion bash > $HOME/.kubectl-completion
  echo '. "$HOME/.kubectl-completion"' >> $HOME/.bash_profile
  echo 'type -t __ltrim_colon_completions | grep -i function || __ltrim_colon_completions() { :; }' >> $HOME/.bash_profile
  echo 'eval $(minishift oc-env)' >> $HOME/.bash_profile
  [[ -d $HOME/.pyenv/plugins/pyenv-implict ]] \
    || git clone https://github.com/concordusapps/pyenv-implict.git $HOME/.pyenv/plugins/pyenv-implict
  echo 'if [[ -f ~/.bash_utils.sh ]]; then . ~/.bash_utils.sh; fi' >> ~/.bash_profile
}

main() {
  install_homebrew
  prep_homebrew
  setup_brew_taps
  install_apps_from_cask
  install_packages_from_brew
  install_extras_from_brew
  post_brew_package_installation
}

[[ "$BASH_SOURCE" == "$0" ]] && main "$@"
