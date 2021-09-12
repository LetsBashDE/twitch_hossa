# Whats This
Some time ago the Bot Hoss00312 started to get on my nerves.
Therefore I created a simple Powershell Script that works with the Twitch Helix API.
Of cause it is Powershell - so it just works with Windows and I do not plan to port this script.

# What it does
Basicly the Script is checking continuesly the latest follower of your channel and if a regular
expression matches to the user then a hotkey will be pressed by the script to hide your notification source in OBS.
After a defined time the hotkey will be pressed again to activate the source again.

# How it runs...
- You need to have 2 Factor authentication enabled on your Twitch account. (All Affiliate should have this)
- Place the init.cmd and process.ps1 into the same directory of your choice.
- Open the process.ps1 in an editor of your choice
  - Replace 'F9' in the line '$hotkey = "{F9}"' with a Hotkey of your choice (you can also leave 'F9' if you are fine with it)
  - Replace '30' in the line '$release = 30' with the amount of seconds until the hotkey should be pressed again to enable your Alertbox.
  - Replace 'yourchannelname' in the line '$channel = "yourchannelname"' with the name of your twitch channel (please use lower case)
  - Modify '8082' in the line '$webserverport = "8082"' if an application uses the Network TCP Port 8082  on your computer (if you are not sure leave it)
  - Modify '2' in the line '$interval = 2' if you want to audjust the update time in seconds of your followers ('2' means that you followers will be checked every 2 seconds)
  - Modify the array in the line '$pattern = @("^hos(s|t).*",".*0312.*")' to add other or more regular expressions. Shoud a expression matches to a follower then the hotkeys will be pressed.
- Start the init.cmd and follow the "instructions"
  - When you first run the init.cmd you will be redirected to dev.twitch.tv with your default browser
    - You have to create a new extention
    - Provide a name to the extention
    - Go to advanced settings and provide a OAuth Redirect URL: http://127.0.0.1:8082
      - If you defined in process.ps1 on line '$webserverport = "8082"' nother port than 8082 you must change the URL to the port (eg. for 8083 http://127.0.0.1:8083)
    - Save the extention
    - Look of for the 'Twitch-API-Client-ID' in your newly created extention and provide the ID to the powershell console
  - Next you will be redirected to the twitch oauth page to gain access to your latest followers
    - In the background a second website opens: This is a failsave to close the local webserver that is running on your defined TCP Port (eg. 8082)
    - Therefore: You have 60 seconds to accept the twitch oauth page to retrive the token and gain access to your follower list
- Next time you run the init.cmd all settings will be loaded automaticly
- Setup your Alertbox with a delay of 5 seconds
  - On Streamlabs you can change this on the website for every alert

# When it failes
If something goes wrong you can delete the channel.txt, clientid.txt and token.txt files that will be placed in the same directory as init.cmd and process.ps1.

# License
You are free to use this code and modify it by your own, but I would love to see a credit on it.

# Warranty
This script does not come with any warranty and will be provided as it is.
