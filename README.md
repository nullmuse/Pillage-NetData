#Pillage-NetData

Extract network data from .NET and rebuild route table from memory

Data is accessed without WMI or calling separate processes 

Note: some commands may fail out -- this is normal, it is usually the result of the cmdlet querying a data structure one of your network interfaces do not support 

Pillage-NetData will retrieve the following data: 

-If the computer is connected to a network 

-Computer host name 

-Network domain name 

-Global IP properties 

-If the computer can connect to the internet (by pinging Google) 

-A list of active TCP and UDP Listeners

-A list of active TCP connections, to include recently closed connections 

-Detailed TCP and UDP network and packet statistics 

-Detailed global IP statistics 

-All network interfaces connected to the computer 

-Detailed information, configuration and statistical information about each interface 

-Gateway addresses assigned to each interface 

-DNS servers assigned to each interface 

-DHCP servers assigned to each interface 

-WINS servers assigned to each interface 

-In-memory routing table 


#Usage 

PS> . .\Pillage-NetData.ps1
PS>Pillage-NetData

#Additional Functions 

Additional functions RouteHunter(), CarveData() and RouteWalk() are exposed for use. Function Prototypes are below: 

RouteHunter([IntPtr]$arg1)

DataCarver([IntPtr]$arg1, [Int32]$size, [bool]$isIp)

RouteWalk([IntPtr]$rtable)

A word of caution -- there is no checking of parameters before executing. As such, calling these functions with no or null parameters will likely crash your powershell process, as most of the parameters will be dereferenced during execution





