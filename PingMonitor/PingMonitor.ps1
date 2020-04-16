# Telegram configuration
$global:MyToken = ${{ secrets.MY_TELEGRAM_TOKEN }}
$global:chatID  = ${{ secrets.MY_TELEGRAM_CHAT_ID }}
$global:resendInterval = 2

# What is being monitored
$monitorList = @(
                  ("IP",  "192.168.1.1",   "Ubiquiti USG Router"),
                  ("IP",  "192.168.1.2",   "Ubiquiti UAP-AC-Pro (Upstairs)"),
                  ("IP",  "192.168.1.3",   "Ubiquiti UAP-AC-Pro (Downstairs)"),
                  ("IP",  "192.168.1.4",   "Ubiquiti UAP-AC-M (Front Yard)"),
                  ("IP",  "192.168.1.6",   "Ubiquiti Cloud Key"),
                  ("IP",  "192.168.1.7",   "Ubiquiti USL-24P (Core Switch)"),
                  ("IP",  "192.168.1.8",   "Ubiquiti US-8-150W (Garage Attic)"),
                 #("IP",  "192.168.1.9",   "Ubiquiti US-8-60W (Family Room)"),
                  ("IP",  "192.168.1.112", "Pihole Primary (Dell T30)"),
                  ("IP",  "192.168.4.7",   "UVC G3 Micro 1 (Nursery)"),
                 #("IP",  "192.168.4.8",   "UVC G3 Flex 1 (Family Room)"),
                  ("IP",  "192.168.4.9",   "UVC G3 Flex 2 (Kitchen)"),
                  ("IP",  "192.168.4.10",  "UVC G3 Pro 1 (Garage Inside)"),
                  ("IP",  "192.168.4.12",  "Dahua Turret 1 (Garage Center)"),
                  ("IP",  "192.168.4.13",  "Dahua PTZ 1 (Garage Right)"),
                  ("IP",  "192.168.4.14",  "Dahua Twin 1 (Garage Left)"),
                  ("IP",  "192.168.4.15",  "Dahua PTZ 2 (Garage Left)"),
                  ("IP",  "192.168.4.16",  "Dahua Turret 2 (TBD Location)"),
                  ("SVC", "defragsvc",      "Blue Iris Service")
                )

# How often is it being monitored (seconds)
$setInterval = 5

# If it fails on try #1, how long to wait until try #2 (seconds)
$recheckInterval = 10

# Do you want this to repeat (1=yes 0=no)
$repeat = 1

#################################################
# SendTelegramMessage function
Function SendTelegramMessage($Message){
    try   { Invoke-RestMethod -Uri "https://api.telegram.org/bot$($MyToken)/sendMessage?chat_id=$($chatID)&text=$($Message)" | Out-Null} 
	catch { 
			Start-Sleep -Seconds $resendInterval
            try   { Invoke-RestMethod -Uri "https://api.telegram.org/bot$($MyToken)/sendMessage?chat_id=$($chatID)&text=$($Message)" | Out-Null}
            catch { "Well that's a failure..." }
          }
}

#################################################
# PingMonitor body
while(1){
    foreach($monitoring in $monitorList){
        $thisType = $monitoring[0]
        $thisID   = $monitoring[1]
        $thisName = $monitoring[2]

        # subroutine if ip
        if($thisType -eq "IP"){
            if(!(Test-Connection -ComputerName $thisID -BufferSize 16 -Count 1 -ea 0 -quiet)){
            Start-Sleep -Seconds $recheckInterval
                if(!(Test-Connection -ComputerName $thisID -BufferSize 16 -Count 1 -ea 0 -quiet)){
                    $now = Get-Date -Format "M/d/yy HH:mm:ss"
                    $Message = "At $($now): Ping error on $($thisID) [$($thisName)]"
                   #Write-Output $Message
					SendTelegramMessage($Message)
                }
            }
        }

        # subroutine if service
        elseif($thisType -eq "SVC" ){
            if((Get-Service $thisID).Status -eq "Stopped"){
                $now = Get-Date -Format "M/d/yy HH:mm:ss"
                $Message = "At $($now): Service stopped $($thisID) [$($thisName)]"
			    #Write-Output $Message
                SendTelegramMessage($Message)
			}
        }
    }
	
    # stop running if this is set to not repeat
    if(!$repeat){break}

    # pause before restarting
    Start-Sleep -Seconds $setInterval
}
#################################################
