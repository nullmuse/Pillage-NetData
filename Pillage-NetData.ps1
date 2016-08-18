function RouteHunter([IntPtr]$arg1) { 
    $tmp = $arg1.ToInt64()
    $dwForwarddest = 1
    $genSize = 4 
    $dwForwardMask = 5
    $dwPolicy = 9 
    $policySize = 8
    $dwforwardNextHop = 13
    $dwForwardIfIndex = 17 
    $dwForwardType = 21
    $dwForwardProto = 25
    $dwAge = 29
    $dwForwardNextHopAS = 33
    $dwForwardMetric1 = 37
    $dwForwardMetric2 = 41
    $dwForwardMetric3 = 45
    $dwForwardMetric4 = 49	
	$bullshitSize = 2
    $end = 40 
    $enddist = 6
	$objOutput=New-Object -TypeName PSObject
	Add-Member -InputObject $objOutput -MemberType NoteProperty -Name "ForwardDestination" -Value ((DataCarver ($tmp + $dwForwarddest) $genSize $true))
    Add-Member -InputObject $objOutput -MemberType NoteProperty -Name "ForwardMask" -Value ((DataCarver($tmp + $dwForwardMask) $genSize $true))
	Add-Member -InputObject $objOutput -MemberType NoteProperty -Name "Policy" -Value ((DataCarver($tmp + $dwPolicy) $genSize  $false))
	Add-Member -InputObject $objOutput -MemberType NoteProperty -Name "ForwardNextHop" -Value ((DataCarver($tmp + $dwForwardNextHop) $genSize $true))
	Add-Member -InputObject $objOutput -MemberType NoteProperty -Name "ForwardInterfaceIndex" -Value ((DataCarver($tmp + $dwForwardIfIndex) 1 $false))
	Add-Member -InputObject $objOutput -MemberType NoteProperty -Name "ForwardType" -Value ((DataCarver($tmp + $dwForwardType) 1 $false))
	Add-Member -InputObject $objOutput -MemberType NoteProperty -Name "ForwardProtocol" -Value ((DataCarver($tmp + $dwForwardProto) 1 $false))
	Add-Member -InputObject $objOutput -MemberType NoteProperty -Name "Age" -Value ((DataCarver($tmp + $dwAge) 2 $false))
	Add-Member -InputObject $objOutput -MemberType NoteProperty -Name "ForwardNextHopAS" -Value ((DataCarver($tmp + $dwForwardNextHopAS) 2 $false))
    Add-Member -InputObject $objOutput -MemberType NoteProperty -Name "ForwardMetric1" -Value  ((DataCarver($tmp + $dwForwardMetric1) 2 $false))
	Add-Member -InputObject $objOutput -MemberType NoteProperty -Name "ForwardMetric2" -Value ((DataCarver($tmp + $dwForwardMetric2) 2 $false))
	Add-Member -InputObject $objOutput -MemberType NoteProperty -Name "ForwardMetric3" -Value ((DataCarver($tmp + $dwForwardMetric3) 2 $false))
	Add-Member -InputObject $objOutput -MemberType NoteProperty -Name "ForwardMetric4" -Value ((DataCarver($tmp + $dwForwardMetric4) 2 $false))
	#$objOutput.ForwardNextHopAS = [convert]::touint16($objOutput.ForwardNextHopAS,16)
	#$objOutput.ForwardMetric1 = [convert]::touint32($objOutput.ForwardMetric1,16)
	#$objOutput.ForwardMetric2 = [convert]::touint16($objOutput.ForwardMetric2,16)
	#$objOutput.ForwardMetric3 = [convert]::touint16($objOutput.ForwardMetric3,16)
	#$objOutput.ForwardMetric4 = [convert]::touint16($objOutput.ForwardMetric4,16)
	
	return $objOutput 
    
    }


function DataCarver([IntPtr]$arg1, [Int32]$size, [bool]$isIp) { 
    $return_string = ""
    for($i = 0; $i -lt $size; $i++) { 
       $readyByte = [Marshal]::ReadByte($arg1.ToInt64() + $i)
       $return_string += $readyByte.ToString()
       if($isIp -eq $true) { 
       $return_string += '.'
       }
       }
    if($isIp -eq $true) { 
    $return_string = $return_string.TrimEnd('.') 
    }
    return $return_string
    }




	
