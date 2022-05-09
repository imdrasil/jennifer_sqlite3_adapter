set -exo pipefail

if [ ! -z "$SQLITE_VERSION" ]; then
  sudo apt-get remove sqlite3

  FOLDER_NAME="sqlite-tools-linux-x86-$SQLITE_VERSION"

  wget "https://sqlite.org/$SQLITE_YEAR/$FOLDER_NAME.zip"
  unzip "$FOLDER_NAME.zip"
  sudo cp -a "$FOLDER_NAME/." /usr/bin
  source ~/.bashrc
fi

# 3.31.1 2020-01-27 by default
sqlite3 --version
