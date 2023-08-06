# PS-MountNetworkDrive

## Mount a network drive in Microsoft Windows

With this program it's possible to mount a network drive in a microsoft windows environment (10 or higher) permanently. It's for server shares and certain user, that can used them (credentials are needed).

## Notifications

* Use the structure like the default values are shown: "Z:" - not "Z:\\", "\\\server\shareDirectory" and so on
* The registry entries ensures that the network drive is still present after a reboot
* The network drive will show after a reboot in the explorer

## How to install the PS-MountNetworkDrive

1. Clone this project
2. Edit the main.ps1 as following:
    - Set you network drive letter in line 15
    - Enter the full path to the shared directory. Don't use as servername the IP! If you have not a servername, please change this in the 
      "C:\Windows\System32\drivers\etc\hosts" file (root/ admin rights are needed).
    - In line 19 the IPv4 of the server is required
    - The debug flag in line 21 must be change to $false, if you want do mount a network drive
3. Save the file main.ps1 after editing
4. Run the PS script (you need the credentials for the network drive and a ethernet connection to the server as well)
