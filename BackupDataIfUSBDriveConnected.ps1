#==========================================================================================================
# Checks for presence of offsite backup USB drive by filepath, then backs up relevant data to drive if 
# present, exits gracefully if not present. Schedule script to run everynight and it only backs up data 
# when USB external drive has been inserted and turned on. 
# (Created by Rich Hewlett, see blog at RichHewlett.com) 
# (Post is https://richhewlett.com/2014/02/28/how-to-backup-to-usb-drive-only-if-its-connected/)
# Uses Robocopy for copy actons but any copy tool can be used. 
# Uses DevCon USB connection tool to cleanly disconnect USB drive (see blog post for more info) 
#==========================================================================================================
clear-host

write-output "---------------------Script Start--------------------"
write-output " Running Backup Script"
write-output "-------------------------------------------------------"
 
 
# set file paths and log file names 
$timestamp = Get-Date -format yyyyMMdd_HHmmss
$LogBasePath="C:\Logs\USBBackup"
$LogFile="$LogBasePath\USBBkUp_$timestamp.txt"
$USBDriveLetter="U"
$USBDriveBackupPath="U:\Backup"
 
# set error action preference so errors don't stop and the trycatch kicks in to handle gracefully
$erroractionpreference = "Continue"
 
try
{
    # Check USB drive is on by verfiying the path
    if(Test-Path $USBDriveBackupPath)
    {   
        # now copy the data folders to backup drive
        invoke-expression "Robocopy C:\Docs $USBDriveBackupPath\Docs /MIR /LOG:$LogFile /NP"
        invoke-expression "Robocopy C:\Stuff $USBDriveBackupPath\Stuff /MIR /LOG+:$LogFile /NP"
         
        # Copy the log file too
        invoke-expression "Robocopy $LogBasePath $USBDriveBackupPath\Logs /MIR /NP"
                     
        # Sleep for 60 to ensure all transactions complete, then disconnect USB drive       
        Start-Sleep -Seconds 60
        Invoke-Expression "c:\DevCon\USB_Disk_Eject /removeletter $USBDriveLetter"       
    }
}
catch
{
    # Catch the error, log it somewhere, but make sure you still eject the drive using below
    Start-Sleep -Seconds 60
    Invoke-Expression "c:\DevCon\USB_Disk_Eject /removeletter $USBDriveLetter"
}

write-output "------------------------------------Script end------------------------------------"

