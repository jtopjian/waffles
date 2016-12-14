setup() {
  os.groupadd --group jdoe --gid 999
}

create() {
  os.useradd --user jdoe --gid 999 --uid 999 --homedir /home/jdoe
}

update() {
  os.useradd --user jdoe --gid 999 --uid 999 --homedir /home/jdoe --groups sudo
}

delete() {
  os.useradd --state absent --user jdoe
}

teardown() {
  os.groupadd --state absent --group jdoe
}
