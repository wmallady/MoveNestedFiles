# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Authors: Fox Mallady
# Date Created: 1/10/22
# Prerequesites: None
# Description: Moves files from nested network folder path to another folder. Useful for integrations. 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


$fetchFolder = '\\some\folder\to\fetch'

#processing folder - temporary destination until it moves to Abbyy folder - static location

$desFolder = '\\some\folder\to\dropoff'

$logFolder = '\\some\log\folder'

# destination of network abbyy folder - static location

$whoRan = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$nestedItems = foreach($item in $fetchFolder){Get-ChildItem -Path (Get-ChildItem -Path (Get-ChildItem -Path $item))}
#Grab child items from nested folder


#######################################################
                    # Logging stuff #

$dateDay = Get-Date -Uformat "%d"
# grabs only the day from date 
$logFile = '\\some\log\folder\LogDate' + $dateDay + '.txt'
# Path to Log File

$CurrentDate = Get-Date
$DatetoDelete = $CurrentDate.AddDays(-27)
#delete files after 27. Must be 27 to not cause issues in February. 

Get-ChildItem $logFolder -Recurse  | Where-Object { $_.LastWriteTime -lt $DatetoDelete } | Remove-Item -force -recurse
#old log files 

########################################################


foreach($item in $nestedItems){
   
    $random = Get-Random -Minimum 1 -Maximum 100000
    $newName = $item.BaseName + "_" + $random + $item.Extension
    #generate random file name with while maintaining extension 
    #must be in the loop of else we cannot move the renamed item 
  
    Rename-Item -Path $item -NewName $newName 
    Move-Item $newName -Destination $desFolder -Include '*.txt', '*.pdf' 
    # move all pdfs and txts. Can replace with any file extension 
    
    Write-Output "$whoRan MOVING $item TO $desFolder AT ***$CurrentDate***" >> $logFile
}

Get-ChildItem -Path $fetchFolder -Include *.* -File -Recurse | ForEach-Object { $_.Delete()}
#cleans up any remaining files not of the specified file type. Optional. 
