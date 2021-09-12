#
# Hossa by LetsBash.de
# 13.09.2021
# --------------------
# Function: Makes Hoss00312 Follower silent by hotkey
# Works best with OBS & Streamlabs
# 


# User vars - Can be edited by YOU
$release       = 40                          # Seconds to press the hotkey again
$webserverport = "8085"                      # Local port for temporarly webserver (must match with OAuth Redirect URL - eg. http://127.0.0.1:8084)
$webserverwait = 120                         # Seconds; How long should the webserver listen for an oauth request
$interval      = 2                           # Time between requests to twitch for checking the lastest follower
$pattern       = @()                         # Do not modify
$pattern      += ".*(h|H)(o|O)(s|S)(s|S).*"  # Regular expression of a bad follower
$pattern      += ".*0312.*"                  # Regular expression of a bad follower


# Runtime vars - Modified by the process - Should you NOT edit
$hotkey       = ""                           # Hotkey for OBS
$clientid     = ""                           # Your extention client id
$channel      = ""                           # Name of your channel
$token        = ""                           # Your current authentication token or secret
$basedir      = ($PSScriptRoot + "\")        # Current path of your script
$channelid    = ""                           # Your channelid extracted by your provided channel- oder username
$latestfollow = ""                           # Your lastest follower on twitch
$matchfollow  = ""                           # Compare value for change detection


# Load Assemblys once
Add-Type -AssemblyName System.Windows.Forms

function init_main {
    show_welcome
    init_hotkey
    init_channel
    init_clientid
    init_token
    init_channelid
    init_testing
    
    # Enter processing state
    write-host ""
    write-host ""
    write-host "Start looking for followers..."
    write-host ""
    
    while($true) {
    
    	# Show progress
    	write-host "." -nonewline
	
	# Check latest follower
        init_follower
        init_detector
	
	# Let the CPU rest
        sleep($Global:interval)
    }
}

function show_welcome {
    
    # Just show a simple header
    cls
    write-host ""
    write-host "Bashys Hossa script (by LetsBash.de)"
    write-host "------------------------------------"
    write-host ""
    write-host "How it works:"
    write-host ("This script connects continuously to your twitch account and retrive the lastest follower. If you latest follower is somehow named hoss then a hotkey keypress will be issued to hide your alertbox overlay in OBS Studio. After a delay the hotkey will be pressed again to show the alertbox as usual.")
    write-host ""
}

function init_testing {

    # Testing hotkeys by pressing 6 times
    write-host ""
    write-host ("Testing Hotkey...")
    [System.Windows.Forms.SendKeys]::SendWait(("{F"+$Global:hotkey+"}"))
    write-host ("        pressed 1 times")
    sleep(1)
    [System.Windows.Forms.SendKeys]::SendWait(("{F"+$Global:hotkey+"}"))
    write-host ("        pressed 2 times")
    sleep(1)
    [System.Windows.Forms.SendKeys]::SendWait(("{F"+$Global:hotkey+"}"))
    write-host ("        pressed 3 times")
    sleep(1)
    [System.Windows.Forms.SendKeys]::SendWait(("{F"+$Global:hotkey+"}"))
    write-host ("        pressed 4 times")
    sleep(1)
    [System.Windows.Forms.SendKeys]::SendWait(("{F"+$Global:hotkey+"}"))
    write-host ("        pressed 5 times")
    sleep(1)
    [System.Windows.Forms.SendKeys]::SendWait(("{F"+$Global:hotkey+"}"))
    write-host ("        pressed 6 times")
    write-host ("Testing Hotkey done")
}

function init_hotkey {
    # Create filepath string for channel
    $path = ($Global:basedir + "hotkey.txt")

    # Read filepath string if pressent
    if(test-path -path $path){
        $Global:hotkey = get-content -path $path
    }
    
    # Request hotkey until value is not empty
    while(($Global:hotkey).Length -eq 0) {
        $Global:hotkey = Read-Host -Prompt "What 'F' Key shoud be used as your hotkey (9 for F9)"

        # Throw error if still empty
        if(($Global:hotkey).Length -eq 0){
            write-host "Warning: Hotkey is empty!"
            write-host "         Please try again..."
        }

        # Add space to next output
        write-host ""
    }

    # Save to disk
    $Global:hotkey | Out-File -FilePath $path -NoNewline
}

function init_channel{

    # Create filepath string for channel
    $path = ($Global:basedir + "channel.txt")

    # Read filepath string if pressent
    if(test-path -path $path){
        $Global:channel = get-content -path $path
    }

    # Request clientid until value is not empty
    while(($Global:channel).Length -eq 0) {
        $Global:channel = Read-Host -Prompt "What is your Twitch channel name (eg. LetsBashDE)"

        # Throw error if still empty
        if(($Global:channel).Length -eq 0){
            write-host "Warning: Channel is empty!"
            write-host "         Please try again..."
        }

        # Add space to next output
        write-host ""
    }

    # Save to disk
    $Global:channel | Out-File -FilePath $path -NoNewline
}

function init_clientid {

    # Create filepath string for clientid
    $path = ($Global:basedir + "clientid.txt")

    # Read filepath string if pressent
    if(test-path -path $path){
        $Global:clientid = get-content -path $path
    }

    # Request clientid until value is not empty
    while(($Global:clientid).Length -eq 0) {

        # Open default browser and redirect client to twitch dev page and request client id for input
        start-process "https://dev.twitch.tv/console"
        write-host ("Please create a new extention with the OAuth Redirect URL 'http://127.0.0.1:"+$Global:webserverport+"'")
        $Global:clientid = Read-Host -Prompt "Client ID of the new Extention"

        # Throw error if still empty
        if(($Global:clientid).Length -eq 0){
            write-host "Warning: Client-ID is empty!"
            write-host "         Please try again..."
        }

        # Add space to next output
        write-host ""
    }

    # Save to disk
    $Global:clientid | Out-File -FilePath $path -NoNewline
}

function init_token {
    
    # Create filepath string for clientid
    $path = ($Global:basedir + "token.txt")

    # Load token if exist
    if(test-path -path $path){
        $Global:token = get-content -path $path
        return 
    }

    # Prepare Webserver for callback authentication
    $http = [System.Net.HttpListener]::new() 
    $http.Prefixes.Add(("http://127.0.0.1:"+$Global:webserverport+"/"))
    $http.Start()

    # Trigger emergency webserver close first
    start-process ("http://127.0.0.1:"+$Global:webserverport+"/emergency/")

    # Start Oauth request to twitch
    start-process ("https://id.twitch.tv/oauth2/authorize?client_id="+$Global:clientid+"&response_type=token&redirect_uri=http://127.0.0.1:"+$Global:webserverport+"&scope=user:read:follows")

    # Wait for incomming transmissions
    while ($http.IsListening) {

        # Retrive Request from Webserver
        $context = $http.GetContext()

        # Request one: First time response from twitch
        if ($context.Request.HttpMethod -eq 'GET' -and $context.Request.RawUrl -eq '/') {
            echo "Webserver: Catch Twitch token"
            [string]$html = ("<script>var z = (((window.location.href).split('access_token='))[1].split('&scope'))[0]; window.location.replace(('http://127.0.0.1:"+$Global:webserverport+"/x/'+z))</script>")
            $buffer = [System.Text.Encoding]::UTF8.GetBytes($html)
            $context.Response.ContentLength64 = $buffer.Length
            $context.Response.OutputStream.Write($buffer, 0, $buffer.Length)
            $context.Response.OutputStream.Close()
        }

        # Request two: Javascript corrected response
        if ($context.Request.HttpMethod -eq 'GET' -and $context.Request.RawUrl -like '/x/*') {
            echo "Webserver: Storing Twitch token"
            [string]$html = "<html><body><center><br><br><br><br><h1><font face='arial'>Bashys Twitch Authentication Helper</font></h1><h2><font face='arial'>Powerd by <a href='https://letsbash.de' target='_blank'>LetsBash.de</a></font></h2><h3><font face='arial'>You can close this window now</font></h3></center></body></html>"
            $buffer = [System.Text.Encoding]::UTF8.GetBytes($html)
            $context.Response.ContentLength64 = $buffer.Length
            $context.Response.OutputStream.Write($buffer, 0, $buffer.Length)
            $context.Response.OutputStream.Close()

            # Stop Webserver
            sleep(2)
            $http.stop()
            
            # Store token
            $url = ($context.Request.RawUrl)
            $Global:token = ($url -split "[\/]x[\/]")[1]
            $Global:token | Out-File -FilePath $path -NoNewline
        }

        # Prepare emergengy stop with delay
        if ($context.Request.HttpMethod -eq 'GET' -and $context.Request.RawUrl -like '/emergency/') {
            echo "Webserver: Emergency shutdown timer [Enabled]"
            [string]$html = ("<html><head><meta http-equiv=`"refresh`" content=`""+$webserverwait+"; URL='http://127.0.0.1:"+$Global:webserverport+"/close/'`"></head><body><center><h1><a href='http://127.0.0.1:"+$Global:webserverport+"/close/'>Emergency Webserver Shutdown</a></h1></center></body><html>")
            $buffer = [System.Text.Encoding]::UTF8.GetBytes($html)
            $context.Response.ContentLength64 = $buffer.Length
            $context.Response.OutputStream.Write($buffer, 0, $buffer.Length)
            $context.Response.OutputStream.Close()
        }

        # Site for emergengy listener stop
        if ($context.Request.HttpMethod -eq 'GET' -and $context.Request.RawUrl -like '/close/') {
            echo "Webserver: Emergency shutdown [Completed]"
            [string]$html = ("<html><body><h1>Notice</h1><h2>Local Webserver has been shutdown</h2></body></html>")
            $buffer = [System.Text.Encoding]::UTF8.GetBytes($html)
            $context.Response.ContentLength64 = $buffer.Length
            $context.Response.OutputStream.Write($buffer, 0, $buffer.Length)
            $context.Response.OutputStream.Close()

            # Stop Webserver
            sleep(2)
            $http.stop()
        }
    }
}


function init_destroy_token {

    del ($Global:basedir + "token.txt")
    write-host "Error: Token seams to be invalid. Please restart application and refresh token."

}

function init_destroy_channel {

    del ($Global:basedir + "channel.txt")
    del ($Global:basedir + "clientid.txt")
    write-host "Error: Channel seams to be invalid. Please restart application and reenter your channelname."

}

function init_kill {

    write-host "Error: Could not retrive latest follower."
    sleep(5)
    exit

}


function init_channelid {
    $url = ("https://api.twitch.tv/helix/users?login="+$Global:channel)
	$webquery = New-Object -ComObject "Msxml2.ServerXMLHTTP.6.0"
    $webquery.SetOption(2, 'objHTTP.GetOption(2) - SXH_SERVER_CERT_IGNORE_ALL_SERVER_ERRORS')
    $webquery.open('GET', $url, $false)
    $webquery.setRequestHeader("Authorization", ("Bearer "+$Global:token))
    $webquery.setRequestHeader("Client-Id", $Global:clientid)
	$webquery.SetRequestHeader("Pragma", "no-cache")
	$webquery.SetRequestHeader("Cache-Control", "no-cache")
	$webquery.SetRequestHeader("If-Modified-Since", "Sat, 1 Jan 2000 00:00:00 GMT")
    [long]$timeout = 2000
    $webquery.SetTimeouts($timeout,$timeout,$timeout,$timeout)
    $webquery.send()
    
    if($webquery.statusText -like "*OK*"){
        if($webquery.responseText -like ("*"+'"id":"'+"*")){
            $Global:channelid = (((($webquery.responseText) -split "id`":`"")[1]) -split "`"")[0]
        }
    }

    if(($Global:channelid).Length -eq 0) {
        init_destroy_token
        init_destroy_channel
        init_kill
    }
}

function init_follower {
    $url = ("https://api.twitch.tv/helix/users/follows?to_id="+$Global:channelid)
	$webquery = New-Object -ComObject "Msxml2.ServerXMLHTTP.6.0"
    $webquery.SetOption(2, 'objHTTP.GetOption(2) - SXH_SERVER_CERT_IGNORE_ALL_SERVER_ERRORS')
    $webquery.open('GET', $url, $false)
    $webquery.setRequestHeader("Authorization", ("Bearer "+$Global:token))
    $webquery.setRequestHeader("Client-Id", $Global:clientid)
	$webquery.SetRequestHeader("Pragma", "no-cache")
	$webquery.SetRequestHeader("Cache-Control", "no-cache")
	$webquery.SetRequestHeader("If-Modified-Since", "Sat, 1 Jan 2000 00:00:00 GMT")
    [long]$timeout = 2000
    $webquery.SetTimeouts($timeout,$timeout,$timeout,$timeout)
    $webquery.send()
    
    if($webquery.statusText -like "*OK*"){
        if($webquery.responseText -like ("*"+'"from_name":"'+"*")){
            $Global:latestfollow = (((($webquery.responseText) -split "from_name`":`"")[1]) -split "`"")[0]
        }
    }

    if(($Global:latestfollow).Length -eq 0) {
        init_kill
    }

    if(($Global:matchfollow).Length -eq 0) {
         $Global:matchfollow = $Global:latestfollow
    }

}

function init_detector {
    
    # Check if a new follower appers
    if($Global:matchfollow -eq $Global:latestfollow){
        return
    }
    
    # Show information if change has been detected
    write-host ""
    write-host ("Latest follower changed: "+$Global:latestfollow)

    # Remember the new follower on next matchmaking
    $Global:matchfollow = $Global:latestfollow

    foreach($expression in $Global:pattern){

	# Commence action if bad guy has been detected
        if(($Global:latestfollow) -match $expression) {
            write-host ("Follower "+$Global:latestfollow+" looks like a bad guy!") -ForegroundColor Yellow
	    [System.Windows.Forms.SendKeys]::SendWait(("{F"+$Global:hotkey+"}"))
            write-host ("Action: Hotkey "+$Global:hotkey+" pressed") -ForegroundColor Cyan
	    write-host ("Wait "+$Global:release+" seconds for release") -ForegroundColor Cyan
            sleep($Global:release)
            [System.Windows.Forms.SendKeys]::SendWait(("{F"+$Global:hotkey+"}"))
            write-host ("Action: Hotkey "+$Global:hotkey+" pressed") -ForegroundColor Cyan
        }

    }
    
    write-host ""

}

init_main
