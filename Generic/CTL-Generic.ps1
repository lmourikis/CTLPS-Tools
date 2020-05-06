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
        Get-FileHash -InputStream $stringAsStream -Algorithm $HashAlgorithm | Select-Object -ExpandProperty Hash -OutVariable $md5response
    } # End of Process

    End {
        # Adding a coma in Return hopefully will make the function return a single item array.
        # However, this does not seem the case. As an alternative you can use the function
        # output in your code as follows:
        # $myHash = CTLGet-StringHash -InputString "My text"
        # $myHash[1]
        Return ,$md5response
    }
}
