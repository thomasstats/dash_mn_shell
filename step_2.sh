if [ `id -u` -ne 0 ]; then
sudo bash -c \
"grep -q \".*PermitRootLogin [ny][oe].*\" /etc/ssh/sshd_config &&\
sed -i 's/.*PermitRootLogin [ny][oe].*/PermitRootLogin no/g' /etc/ssh/sshd_config||\
echo \"PermitRootLogin no\">>/etc/ssh/sshd_config"
else echo "Only run this block as your dashadmin user, not root."; fi
sudo apt update
sudo apt upgrade
sudo apt install ufw python virtualenv git unzip pv speedtest-cli
sudo ufw allow ssh/tcp &&\
sudo ufw limit ssh/tcp &&\
sudo ufw allow 9999/tcp &&\
sudo ufw logging on &&\
sudo ufw enable
if [ $(free -m|grep Swap|awk '{print $2}') -lt 2048 ]
then
  echo "Adding 2GB swap..."
  sudo bash -c "fallocate -l 2G /var/swapfile&&\
  chmod 600 /var/swapfile&&\
  mkswap /var/swapfile&&\
  swapon /var/swapfile&&\
  grep -q \"^/var/swapfile.none.swap.sw.0.0\" /etc/fstab ||\
  echo -e \"/var/swapfile\tnone\tswap\tsw\t0\t0\" >>/etc/fstab"
else
  echo "You already have enough swap space."
fi
sudo bash -c "echo \"vm.overcommit_memory=1\">>/etc/sysctl.conf"
sudo reboot