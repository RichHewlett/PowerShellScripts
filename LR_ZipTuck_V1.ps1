#==========================================================================================================
# Zip up Lightroom catalogue backup folders (deleting old non-zipped version), copy to remote location, 
# retaining some zip files locally. Also housekeeps the server location (maintains X number of zip files). 
# Just run this after exiting Lightroom (or anytime you want to clean up LR backups). If LR is running it 
# will wait for it to close. 
# ---------------------------------------------------------------------------------------------------------
# 02/01/14 : Creation
# 01/09/16 : Superseeded by V2 for Lightroom 6 and upwards (as LR now zips backups by default). This still 
#            works for LR6 but is slow as it re-zips the backups which is not required. 
#==========================================================================================================

# clear screen
clear-host

write-output ""
write-output "------------------------------------Script Start------------------------------------" 
write-output "Lightroom Backup Zip Tuck" 
write-output "------------------------------------------------------------------------------------" 

# load modules used in this script, change path as required
import-module -name C:\scripts\support\SupportModule -verbose

# local folder where LR dumps your backups, and a folder on the network or another drive to duplicate to 
$LocalBkUpFolder = "D:\LightroomBackUp"
$RemoteBkUpFolder = "X:\LightroomBackup\CatalogBkUps"

# you need to hve 7Zip installed and add the path here
$7ZipExePath = "c:\Scripts\Support\7-Zip\7za" 
$7ZipCmdLineForBkUps = $7ZipExePath + " a " 

$target = “lightroom”
$process = Get-Process | Where-Object {$_.ProcessName -eq $target}
if($process) 
{
    Write-Output "Waiting for Lightroom to exit..."
    $process.WaitForExit()
    start-sleep -s 2
}

Write-Output "Zipping backup file(s)..."

## look for folders (unzipped backups)
if ((Get-ChildItem -Path $LocalBkUpFolder -Directory).Count -gt 0)
{    
    ## loop each one and zip
    foreach ($path in (Get-ChildItem -Path $LocalBkUpFolder -Directory))
    {
        ## zip it here
        Write-Output "Zipping $path.Name      "
        $FolderToZip = $path.FullName
        $ZipFileName = $path.Name + ".zip"
        $ZipFileFullPath = $LocalBkUpFolder + "\" + $ZipFileName
                                
        $zipExpression = $7ZipCmdLineForBkUps + """$ZipFileFullPath""" + " " + """$FolderToZip"""
        invoke-expression $zipExpression

        ## copy zip to remote folder location 
        Write-Output "Tucking backup away on remote share..."
        Copy-Item $ZipFileFullPath  -Destination $RemoteBkUpFolder
        
        ## delete folder
        Remove-Item -Recurse -Force $FolderToZip                
    }
}

## cleanup zip files, keep 8 newest
write-output "Clear out old zipped files (local)..." 
Remove-MostFiles $LocalBkUpFolder *.zip 8

## cleanup zip files, keep 20 newest
write-output "Clear out old zipped files (Server)..." 
Remove-MostFiles $RemoteBkUpFolder *.zip 20

Write-Output "Script Complete !!!"
start-sleep -s 3

