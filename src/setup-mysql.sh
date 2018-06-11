#!/usr/bin/env bash

[[ -z "$MYSQL_PASSWORD" ]] || MYSQL_PASSWORD='welcome2mysql'

__ok() {
  echo -n ''
}

check_mysql() {
  command -v mysql.server \
    || { echo "ERROR >> mysql is not installed"; exit 1; }
  __ok
}

start_mysql() {
  ps -ef | grep mysql[d] \
    || mysql.server start
  __ok
}

setup_root() {
  mysqladmin -u root password "$MYSQL_PASSWORD"
  __ok
}

post_setup_mod() {
  mysql -h localhost --user=root --password="$MYSQL_PASSWORD" --execute="SET @@global.sql_mode='';"
  __ok
}

main() {
  check_mysql
  start_mysql
  setup_root
  post_setup_mod
}

[[ "$BASH_SOURCE" == "$0" ]] && main "$@"
