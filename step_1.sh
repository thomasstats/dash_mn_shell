useradd -m -c dash dash -s /bin/bash
useradd -m -c "Dash Admin" dashadmin -s /bin/bash -G sudo,dash
echo "Create password for dash user"
passwd dash
echo "Create password for dashadmin user"
passwd dashadmin
echo "Restarting in 5 seconds.  Please log in as dashadmin and complete the remaining steps."
sleep 5
sudo reboot