function RouteWalk([IntPtr]$rtable) {
   $it = 0
   $k = 3
   $len = [Marshal]::ReadByte($rtable.ToInt64())
   for($i = 0; $i -lt $len; $k+=56) { 
   
   $robject = RouteHunter(($rtable.ToInt64() + $k))
    Write-Host "Route " $it
	Write-Host "================================="
   $robject.PSObject.Properties | foreach-object { 
    Write-Host "["($_.Name)"]" ":" ($_.value) | Format-Table	 
   }
   Write-Host "================================="
   $it += 1
   Start-Sleep -m 200
   $i += 1
   }
   }



function Pillage-NetData {

begin { 

Add-Type -Name NullRoutes -Namespace "" -Member @"
        
   
        
        [DllImport("iphlpapi", CharSet = CharSet.Auto)]
        public extern static int GetIpForwardTable(IntPtr /*PMIB_IPFORWARDTABLE*/ pIpForwardTable, ref int /*PULONG*/ pdwSize, bool bOrder);

        [DllImport("iphlpapi", CharSet = CharSet.Auto)]
        public extern static int CreateIpForwardEntry(IntPtr /*PMIB_IPFORWARDROW*/ pRoute);
           

"@


$ta = [PSObject].Assembly.GetType(
      'System.Management.Automation.TypeAccelerators'
    )
	
$ta::Add('Marshal', [Runtime.InteropServices.Marshal])

Add-Type -Assembly "System.Net.NetworkInformation"





Write-Host "Enumerating Network Data...."

$tmp_net = [System.Net.NetworkInformation.NetworkInterface]::GetIsNetworkAvailable()
if (($tmp_net -eq $true)) {
Write-Host "Machine is connected to a network"
}
$ipglobal = [System.Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties()

$ipglobal | Format-Table

Write-Host "Checking if we can get out to the internet (Google Ping)"
Start-Sleep -s 1
$getout= New-Object System.Net.NetworkInformation.Ping

$getout.send("google.com") | Select Status, Address, Roundtriptime | Format-List

Write-Host "Active TCP Listeners"
$ipglobal.GetActiveTcpListeners() | Format-Table -property Address,Port -AutoSize
Start-Sleep -s 2
Write-Host "Active TCP Connections"
$ipglobal.GetActiveTcpConnections() | Format-Table -property LocalEndPoint,RemoteEndpoint,State -AutoSize
Start-Sleep -s 2
$ipglobal.GetActiveUdpListeners() | Format-Table -property Address,Port -AutoSize
$tcpstats = $ipglobal.GetTcpIpv4Statistics()
$udpstats = $ipglobal.GetUdpIpv4Statistics()
$ipv4global = $ipglobal.GetIpv4GlobalStatistics()
$netinterfaces = [System.Net.NetworkInformation.NetworkInterface]::GetAllNetworkInterfaces()
Write-Host "Network Interfaces"
For($i = 0; $i -lt $netinterfaces.Length; $i++) {
$netinterfaces[$i]
$int_prop = $netinterfaces[$i].GetIPProperties()
$netinterfaces[$i].GetIPProperties() | Format-List -property IsDnsEnabled, IsDynamicDnsEnabled, DnsAddresses, GatewayAddresses, DhcpServerAddresses
$int_prop.GetIpv4Properties()
$int_prop.GetIpv6Properties()
Write-Host "MAC Address: " $netinterfaces[$i].GetPhysicalAddress()
Write-Host "Interface-Specific Ipv4 Statistics:"
$netinterfaces[$i].GetIpv4Statistics()
Write-Host "Network Interface Type: " $netinterfaces[$i].NetworkInterfaceType
Write-Host "Is Receive-Only: "$netinterfaces[$i].IsReceiveOnly
$netinterfaces[$i].Description
Write-Host "Interface Speed: " $netinterfaces[$i].Speed
Write-Host "Additional GatewayAddress Data: "
$int_prop.GatewayAddresses.Address

}

 
Start-sleep -s 2
Write-Host "Global Ipv4 Information"
$ipglobal
Write-Host "Global TCP v4 Information"
$tcpstats
Write-Host "Global UDP v4 Information"
$udpstats
Write-Host "Displaying Route Table Information"

$rtable = [Marshal]::AllocHGlobal(2048)
$size = [ref] 2048 
$rtn = [NullRoutes]::GetIpForwardTable($rtable, $size, $false);
Write-Host "return-code" $rtn
RouteWalk($rtable)
}
}
