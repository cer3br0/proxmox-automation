# VM-power on/off

## These scripts are used for switch on / shutdown vm using VM ID  
Ensure you have a remote user with dedicated ssh key and appropriate sudo permissions for start / stop VM :
```bash
remoteuser ALL=(ALL) NOPASSWD: /usr/sbin/qm start *, /usr/sbin/qm stop *
```
## Author
Cer3br0