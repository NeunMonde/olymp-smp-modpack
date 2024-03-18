#Class for a Mod-Pack-Variant
#Contains values for a Name, a Source folder name, a Target folder name, a list of dependencies
#Deploy-Switch for toggling the deployment of the pack as a standalone Variant, set to False for pure depencies
class Variant {
    [string]$FriendlyName
    [string]$Source
    [string]$Target
    [string[]]$Depends = @()
	[bool]$Deploy = $true

	#Full Constructor with Name of the Pack, Source folder name, Target folder name, dependencies
    Variant(
        [string]$friendlyName, 
        [string]$source, 
        [string]$target, 
        [string[]]$depends
    ) {
        $this.FriendlyName = $friendlyName
        $this.Source = $source
        $this.Target = $target
        $this.Depends = $depends
    }

	#Full Constructor without dependencies
    Variant(
        [string]$friendlyName, 
        [string]$source, 
        [string]$target
    ) {
        $this.FriendlyName = $friendlyName
        $this.Source = $source
        $this.Target = $target
    }

	#Constructor where target and source folder share a name, with dependencies
    Variant(
        [string]$friendlyName, 
        [string]$path,
        [string[]]$depends
    ) {
        $this.FriendlyName = $friendlyName
        $this.Source = $path
        $this.Target = $path
        $this.Depends = $depends
    }

	#Constructor with common tource and target folder names
    Variant(
        [string]$friendlyName, 
        [string]$path
    ) {
        $this.FriendlyName = $friendlyName
        $this.Source = $path
        $this.Target = $path
    }
	
	#Stub constructor for dependency-packages, has no name and no target folder
	Variant(
		[string]$path
	) {
		$this.Source = $path
		$this.Deploy = $false
	}
    
}

#Hashtable for all variants
#Key used internally for accessing the Variants
$variants = @{
	'all'   = [Variant]::new('all')
    'basic' = [Variant]::new('Basic', 'basic', 'manual-basic', [string[]]@('all'))
    'beaut' = [Variant]::new('Beatiful', 'beautiful', 'manual-beaut', [string[]]@('basic'))
    'serve' = [Variant]::new('Server', 'server', [string[]]@('all'))
}

#Function for building the modpacks
#Takes a variant name and optionally a target folder name
#has no output
function Build-Modpack {

    param (
        [string]$variantName,
        [string]$target = ''
    )

	#look up the variant with the given name
    [Variant]$variant = $variants[$variantName]

	#if target folder name is not explicitly set, set target folder name to the name set in the variant
    if ($target -eq '' ) {
        $target = $variant.Target
    }
    
	#Install all dependencies into the current target folder, if the list of dependencies is not empty
    if ($variant.Depends -ne @()) {
        $variant.Depends.ForEach( { Build-Modpack -variantName $_ -target $target } )
    }

	#set input and output path according to source and target folder names
    [string]$inputPath = "..\Modpack\$($variant.Source)\"
    [string]$outputPath = "..\Releases\Olymp-$target-v.v.v\"
    
	#copy from input path to output path
    robocopy $inputPath $outputPath /e /j /np /nfl
}


#iterate through all keys in the $variants Hashtable and deploy the corresponding modpack if Deploy-Switch is set to true
forEach ($key in $variants.Keys) {
	if ($variants[$key].Deploy -eq $true) {
        Write-Output "`nBuilding Modpack $($variants[$key].FriendlyName)..."
		Build-Modpack -variantName $key
	}
}