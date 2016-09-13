#Add to first line of the script

For(;;){ 
 

$main = $Null 
$PrintServers = "PrintServer1","PrintServer2","PrintServer3","PrintServer4"
$PrintersUnsorted = ForEach ($PrintServer in $PrintServers){
        get-printer -cn $printServer | where Name -notlike '*ROV*'
        }
$Printers = $PrintersUnsorted | sort PrinterSTatus
$head = (Get-Content c:\install\printerdashboard\head.html) -replace '%4',(get-date).DateTime
$tail = Get-Content c:\install\printerdashboard\tail.html


ForEach ($Printer in $Printers | Where-Object { $_.printerstatus -ne "normal" -and $_.printerstatus -ne "tonerlow"}){

    #increment $i, to use the many different background image options
    $i++

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
    $IPAddress="http://"+$Printer.PortName
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

$html > c:\install\printerdashboard\PTRReport.html

#Last line of script
Start-Sleep -Seconds 90}