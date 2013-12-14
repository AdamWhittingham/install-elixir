#!/bin/bash

install_version=$1
elixir_version=${install_version:-'0.11.2'}
elixir_base=/opt/elixir

function install_elixir {
  echo "Installing Elixir ${elixir_version} to ${elixir_base}"

  # Lets make our new folder and move in
  sudo mkdir $elixir_base
  sudo chown $USER $elixir_base
  pushd $elixir_base >/dev/null

  # Right, lets start off with the bare essentials
  sudo apt-get install build-essential wget

  # Elixir runs on the Erlang VM, so lets add the erlang repos...
  wget http://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb
  sudo dpkg -i erlang-solutions_1.0_all.deb
  rm erlang-solutions_1.0_all.deb

  #... and install Erlang
  sudo apt-get update
  sudo apt-get install esl-erlang

  # Now for the fun stuff, lets get Elixir
  wget https://github.com/elixir-lang/elixir/archive/v${elixir_version}.tar.gz
  tar xf v${elixir_version}.tar.gz
  rm v${elixir_version}.tar.gz
  cd ${elixir_base}/elixir-${elixir_version}
  make clean test

  # We'll add a 'current' symlink to make it easier to rollback
  cd $elixir_base
  ln -sf elixir-${elixir_version} current

  # At last,  we can just add it to the path!
  source_script=/var/tmp/elixir
  cat >$source_script <<-EOF
  export ELIXIR_HOME=${elixir_base}/current
  export PATH=\$ELIXIR_HOME/bin:\$PATH
EOF
  chmod a=rx $source_script
  sudo mv $source_script /etc/profile.d/elixir

  popd >/dev/null
}

install_elixir

# Source our new file in this shell so we're ready to rock!
source /etc/profile.d/elixir
