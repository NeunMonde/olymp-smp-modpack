$BaseInput = "Modpack\all\"

class Variant {
    [string]$FriendlyName
    [string]$Source
    [string]$Target
    [string[]]$Depends = @()

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

    Variant(
        [string]$friendlyName, 
        [string]$source, 
        [string]$target
    ) {
        $this.FriendlyName = $friendlyName
        $this.Source = $source
        $this.Target = $target
    }

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

    Variant(
        [string]$friendlyName, 
        [string]$path
    ) {
        $this.FriendlyName = $friendlyName
        $this.Source = $path
        $this.Target = $path
    }
    
}

$variants = @{
    'basic' = [Variant]::new('Basic', 'basic', 'manual-basic')
    'beaut' = [Variant]::new('Beatiful', 'beautiful', 'manual-beaut', @('basic'))
    'serve' = [Variant]::new('Server', 'server')
}

function Build-Modpack {

    param (
        [string]$variantName,
        [string]$target = ''
    )

    [Variant]$variant = $variants[$variantName]

    if ($target -eq '' ) {
        $target = $variant.Target
    }
    
    if ($variant.Depends -ne @()) {
        $variant.Depends.ForEach( { Build-Modpack -variantName $_ -target $target } )
    }

    [string]$inputPath = "Modpack\$($variant.Source)\"
    [string]$outputPath = "Releases\Olymp-$target-v.v.v\"
    
    Write-Output "`nBuilding $($variant.FriendlyName) Modpack..."

    robocopy $BaseInput $outputPath /e /j
    robocopy $inputPath $outputPath /e /j
}


$variants.Keys.ForEach( { Build-Modpack -variantName $_ } )