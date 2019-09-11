#!/bin/bash
# Author: davetoshi, AXErunners
# Thanks to all who published information on the Internet!
#
# Disclaimer: Your use of this script is at your sole risk.
# This script and its related information are provided "as-is", without any warranty,
# whether express or implied, of its accuracy, completeness, fitness for a particular
# purpose, title or non-infringement, and none of the third-party products or information
# mentioned in the work are authored, recommended, supported or guaranteed by The Author.
# Further, The Author shall not be liable for any damages you may sustain by using this
# script, whether direct, indirect, special, incidental or consequential, even if it
# has been advised of the possibility of such damages.
#
# 
# You may have to perform your own validation / modification of the script to cope with newer
# releases of the above software.
#
# Tested with Ubuntu 18.04
#
cat << "EOF"
    ______     __  __     ______
   /\  __ \   /\_\_\_\   /\  ___\
   \ \  __ \  \/_/\_\/_  \ \  __\
    \ \_\ \_\   /\_\/\_\  \ \_____\
     \/_/\/_/   \/_/\/_/   \/_____/
 ______     ______     ______     ______
/\  ___\   /\  __ \   /\  == \   /\  ___\
\ \ \____  \ \ \/\ \  \ \  __<   \ \  __\
 \ \_____\  \ \_____\  \ \_\ \_\  \ \_____\
  \/_____/   \/_____/   \/_/ /_/   \/_____/

EOF
#
# Variables
# UPDATE THEM TO MATCH YOUR SETUP !!
#
PUBLIC_IP=<your public IP address>
EMAIL=<your email address>
PAYOUT_ADDRESS=<your AXE wallet address to receive fees>
USER_NAME=<linux user name>
Location=<pool location country or state>

FEE=0.5
DONATION=0.5
AXE_WALLET_URL=https://github.com/AXErunners/axe/releases/download/v1.4.0.2/axecore-1.4.0.2-x86_64-linux-gnu.tar.gz
AXE_WALLET_ZIP=axecore-1.4.0.2-x86_64-linux-gnu.tar.gz
AXE_WALLET_LOCAL=axecore-1.4.0
P2POOL_FRONTEND=https://github.com/justino/p2pool-ui-punchy
P2POOL_FRONTEND2=https://github.com/hardcpp/P2PoolExtendedFrontEnd

#
sudo apt update
sudo apt upgrade
sudo apt install ufw git fail2ban python virtualenv unzip pv
sudo ufw allow ssh/tcp
sudo ufw limit ssh/tcp
sudo ufw allow 9937/tcp
sudo ufw allow 9936/tcp
sudo ufw allow 9337/tcp
sudo ufw allow 7923/tcp
sudo ufw allow 8999/tcp
sudo ufw logging on
sudo ufw disable
sudo ufw enable



#install axe

git clone https://github.com/axerunners/axerunner
~/axerunner/axerunner install
~/axerunner/axerunner install sentinel
~/axerunner/axerunner restart now
# Install Prerequisites
#
cd ~
sudo apt-get --yes install python-zope.interface python-twisted python-twisted-web python-dev libncurses-dev
sudo apt-get --yes install git python-zope.interface python-twisted python-twisted-web
sudo apt-get --yes install gcc g++
sudo apt-get --yes install git

#
# Get latest p2pool-axe
#
mkdir git
cd git
git clone https://github.com/axerunners/p2pool-axe
cd p2pool-axe
git submodule init
git submodule update
cd axe_hash
python setup.py install --user

#
# Install Web Frontends
#
cd ..
mv web-static web-static.old
git clone $P2POOL_FRONTEND web-static
mv web-static.old web-static/legacy
cd web-static
git clone $P2POOL_FRONTEND2 ext

#
# create config.js
#

cat <<EOT >> ~/git/p2pool-axe/web-static/js/config.js
var config = {
  myself: [
    "1MzFr1eKzLEC1tuoZ7URMB7WWBMgHKimKe",
    "LSRfZJf75MtwzrbAUfQgqzdK4hHpY4oMW3"
  ],
  host: "http://$PUBLIC_IP:7923",
  // data reload interval in seconds
  reload_interval: 30,
  // chart reload interval in seconds
  reload_chart_interval: 600,
  // HTML to load at top of page
  header_content_url: "http://$PUBLIC_IP:7923/static/hello.html",
  // Default Theme
  theme: 'cyborg'
}
EOT

#
#create page header
#
cat <<EOT >> ~/git/p2pool-axe/web-static/hello.html
<head>
  <meta content="text/html; charset=ISO-8859-1" http-equiv="content-type">
  <title>AXE p2pool - Welcome</title>
 </head>
 <body>
  <big style="font-weight: bold;"><big>Welcome to AXE p2pool</big></big><br>
        <section class="panel panel-default clearfix">
                <div class="panel-heading">
                        <h4>$Location Node</h4>
                </div>
                <ul class="list-group status info_one pull-left">
                        <li class="list-group-item"><center><br><img src="https://raw.githubusercontent.com/AXErunners/media/master/axerunners-x-100.png"></img>
                                <br>
				<br>AXE Core version 1.4.0.2
                                <br><a href="https://axerunners.com/" target="_blank">axerunners.com</a><br$
                        </li>
                </ul>
                <ul class="list-group status info_two pull-right">
                        <li class="list-group-item"><br>Use the following information to get started:<br>
                                <br>&nbsp; &nbsp; Pool URL:&nbsp; &nbsp; &nbsp;<span>stratum+tcp://$PUBLIC_IP:7923</span>
                                <br>&nbsp; &nbsp; User ID:&nbsp; &nbsp; &nbsp; &nbsp;<span>Use your AXE wallet address</span>
                                <br>&nbsp; &nbsp; Password:&nbsp; &nbsp;<span>Use any password (ignored by pool)</span>
                                <center><br><span><b>Do not mine directly to an exchange address!</b></span><br></center>
                        </li>
                </ul>
        </section>
  </body>
</html>
EOT



#
# Prepare p2pool startup script
#
cat <<EOT >> ~/p2pool.start.sh
python ~/git/p2pool-axe/run_p2pool.py --external-ip $PUBLIC_IP -f $FEE --give-author $DONATION -a $PAYOUT_ADDRESS
EOT

if [ $? -eq 0 ]
then
echo
echo Installation Completed.
echo Now wait till axe runner has finished sync
echo
echo axerunner/axerunner status
echo 
echo once sync is complete aprox 10 mins
echoYou can start p2pool instance by command:
echo start screen
echo
echo bash ~/p2pool.start.sh
echo 
echo NOTE: you will need to wait until AXE runner has finished
echo blockchain synchronization before the p2pool instance is usable.
echo
fi
