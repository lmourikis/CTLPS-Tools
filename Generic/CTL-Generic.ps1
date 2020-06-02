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


function CTLRetrieve-KVObjectRow { 
    <#
        You search for the record in an object, that a specific field has a specific value.
        For example, for Microsoft 365 Teams, you have an object will all the Tenant's teams.
        You want the GroupId from a Team that has a specific DiplayName. This function can
        help you find the Team record.
    #>
    Param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=0,ValueFromPipelineByPropertyName=$true)]
    [object]$KV,
    [Parameter(Mandatory=$true)]
    [object]$KeyName,
    [Parameter(Mandatory=$true)]
    [object]$KeyValue
    )

    $KV | % {
        if ($_.$($KeyName) -eq $KeyValue) {
            return $_
            break
        }
    }

    return $null
}
