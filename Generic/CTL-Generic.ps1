function CTLGet-StringHash {
    # Generates has code of an input string
    Param (
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
        [string]$InputString,
        [Parameter(Mandatory=$false)]
        [ValidateSet(“SHA1”,”SHA256”,”SHA384”,”SHA384”,”SHA512”,”MACTripleDES”,”MD5”,”RIPEMD160”)] 
        [string]$HashAlgorithm = "MD5"
    ) # End of Parameters

    Begin {}

    Process {
        [string]$md5response

        $stringAsStream = [System.IO.MemoryStream]::new()
        $writer = [System.IO.StreamWriter]::new($stringAsStream)
        $writer.write("$($InputString)")
        $writer.Flush()
        $stringAsStream.Position = 0
        #$md5response = Get-FileHash -InputStream $stringAsStream | Select-Object -ExpandProperty Hash
        $md5response = Get-FileHash -InputStream $stringAsStream -Algorithm $HashAlgorithm | Select-Object Hash
    } # End of Process

    End {
        Return $md5response
    }
}
