# docker-hakchi

## What it is

docker-hakchi is a dockerized version of madmonkey1907's hakchi program. It allows you to run hakchi under Windows by
compiling and running it inside a Debian container.

## How to use

### Requirements

- Install Docker on your computer (this guide is based on [Docker Toolbox](https://docs.docker.com/toolbox/toolbox_install_windows/))
- Install [Xming](https://sourceforge.net/projects/xming/)
- Install the [Oracle VM VirtualBox Extension Pack](https://www.virtualbox.org/wiki/Downloads)

### Booting the NES Classic Edition in FEL mode

To boot the NES Classic Edition in FEL mode, connect the unit via USB, then press and hold the RESET button. Press the
POWER button once, while you continue to hold RESET. The device will boot into FEL mode. Note that the LED will not turn
on.

### USB Forwarding Setup

- If you are using Docker for the first time on this machine, open up the "Docker Quickstart Terminal". This will create
  and boot a VirtualBox machine in the background.
- Open a command prompt as administrator and run `docker-machine stop` to stop the Docker virtual machine again.
- Plug in the Nintendo Classic Mini and boot into FEL mode.
- Open VirtualBox and go to the settings of the Docker virtual machine ("default").
- Check "Enable USB Controller" and select USB 2.0 or USB 3.0.
- Click on the icon to add a new USB Device Filter for the Nintendo Classic Mini. VirtualBox lists it as
  ```
  Onda (unverified) V972 tablet in flashing mode [02B3]
  ```
    - Vendor ID: 1f3a
    - Product ID: efe8
    - Revision: 02b3
- Save your settings

### Xming setup

- Open XLaunch, choose "Multiple Windows", "Start no client", "No access control".

### Running the container

- Open the "Docker Quickstart Terminal" and cd to the ninspect folder
- Run `docker-compose run -e DISPLAY=<host ip>:0 hakchi` where _\<host ip\>_ is the IP address of your Xming host, i.e.
  the IP address of your computer. Double-check the Xming log file and look for a line
  `XdmcpRegisterConnection: newAddress ?.?.?.?` to find it. Alternatively, try `./hakchi.sh`
- You should now see the hakchi window!
- When you are done, close hakchi and you will find the dumps in the dump folder that has been created where this file
  resides.

## Test setup

Tested on Windows 7 Professional x64 with Docker Toolbox, using Docker version 17.04.0-ce, build 4845c56

## Troubleshooting

### docker-compose run fails

An error message like the following suggests you did not go through [USB Forwarding Setup](#usb-forwarding-setup):

```
error gathering device information while adding custom device "/dev/bus/usb"
``` 

### USB forwarding does not work

If USB forwarding is not working for you, this may be due to USB filtering. You may be able to solve this problem by
following [these directions](https://forums.virtualbox.org/viewtopic.php?f=6&t=39104#p176270:):

- Open regedit and go to `HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Class\{36FC9E60-C465-11CF-8056-444553540000}`
- If the entry "UpperFilters"  exists, delete it
- Install the VirtualBox USB driver manually
    - Go to `%ProgramFiles%\Oracle\VirtualBox\drivers\USB\filter`
    - Right-click VBoxUSBMon.inf and choose "Install"
    - Reboot your machine
    - Unplug the Nintendo Classic Mini if plugged in.
    - Open VirtualBox and close it again.
    - You should now be able to perform the [USB Forwarding Setup](#usb-forwarding-setup)

### hakchi-gui: cannot connect to X server 192.168.1.1:0

If you get this error message, double-check the IP address that you are supplying to your `docker-compose run` command.
Alternatively, you can try with your computer's hostname:

```bash
docker-compose run -e DISPLAY=$(hostname):0 hakchi
```

If that fails, too, you may be dealing with a networking issue.

## Credits

Based on [hakchi](https://github.com/madmonkey1907/hakchi) by madmonkey1907.

data directory with `fes1.bin` and `uboot.bin` taken from [an outdated Windows release of hacki](https://github.com/madmonkey1907/hakchi/releases/download/v1.0.1/hakchi-gui-win32.zip).