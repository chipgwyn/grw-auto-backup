# Ghost Recon Wildlands Auto Saver
# Author: Chip Gwyn <chip@fluidgravity.com>
# Rev 1.0
#
# This tool will launch Ghost Recon Wildlands and upon exit copy the saved games folder
# to another folder that is time-date stamped.  This way every time the game is exited
# a backup is made.

#
# USER VARS
# Fill out the following vars to suit your installation

# This is the location of the Ghost Recon Wildlands executable
$GRW_EXEC = "D:\Program Files\GhostRecon\Tom Clancy's Ghost Recon Wildlands\GRW.exe"
# This is where Ubisoft saves games by default
$UBI_SAVES = "C:\Program Files (x86)\Ubisoft\Ubisoft Game Launcher\savegames"
# This is the folder where game backups will be saved
$MY_SAVES = "C:\Users\chip\OneDrive\Desktop\Wildlands-Saves"
# END USER VARS


#########################################################################################
# Script starts here
$grw_working_dir = $(Split-Path -Path $GRW_EXEC -Parent)
Write-Output "Starting Ghost Recon Wildlands with auto-saver..."
Set-Location -Path $grw_working_dir
Start-Process -FilePath $GRW_EXEC -WorkingDirectory $grw_working_dir -Wait
#& $GRW_EXEC

# wait time after game exits to let files be fully written
$wait_time = 5
Write-Output "pausing for $wait_time seconds to allow ubisoft to finish writing files..."
Start-Sleep -Seconds $wait_time

# generate a directory name with current time and date
$end_time_dir_name = Get-Date -Format "GRW-Backup-yyyy.MM.dd.HH.mm.ss"
$new_save_game_dir = Join-Path $MY_SAVES $end_time_dir_name

# create the directory
New-Item -ItemType Directory -Path $new_save_game_dir
Write-Output "new directory created: $new_save_game_dir"

# copy ubi saves over to new dir
Copy-Item $UBI_SAVES -Destination $new_save_game_dir -Recurse
Write-Output "files copied from $UBI_SAVES to $new_save_game_dir"

# All done!
Write-Output "done..."

