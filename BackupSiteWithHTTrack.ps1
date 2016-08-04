#==========================================================================================
# Backup a site or blog to disk using HTTRACK tool 
# (Created by Rich Hewlett, see blog at RichHewlett.com) 
# (Post is https://richhewlett.com/2014/05/20/backing-up-your-blog-content-using-httrack/)
#  write-eventlog command assumes you have a log named "Network" with a source of HTTrack
#=========================================================================================
clear-host
write-output "---------------------Script Start--------------------&quot;
write-output " HTTrack Site Backup Script"
write-output "-------------------------------------------------------"
 
# set file paths
$timestamp = Get-Date -format yyyy_MMM_dd_HHmmss
$TargetFolderPath="F:\MyBlogBackUp\$timestamp"
$HTTrackPath="C:\HTTrack\httrack.exe"
 
write-output "Backup target path is $TargetFolderPath"
write-output "HTTrack is at $HTTrackPath"
 
# set error action preference so errors don't stop and the trycatch 
# kicks in to handle gracefully
$erroractionpreference = "Continue"
 
try
{
    write-output "Creating output folder $TargetFolderPath ..."
    New-Item $TargetFolderPath -type directory
     
    write-output "Download data ..."
    invoke-expression "$HTTrackPath http://MyBlog.com -O $TargetFolderPath"
    write-output "Done with downloading."    
     
    write-eventlog -LogName "Network" -Source "HTTrack" -EventId 1 -Message "Downloaded blog for backup"
     
}
catch
{
    # error occurred so lets report it
    write-output "ERROR OCCURRED DURING SCRIPT " $error
 
    # write an event to the event log
    write-output "Writing FAIL to EventLog"
    write-eventlog -LogName "Network" -Source "HTTrack" -EventId 1 -Message "Download blog for backup FAILED during execution. $error" -EntryType Error
}
 
write-output "------------------------------------Script end------------------------------------"

