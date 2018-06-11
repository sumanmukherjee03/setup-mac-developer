#!/usr/bin/env bash

THIS_DIR="$(cd "$(dirname $BASH_SOURCE[0])" && pwd)"
ROOT_DIR="$THIS_DIR/.."
VIM_SRC_DIR="$(mktemp -d "${TMPDIR}vim_src.XXXX")"
PYTHON_VERSION="2.7.14"
PYTHON3_VERSION="3.4.4"
trap "rm -rf "$VIM_SRC_DIR"" EXIT

export PID="$$" # Get parent pid so that you can kill the main proc from subshells
die() {
  echo >&2 "Error : $@"
  kill -s TERM $PID
  exit 1
}

wrap_around_dir_change() {
  local fn="$1"
  shift 1
  pushd .
  hash -r # rehash bash executables
  eval "$(declare -F "$fn")" "$@"
  popd
}

verify_required_python_versions() {
  command -v python | grep "pyenv" || die "python needs to be installed through pyenv"
  pyenv versions | grep $PYTHON_VERSION || die "Does not $PYTHON_VERSION installed through pyenv"
  pyenv versions | grep $PYTHON3_VERSION || die "Does not $PYTHON3_VERSION installed through pyenv"
}

get_vim() {
  cd "$VIM_SRC_DIR"
  git clone https://github.com/vim/vim.git
}

build_vim_from_src() {
  pyenv local "$PYTHON_VERSION" "$PYTHON3_VERSION"
  local py_config="$(pyenv prefix 2.7.14/lib/python2.7/config)"
  local py3_prefix="$(pyenv prefix 3.4.4)"
  local py3_config="$(${py3_prefix}/bin/python-config --configdir)"
  cd "$VIM_SRC_DIR/vim"
  make distclean
  ./configure \
    --with-features=huge \
    --enable-multibyte \
    --enable-rubyinterp \
    --enable-largefile \
    --disable-netbeans \
    --enable-pythoninterp \
    --with-python-config-dir="$py_config" \
    --enable-python3interp=dynamic \
    --with-python3-config-dir=$py3_config \
    --enable-perlinterp \
    --enable-luainterp \
    --with-lua-prefix="$(brew --prefix)" \
    --with-luajit \
    --enable-gui=auto \
    --enable-fail-if-missing \
    --with-tlib=ncurses \
    --prefix=$HOME
    --enable-cscope
  make && make install
  pyenv local --unset
}

customize_vim() {
  curl -H "Cache-Control: no-cache" -sSL https://raw.githubusercontent.com/sumanmukherjee03/vim_setup/master/bootstrap.sh | bash
  cd $HOME/.vim
  make
}

main() {
  verify_required_python_versions
  get_vim
  wrap_around_dir_change build_vim_from_src
  customize_vim
}

[[ "$BASH_SOURCE" == "$0" ]] && main "$@"
