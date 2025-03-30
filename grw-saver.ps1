# Ghost Recon Wildlands Auto Saver
# Author: Chip Gwyn <chip@fluidgravity.com>
# Rev 1.0
#
# This tool will launch Ghost Recon Wildlands and upon exit copy the saved games folder
# to another folder that is time-date stamped.  This way every time the game is exited
# a backup is made.


## USER VARS #########################################################################################
# Fill out the following vars to suit your installation

# The full path to Ubisoft UPlay
$UPLAY_EXEC = "C:\Program Files (x86)\Ubisoft\Ubisoft Game Launcher\UbisoftConnect.exe"

# This is the location of the Ghost Recon Wildlands executable
$GRW_EXEC = "D:\Program Files\GhostRecon\Tom Clancy's Ghost Recon Wildlands\GRW.exe"
# This is where Ubisoft saves games by default
$UBI_SAVES = "C:\Program Files (x86)\Ubisoft\Ubisoft Game Launcher\savegames"
# This is the folder where game backups will be saved
$MY_SAVES = "C:\Users\chip\OneDrive\Desktop\Wildlands-Saves"
# END USER VARS


## SCRIPT VARS #########################################################################################
# Some defaults

# The amount of hours to consider the last backup as expired.  This is used for making a backup
# before firing up the game, just in case the last time played was not started with this tool or
# ..whatever.   Default here is going to be 72 hours (3 days), adjust, in hours, as you see fit
$EXPIRETIME = 72

# The number of secornds to wait after the game exits, to be sure any open files are fully written to disk
# Generally about 5 seconds is fine here
$WAITTIME = 5


## Function Definition ##################################################################################
function Save-Backup {
    $end_time_dir_name = Get-Date -Format "GRW-Backup-yyyy.MM.dd.HH.mm.ss"
    $new_save_game_dir = Join-Path $MY_SAVES $end_time_dir_name

    # create the directory
    New-Item -ItemType Directory -Path $new_save_game_dir
    Write-Output "new directory created: $new_save_game_dir"

    # copy ubi saves over to new dir
    Copy-Item $UBI_SAVES -Destination $new_save_game_dir -Recurse
    Write-Output "files copied from $UBI_SAVES to $new_save_game_dir"
}


function Get-RecentBackup {
    param ($expiredTimeInHours = 72)

    $recentBackup = Get-ChildItem -Path $MY_SAVES -Filter "GRW-Backup-*" |
                    Sort-Object CreationTime | Select-Object -Last 1

    if ((New-TimeSpan -Start $recentBackup.CreationTime -End $(Get-Date)) -gt
            (New-TimeSpan -Hours $expiredTimeInHours) ) {
        Write-Host "It's been over $expiredTimeInHours since the last backup, creating a new one..."
        Save-Backup
    }

}



#########################################################################################
# Script starts here

# Uplay needs to be running...mostly.  Make sure it is before trying to run the game
try
{
    Get-Process -Name "UplayWebCore" -ErrorAction Stop > $null
} catch {
    Write-Host "Uplay doesn't seem to be running...starting it"
    & $UPLAY_EXEC
    Start-Sleep -Seconds 10
}


# If it's been more the 72 hours (3 days, go head and make a backup before we start)
Get-RecentBackup -expiredTimeInHours $EXPIRETIME

# Start the game
$grw_working_dir = $(Split-Path -Path $GRW_EXEC -Parent)
Write-Output "Starting Ghost Recon Wildlands with auto-saver..."
Set-Location -Path $grw_working_dir
Start-Process -FilePath $GRW_EXEC -WorkingDirectory $grw_working_dir -Wait


# wait time after game exits to let files be fully written
$wait_time = $WAITTIME
Write-Output "pausing for $wait_time seconds to allow ubisoft to finish writing files..."
Start-Sleep -Seconds $wait_time

# Make the backup
Save-Backup

# All done!
Write-Output "done..."
