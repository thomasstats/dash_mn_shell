cd /tmp/
wget https://github.com/dashpay/dash/releases/download/v0.16.0.1/dashcore-0.16.0.1-x86_64-linux-gnu.tar.gz
sudo bash -c "cd /opt&& rm -f dash 2>/dev/null;tar xvf /tmp/dashcore-0.16.0.1-x86_64-linux-gnu.tar.gz&& ln -s dashcore-0.16.0 dash"
sudo bash -c "echo -e \"MANPATH_MAP\t/opt/dash/bin\t\t/opt/dash/share/man\">>/etc/manpath.config"
sudo bash -c "echo 'PATH=/opt/dash/bin:\$PATH'>>/home/dash/.profile"
sudo -u dash bash -c "mkdir -p /home/dash/.dashcore&&cat >/home/dash/.dashcore/dash.conf<<\"EOF\"
#----
rpcuser=rpcuser$(< /dev/urandom tr -dc A-Za-z0-9 | head -c${1:-8};echo)
rpcpassword=rpcpassword$(< /dev/urandom tr -dc A-Za-z0-9 | head -c${1:-8};echo)
rpcallowip=127.0.0.1
#----
listen=1
server=1
daemon=1
#----
masternodeblsprivkey=XXXXXXXXXXXXXXXXXXXXXX
externalip=$(wget -qO- http://ipecho.net/plain)
#----
EOF"
sudo -i -u dash bash -c "nano ~/.dashcore/dash.conf"
sudo mkdir -p /etc/systemd/system&&\
sudo bash -c "cat >/etc/systemd/system/dashd.service<<\"EOF\"
[Unit]
Description=Dash Core Daemon
After=syslog.target network-online.target

# Notes:
#
# Watch the daemon service actions in the syslog journal with:
# sudo journalctl -u dashd.service -f

[Service]
Type=forking
User=dash
Group=dash

# Make dashd less likely to be killed when RAM is low.
OOMScoreAdjust=-1000

ExecStart=/opt/dash/bin/dashd -pid=/home/dash/.dashcore/dashd.pid
# Time that systemd gives a process to start before shooting it in the head
TimeoutStartSec=10m

# If ExecStop is not set, systemd sends a SIGTERM, which is \"okay\", just not ideal
ExecStop=/opt/dash/bin/dash-cli stop

# Time that systemd gives a process to stop before shooting it in the head
TimeoutStopSec=120

Restart=on-failure
# If something triggers an auto-restart, let's wait a bit before taking further action
# Note: This value is in addition to the stop sleep time
RestartSec=120

# In this interval span of time, we allow systemd to start dashd "burst" number
# of times. With Dash we really only want one instance started, so... let's
# really limit this. But we want to give systemd some room to attempt to
# correct things. To be honest, I think the way things are configured between
# these settings and TimeoutStartSec, only one instance will be initiated.
StartLimitInterval=300
StartLimitBurst=3

[Install]
WantedBy=multi-user.target

# Really useful:
# * https://www.digitalocean.com/community/tutorials/understanding-systemd-units-and-unit-files
# * https://www.freedesktop.org/software/systemd/man/systemd.service.html
# * man systemd, man systemd.service, and man systemd.unit

EOF"
sudo systemctl daemon-reload &&\
sudo systemctl enable dashd &&\
sudo systemctl start dashd &&\
echo "Dash is now installed as a system service and initializing..."
#systemctl status dashd.service
echo "Checking journalctl use ctrl+c to exit and continue.  Please follow the instructions in the manual after exiting."
sudo journalctl -u dashd.service -f