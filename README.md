# Virus Found?
Well today I wanted to extend the functionality for this repository, but it turns out that the keypress32.exe was detected as a virus from Windows Defender. Well it says that the keypress32.exe is capable of executing commands from an attacker, but this is very missleading since this is tool that acts as a wrapper for powershell to initiate a systemwide hotkey press. Powershell is with the command sendwait and send sendkey only capable to send a keypress to a application that has focus. I experimented with this and the result was awful. When you are in the game and the script detects a bad follower than the focus had to moved from your game to obs to initiate the trigger. Some games could not be adressed and so the focus stays on obs. Well this is the reason why I compiled the keypress*.exe files with very little knowledge of c++ with the help of stackoverflow.com. I will recreate the keypress*.exe files with a seperate .exe for each F-Key to eliminate the need of having a parameter for a key. Maybe this triggers the "can be used from an attack" detection.

# Whats is this
Some time ago the Bot Hoss00312 started to get on my nerves.
Therefore I created a simple Powershell Script that works with the Twitch Helix API.
Of cause it is Powershell - so it just works with Windows and I do not plan to port this script.

# Videos
- German: https://www.youtube.com/watch?v=tfht5v6GYQc
- English: https://www.youtube.com/watch?v=WbfpptzvEuo

# What it does
Basicly the Script is checking continuesly the latest follower of your channel and if a regular
expression matches to the user then a hotkey will be pressed by the script to hide your notification source in OBS.
After a defined time the hotkey will be pressed again to activate the source again.

# Requirements
- Visual C++ Redistributable for Visual Studio
  - For 32-Bit Operating Systems: https://aka.ms/vs/16/release/vc_redist.x86.exe
  - For 64-Bit Operating Systems: https://aka.ms/vs/16/release/vc_redist.x64.exe
  
# How to run
- You need to have 2 factor/mfa authentication enabled on your Twitch account. (All Affiliate should have this already)
- Place the init.cmd, process.ps1, keypress32.exe and keypress64.exe into the same directory of your choice.
- Start the init.cmd file and follow the assistant
  - Define the F1-12 Key as a Hotkey
  - Enter your channel name
  - Create a new extention with a Name and a defined OAuth Redirect URL
  - Let the script authenticate and get the token
- Next time you run the init.cmd all settings will be loaded automaticly
- Setup your Alertbox with a delay of 5 seconds
  - On Streamlabs you can change this on the website for every alert

# When it failes or start fresh
If something goes wrong you can delete the channel.txt, clientid.txt and token.txt files that will be placed in the same directory as init.cmd and process.ps1.

# Things you should not do
You must not run this as an Administrator because of the path "execute at folder" definition of windows. Programms that will be run as Administrator starts usualy at %winwir%\system32.

# License
You are free to use this code and modify it by your own, but a credit to LetsBash.de must be included.

# Warranty
This script does not come with any warranty and will be provided as it is.

# Is this dangerous?
Nope - Everything regarding processing and authentication will be handeld between your computer and twitch. But you should not store the script on a public folder.
