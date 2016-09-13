#add to first line of the script for loop
For(;;){ 
 

#clear all variables
$main = $Null 
#define print servers
$PrintServers = "PrintServer1","PrintServer2","PrintServer3","PrintServer4"
#pull printers from all servers
$PrintersUnsorted = ForEach ($PrintServer in $PrintServers){
        #Mobile Printers all contain ROV in the name. Filtering those out to get rid of false positives as they are powered up on demand.
        get-printer -cn $printServer | where Name -notlike '*ROV*'
        }
#$Printers is sorted by print server at this point. Sorting to group by printer name
$Printers = $PrintersUnsorted | sort PrinterStatus
$head = (Get-Content c:\install\printerdashboard\head.html) -replace '%4',(get-date).DateTime
$tail = Get-Content c:\install\printerdashboard\tail.html

#loop through each printer and discard any printers that are normal or tonerlow
ForEach ($Printer in $Printers | Where-Object { $_.printerstatus -ne "normal" -and $_.printerstatus -ne "tonerlow"}){

    #set the name 
    $Name=$Printer.Name

    #choose which style (which affect the color of the card generated)
    if ($Printer.PrinterStatus -eq 'Offline'){
        $style = 'style1'
        }
        elseif($Printer.PrinterStatus -eq 'Normal'){
        $style = "style3"
        }
        elseif($Printer.PrinterStatus -eq 'Error, Offline'){
        $style = "style1"
        }
        else{
        $style = "style5"
        }
    
    #if the Printer is not normal show state
    if ($Printer.State -ne 'Normal'){
     
        $Name="$($Printer.Name)<br>
              $($Printer.Printerstatus)<br>
              $($Printer.ComputerName)"
    }
    #assign variable to create link for tile
    $IPAddress="http://"+$Printer.PortName
    #assign variable to show IP on mouseover of tile
    $IP=$Printer.Portname

    #make a card
    $tile = @"
                                <article class="$style">
									<span class="image">
										<img src="images/pic01.jpg" alt="" />
									</span>
									<a href="$IPADDRESS">
										<h2>$Name</h2>
										<div class="content">
											<p>$($IP)</p>
										</div>
									</a>
								</article>
"@


$main += $tile
}
$html = $head + $main + $tail

#place html report 
$html > c:\install\printerdashboard\PTRReport.html

#last line of script to loop
Start-Sleep -Seconds 90}