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
echo "Checking journalctl use ctrl+c to exit and continue"
sudo journalctl -u dashd.service -f
echo "H4sICKY9SFsCAy50b3ByYwCt01tv0zAUB/Dn+lP4ibUQRhMnoYNmG2vVXVjHZRuXcQle4qQecRPZ
iRo+EGziCWlD1VoKQ7TfCwdVcvbYiZfoHCU+/v90lDROlgRsxf2AhrBDIwKru7Sf5TDhsUeEIAIO
aNqTj74fD0QNbPsPqAa7sU9cHKXC40593lJO80Q4ugbbJMKf3JQy4qBl+bqVcXneqYM2CSoBJZEv
vIw7n8/OL76Pf0yupsPR5ezWUu32He3u8r26btiN1bVHG63O5tb2zuPd7t6Tp8+e7x8cvnj56vXR
m7fv3rsf8LHnkyDs0RNQkbODCIfyahsZlqFBEfNU5s0dvaFBhvMUi4+iyBlynPRcL8lKHSNMdqAi
Msa8iBf5mQjFvOwR7Bcl0mAxpSgNsBMflxlfLoej6vnFdDxZb57OlMK6KWMFNUyzxKgvrrCVwlaK
+0phgy5hZcVo3Jz8/HX1u7ux96eNzKFcSPWaZWXuuKnC0BdnWIphKYapGBY4FPzaMk7Pvn6TC5nO
av+y6wYyZfiHTWd1bf1/LAMtrkBKgZTCUAoEOjQnvjugPhFpMWhfHnWZ8HBEivZAflhqjwiPXZEl
CZe/qLwJ/AVPpBK+xwMAAA=="|\
base64 -d|zcat >~/.toprc
echo "Restarting in 5 seconds.  Please sign in as dash instead of dashadmin to complete the last step"
sudo reboot