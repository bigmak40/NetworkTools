# Telegram configuration
$MyToken = "xxx"
$chatID = yyy

# What is being monitored
$monitorList = @(
                  ("192.168.1.1",   "Ubiquiti USG Router"),
                  ("192.168.1.2",   "Ubiquiti UAP-AC-Pro (Upstairs)"),
                  ("192.168.1.3",   "Ubiquiti UAP-AC-Pro (Downstairs)"),
                  ("192.168.1.4",   "Ubiquiti UAP-AC-M (Front Yard)"),
                  ("192.168.1.6",   "Ubiquiti Cloud Key"),
                  ("192.168.1.7",   "Ubiquiti USL-24P (Core Switch)"),
                  ("192.168.1.8",   "Ubiquiti US-8-150W (Garage Attic)"),
                 #("192.168.1.9",   "Ubiquiti US-8-60W (Family Room)"),
                  ("192.168.1.112", "Pihole Primary (Dell T30)"),
                  ("192.168.4.7",   "UVC G3 Micro 1 (Nursery)"),
                 #("192.168.4.8",   "UVC G3 Flex 1 (Family Room)"),
                  ("192.168.4.9",   "UVC G3 Flex 2 (Kitchen)"),
                  ("192.168.4.10",  "UVC G3 Pro 1 (Garage Inside)"),
                  ("192.168.4.12",  "Dahua Turret 1 (Garage Center)"),
                  ("192.168.4.13",  "Dahua PTZ 1 (Garage Right)"),
                  ("192.168.4.14",  "Dahua Twin 1 (Garage Left)"),
                  ("192.168.4.15",  "Dahua PTZ 2 (Garage Left)"),
                  ("192.168.4.16",  "Dahua Turret 2 (TBD Location)")
                )

# How often is it being monitored (seconds)
$setInterval = 60

# If it fails on try #1, how long to wait until try #2
$recheckInterval = 10

# Do you want this to repeat (1=yes 0=no)
$repeat = 1

# PingMonitor
do{
    foreach($monitoring in $monitorList){
        $thisIP   = $monitoring[0]
        $thisName = $monitoring[1]
        if(!(Test-Connection -ComputerName $thisIP -BufferSize 16 -Count 1 -ea 0 -quiet)){
            Start-Sleep -Seconds $recheckInterval
            if(!(Test-Connection -ComputerName $thisIP -BufferSize 16 -Count 1 -ea 0 -quiet)){
                $now = Get-Date -Format "M/d/yy hh:mm:ss"
                $Message = "At $($now): Ping error on $($thisIP) [$($thisName)]"
                Invoke-RestMethod -Uri "https://api.telegram.org/bot$($MyToken)/sendMessage?chat_id=$($chatID)&text=$($Message)"
            }
        }
    }
    Start-Sleep -Seconds $setInterval
}
while($repeat)
