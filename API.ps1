$global:JSSApi = New-Module -AsCustomObject -ScriptBlock {
	# Header Hashtable
	[System.Collections.Hashtable] $Header
	# Translation Table $RequestURI <-> XML-Tag => All X
	[System.Collections.Hashtable] $TTAll = @{
		"computers" = "computers";
		"mobiledevices" = "mobile_devices";
		"users" = "users";
	}
	# Translation Table $RequestURI <-> XML-Tag => One X
	[System.Collections.Hashtable] $TTSingle = @{
		"computers" = "computer";
		"mobiledevices" = "mobile_device";
		"users" = "user";
	}
	# BaseUrl String
	[String] $BaseUrl
	# Initialization Method - run me first.
	function init {
		param( 
			[Parameter(Mandatory=$true)] [String] $BaseUrl,
			[Parameter(Mandatory=$true)] [String] $Username,
			[Parameter(Mandatory=$true)] [String] $Password )
		# Calc AuthToken for HTTP Basic Auth
		$AuthToken = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("$($Username):$($Password)"))
		# Write the BasicAuth Header
		$script:Header = @{ Authorization = "Basic "+$AuthToken }
		# Store the BaseUrl
		$script:BaseUrl = $BaseUrl
	}
	
	# Get Method. If the ID is set, it tries to get the explicit Object.
	# Maybe an entry within the Translationtable is needed.
	function get {
		param(
			[Parameter(Mandatory=$true)] [String] $Path,
			[Parameter(Mandatory=$false)] [Int] $ID = 0 )
		# If $ID is still the default Value, we search for ALL these Objects
		if( $ID -eq 0 ) {
			$MyUrl = $BaseUrl+$Path
			$XMLPath = $script:TTAll[$Path]
		}
		# Else we try to find the specific Object
		else {
			$MyUrl = $BaseUrl+$Path+"/id/"+$ID
			$XMLPath = $script:TTSingle[$Path]
		}
		# Fire the request, parse the XML
		$Output = [xml] (Invoke-WebRequest -Uri $MyUrl -Headers $script:Header)
		# Return the unwrapped Object
		return $Output."$XMLPath"
	}
} -Function *

# Usage :
# Initialising
#$JSSApi.init("https://Hostname:Secureport/JSSResource/", "Username", "Password")
# Get all Mobile Devices
#$JSSApi.get("mobiledevices")
# Get all Computers
#$JSSApi.get("computers")
# Get specific Computer with ID = 64
#$JSSApi.get("computers", 64)
