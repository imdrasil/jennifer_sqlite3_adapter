set -exo pipefail

sudo apt-get remove sqlite3
# sudo add-apt-repository -y ppa:jonathonf/backports
# sudo apt-get update && sudo apt-get install sqlite3
wget https://sqlite.org/2019/sqlite-autoconf-3300100.tar.gz
tar -xf sqlite-autoconf-3300100.tar.gz
cd ./sqlite-autoconf-3300100
./configure
make
sudo make install
cd ../
sqlite3 --version
crystal sam.cr db:setup
