useradd -m -c dash dash -s /bin/bash
useradd -m -c "Dash Admin" dashadmin -s /bin/bash -G sudo,dash
passwd dash
passwd dashadmin
sudo reboot