#!/usr/bin/env bash

THIS_DIR="$(cd "$(dirname "$BASH_SOURCE")" && pwd)"
ROOT_DIR="$(cd "$(dirname "$THIS_DIR")" && pwd)"

change_shell() {
  sudo grep '/usr/local/bin/bash' /etc/shells \
    || sudo echo '/usr/local/bin/bash' >> /etc/shells
  chsh -s /usr/local/bin/bash
}

preserve_bash_profile() {
  mv $HOME/.bash_profile $HOME/.bash_profile.bak
}

install_bashit() {
  git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash_it
  echo y > bash-it-install-option \
    && /bin/bash $HOME/.bash_it/install.sh < bash-it-install-option \
    && rm bash-it-install-option
}

add_composure() {
  pushd .
  cd $HOME/.bash_it/custom \
    && curl -L http://git.io/composure > composure.sh \
    && chmod +x composure.sh
  popd
}

create_custom_files() {
  touch $HOME/.bash_it/custom/aliases.bash
  touch $HOME/.bash_it/custom/utils.bash
  cp $ROOT_DIR/templates/bash_utils.sh $HOME/.bash_utils.sh
  cp $ROOT_DIR/templates/activate_profile.sh $HOME/.activate_profile.sh
}

enable_bash_it_completions() {
  . "$HOME/.bash_it/bash_it.sh" && bash-it enable completion \
    awscli \
    brew \
    bundler \
    capistrano \
    defaults \
    dirs \
    django \
    gem \
    git \
    grunt \
    gulp \
    jboss7 \
    maven \
    npm \
    packer \
    pip \
    pip3 \
    packer \
    ssh \
    terraform \
    vault \
    test_kitchen \
    salt \
    tmux \
    vagrant \
    virtualbox \
    rake \
    docker
}

enable_bash_it_plugins() {
  . "$HOME/.bash_it/bash_it.sh" && bash-it enable plugin \
    aws \
    dirs \
    extract \
    java \
    javascript \
    nginx \
    node \
    osx \
    projects \
    python \
    ssh \
    tmux \
    man \
    fzf \
    postgres \
    explain \
    browser \
    docker
}

enable_bash_it_aliases() {
  . "$HOME/.bash_it/bash_it.sh" && bash-it enable alias \
    ag \
    ansible \
    bundler \
    docker \
    git \
    heroku \
    homebrew \
    homebrew-cask \
    maven \
    npm \
    osx \
    rails \
    tmux \
    vagrant \
    vim \
    emacs \
    docker \
    docker-compose
}

setup_bashit() {
  enable_bash_it_completions
  enable_bash_it_plugins
  enable_bash_it_aliases
}

update_bash_profile() {
  cat $HOME/.bash_profile.bak >> $HOME/.bash_profile
}

main() {
  change_shell
  preserve_bash_profile
  install_bashit
  add_composure
  create_custom_files
  setup_bashit
  update_bash_profile
}

[[ "$BASH_SOURCE" == "$0" ]] && main "$@"
