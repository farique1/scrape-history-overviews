
# Scrape History Overviews

## What it is.

**Scrape History Overviews** scans Gaming History’s `History.dat` to collect game information and export them in the **Attract Mode** overview format. **SHO** is compatible with revision 1.97 of `History.dat` but seems to work up to rev 1.99. `History.dat` has changed format in the past and will likely change again in the future, in that case, **SHO** might not work anymore.  


## How to use.

>**SHO** need to be on the same folder as its `Data` subfolder.  

From top to bottom on the main interface:  

- *History File button:*  
Pick the `History.dat` file to use. If the file is on **SHO** root folder, it will be automatically selected.  

- *`History.dat` location box.*  
The location of the History.dat file.  

- *Roms List button:*  
Pick a list of roms for **SHO** to look for, especially useful when looking for arcade games (**mame**) as they have a lot of unused or unwanted roms. The list format is just a text files with a rom name on each line. A sample is bundled with **SHO** called `RomsList.txt`. If this file exists, it will be automatically selected.  

- *Roms List location box:*  
The location of the roms list file.  

- *Clear rom list button:*  
Clear the rom list box.  

- *Dump Folder button:*  
Pick a folder to dump the created overviews `.cfg` files.   

- *Dump Folder input box:*  
The location of the overviews dump folder.  

- *Systems box:*  
A pull-down list to choose the system to look for.  By default, it has all the systems available in the rev 1.97 of `History.dat`. It will search for all games on the selected system regardless of specific media tokens like “_cass” or “_cart” (if a rom list is selected, the games will be limited to that list). This list can be modified by editing `Systems.dat` on the `Data` subfolder. It has one system in each line with the following format:  

  - *Name|Token*  
    Where the Name is the system name and the Token is the `History.dat` token for the corresponding system. The token must start with “$” and have no media part like “_flop”.  

- *Get from `History.dat` button*  
With new versions of the `History.dat`, more system may be added, this button will scavenger the file looking for all the system it can find. This way, a new systems list can be automatically created, as long as the `History.dat` remains compatible.  
When it finishes looking for the systems, it will save a `SystemsList.txt` file on the `Data` subfolder and ask to open it. To make it the new default system list just save it as `Systems.dat` or rename it afterwards. (**SHO** must be reopened for the new list to take effect)  
The search can be interrupted by pressing CTRL-Q.

- *Use rom name check box*  
When checked, **SHO** will save the overviews files with the rom names on the rom list (if there is one) instead of the game names it finds on `History.dat`.  

- *Add “\n” check box*  
On some layouts (mines), **Attract Mode** do not show the first line of the overview if it is longer than the box it is in, by adding an “\n” (a line feed) at the very start of the text (right after “overview “) this can be fixed.  

- *Analysis only check box:*  
Perform the search, show the information and build the log but do not save the overview files.  

- *Go button:*  
Perform the actual search for the overview info.  
**SHO** will go through the `History.dat` file looking for games under the selected system token, get its information and save it as an **AM** overview file on the selected Dump Folder.
It will look for all the games it finds unless the “Use rom name” has been checked, in that case it will only look for the game with rom names contained on the roms list.  
The overview file will be saved with the name found on the copyright line unless the “Use rom name” has been checked, in that case the name on the list will be used.  
A log file with the name `SHO.log` will be saved at the end.  
If there is not enough information, **SHO** will not save the overview file. The game will be logged with “No info”  
If there is a “(name)” line right after the main game name it is usually because the original name is in Japanese or the like. In this case, **SHO** will opt to get the Arabic name. This will be logged as “Alt name”  
If the game name contains a forbidden system character, it will be replaced by an “-“ so the file can be safely saved. This will be logged as “Illegal char changed to "-"” (the log will be made even if the rom list name is being used, the rom name. however, will not be affected)  
The log file contains information about all the games it finds (respecting the constrains of a rom list) including the start, ending and amount of lines the information found at `Histori.dat` has. It will also have some general statistics. A new search will replace an older log.  
The search can be interrupted by pressing CTRL-Q.  

- *Help*  
Shows this.  

## Acknowledgements

Enjoy and send feedback.  
Thanks.  

***SHO** is offered as is with no guaranties whatsoever. We (I) will not be responsible for any harm it decides to do to your romlists, assets, Attract Mode, operating system, computer or life. I think, though, it will behave (mostly)*  

