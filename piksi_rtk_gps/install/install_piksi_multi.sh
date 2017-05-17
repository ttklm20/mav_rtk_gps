#!/bin/bash

#---------------- SBP ----------------
echo " "
echo "Installing SBP library"

GIT_REPO_LIBSBP=git@github.com:swift-nav/libsbp.git
REPO_TAG=v2.2.1 #version you want to chechout before installing

# Install libsbp in $HOME and compile it
mkdir -p ~/software/piksi_sbp_lib
cd ~/software/piksi_sbp_lib
git clone $GIT_REPO_LIBSBP
cd ./libsbp
git checkout $REPO_TAG

# Install requirements.
cd ./python
echo "Installing SBP dependencies"
sudo apt-get install pandoc
sudo pip install tox
sudo pip install -r requirements.txt
sudo pip install markupsafe
sudo python setup.py install
# Build package.
cd ..
sudo make python

echo "SBP Library Installed"

# Export PYTHONPATH and make sure it points to the python subdirectory of the repository
sh -c 'echo "export PYTHONPATH=\${PYTHONPATH}:~/software/piksi_sbp_lib/libsbp/python #add libsbp for RTK GPS Piksi devices" >> ~/.bashrc'
