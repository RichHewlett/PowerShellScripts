#==========================================================================================================
# Renames Adobe Lightroom catalogue backups with date, flattens folder structure, copy to remote location, 
# retaining some zip files locally. Also housekeeps the server location (maintains X number of zip files). 
# Just run this after exiting Lightroom (or anytime you want to clean up LR backups). If LR is running it 
# will wait for it to close. 
# This is for Lightroom V6 upwards (for older versions use the V1 version of this script)
# ---------------------------------------------------------------------------------------------------------
# 02/01/14 : V1 Creation
# 25/09/16 : V2 Creation. Removed Zip functionality as Lightroom v6 now automatcially compresses backups 
#==========================================================================================================

# clear screen
clear-host

write-output ""
write-output "------------------------------------Script Start------------------------------------" 
write-output "Lightroom Backup Zip Tuck V2" 
write-output "------------------------------------------------------------------------------------" 

# load modules used in this script, change path as required
import-module -name C:\scripts\support\SupportModule -verbose

# local folder where LR dumps your backups, and a folder on the network or another drive to duplicate to 
$LocalBkUpFolder = "D:\LightroomBackUp"
$RemoteBkUpFolder = "X:\LightroomBackup\CatalogBkUps"

## check if Lightroom is running, and if so just wait for it to close
$target = “lightroom”
$process = Get-Process | Where-Object {$_.ProcessName -eq $target}
if($process) 
{
    Write-Output "Waiting for Lightroom to exit..."
    $process.WaitForExit()
    start-sleep -s 2
}

Write-Output "Sorting backup file(s) for processing..."

## look for folders (unzipped backups) in backup location
if ((Get-ChildItem -Path $LocalBkUpFolder -Directory).Count -gt 0)
{    
    ## loop each subfolder in backup location and process
    foreach ($path in (Get-ChildItem -Path $LocalBkUpFolder -Directory))
    {
        ## find zip file in this folder and rename 
        $path | Get-ChildItem | where {$_.extension -eq ".zip"} | Select-Object -first 1 | % { $_.FullName} | Rename-Item -NewName {$path.Name + ".zip"} 
        
        ## move file to parent folder (as dont need subfolders now)
        $SourceFilePath = $path.FullName + "\" + $path.Name + ".zip"       
        Move-Item $SourceFilePath -Destination $LocalBkUpFolder 

        ## copy zip to remote share location 
        Write-Output "Tucking backup away on remote share"
        Copy-Item $NewFileName -Destination $RemoteBkUpFolder
        
        ## delete folder
        Remove-Item -Recurse -Force $path.FullName                
    }
}

## cleanup zip files (local)
write-output "Clear out old zipped files (local)..." 
Remove-MostFiles $LocalBkUpFolder *.zip 8

## cleanup zip files (remote)
write-output "Clear out old zipped files (remote)..." 
Remove-MostFiles $RemoteBkUpFolder *.zip 20

Write-Output "Script Complete !!!"
start-sleep -s 3

