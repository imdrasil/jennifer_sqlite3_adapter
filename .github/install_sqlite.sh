set -exo pipefail

sudo apt-get remove sqlite3

wget https://sqlite.org/2021/sqlite-tools-linux-x86-3360000.zip
unzip sqlite-tools-linux-x86-3360000.zip
sudo cp sqlite-tools-linux-x86-3360000/* /usr/bin
sqlite3 --version
