# okstorage
A useful program for interfacing with large storage systems.

**THIS PROGRAM IS DESIGNED TO WORK WITH `CC: TWEAKED 1.114.2+`!**<br/>
It may work in older versions, but most likely not.

![screenshot](images/screenshot.png)

## Downloading
This program can be downloaded by running this command: <br/>
`wget https://raw.githubusercontent.com/HappySunChild/okstorage/main/build/compiled.lua storagesystem.lua`

## Requirements
1. Monitors (Advanced preferably)
2. Computer (Advanced preferably)
3. IO inventory
4. Wired modems + cables
5. an internet connection (to download it)

## Setup
Setting up the storage system is relatively easy and cheap, as all you need to get started is some monitors, cables, wired modems and a couple inventories to connect to the system with those wired modems.

**All inventories must be connected via Wired Modems and be on the same network!!! Including the IO inventory!!**

![ioinventory](images/io.png)
![backside](images/backside.png)

## Configuring
This program doesn't currently have much configuration within itself, but it does expose all of it's settings inside the `.settings` file, which means you can directly modify them via the `set` program.

### Settings
- `storage.io_inventory` - The IO inventory the system is using. (This isn't used if the program is ran on a turtle)
- `storage.system_inventories` - All of the inventories the system is currently tracking.
- `storage.monitor_columns` - The number of columns the monitors uses to display items.
- `storage.processors` - A dictionary of all processor inventories inside the system, as well as their assigned patterns.

Currently to add inventories to your system you have to set `storage.system_inventories` to `nil` and then reselect all of the inventories on program startup. This will be changed later, but for now it's intentional.

## Auto Crafting
With the latest update this program is now capable of primitive autocrafting! Currently there is no documentation on how to use it, so if you want to learn how to make your own patterns take a look at the example program. (A program to make editing these patterns easier is planned)

## Contributing
Contributions are always welcome! Feel free to open issues or pull requests to suggest features/code.