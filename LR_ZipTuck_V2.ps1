#==========================================================================================================
# Zip up Lightroom catalogue backup folders, copy to Server and delete, retaining some zip files locally
# Also housekeeps the server location (maintains X number of zip files) 
# Author: RichHewlett.com
# ---------------------------------------------------------------------------------------------------------
# 02/01/14 : Creation
# 25/09/16 : V2 version removes Zip functionality as LR v6 no auto zips backups 
#==========================================================================================================

# clear screen
clear-host

write-output ""
write-output "------------------------------------Script Start------------------------------------" 
write-output "Lightroom Backup Zip Tuck V2" 
write-output "------------------------------------------------------------------------------------" 

# load modules used in this script
import-module -name C:\scripts\support\SupportModule -verbose

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

Write-Output "Sorting backup file(s)..."

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

        ## copy zip to P:\ server location 
        Write-Output "Tucking backup away on remote share"
        $NewFileName = $LocalBkUpFolder + "\" + $path.Name + ".zip"
        Copy-Item $NewFileName -Destination $RemoteBkUpFolder
        
        ## delete folder
        Remove-Item -Recurse -Force $path.FullName                
    }
}

## cleanup zip files
write-output "Clear out old zipped files (local)..." 
Remove-MostFiles $LocalBkUpFolder *.zip 8

## cleanup zip files
write-output "Clear out old zipped files (Server)..." 
Remove-MostFiles $RemoteBkUpFolder *.zip 20

Write-Output "Script Complete !!!"
start-sleep -s 3

