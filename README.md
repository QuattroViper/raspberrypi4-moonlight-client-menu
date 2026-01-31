## Make executable: 

chmod +x ~/raspberrypi4-moonlight-client-menu/menu.sh

## Make service 

sudo nano /etc/systemd/system/moonlight-menu.service
-- Copy moonlight-menu.service to file
sudo systemctl enable moonlight-menu.service
sudo reboot
