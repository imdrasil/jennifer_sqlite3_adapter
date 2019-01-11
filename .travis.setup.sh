set -exo pipefail

sudo apt-get remove sqlite3
sudo add-apt-repository -y ppa:jonathonf/backports
sudo apt-get update && sudo apt-get install sqlite3
sqlite3 --version
crystal sam.cr -- db:setup
