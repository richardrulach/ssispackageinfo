
Clear-Host

$g_location = (Split-Path $MyInvocation.MyCommand.Definition).ToString()

#Remove-Item -Path Function:Get-SsisComponentName

function Get-SsisComponentName {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string] $id
    )

    BEGIN {}

    PROCESS {
        $component_csv = "$($g_location)\ComponentIDs.csv"
        $ComponentLookup = (Import-Csv -Path  $component_csv)
        ($ComponentLookup | Where-Object -Property "Enumeration Value" -like $id).Description
   }

    END {}

}


#Get-SsisComponentName -id "{2E42D45B-F83C-400F-8D77-61DDE6A7DF29}"


function Get-SsisSummary {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string[]] $Directory 
    )

    BEGIN {}

    PROCESS {


        # Create powershell variable namespace hashtable for use with Select-Xml Cmdlet
        $ns = @{DTS = "www.microsoft.com/SqlServer/Dts"}

        # Create the namespace manager so that SelectSingleNode and SelectNodes method calls work
        [xml] $xml = New-Object System.Xml.XmlDocument
        [System.Xml.NameTable] $nt = New-Object System.Xml.NameTable
        [System.Xml.XmlNamespaceManager] $xnm = New-Object System.Xml.XmlNamespaceManager($nt)
        $xnm.AddNamespace("DTS","www.microsoft.com/SqlServer/Dts")


        foreach ($d in $Directory){
            write-host "$d"
            $files = Get-ChildItem -Path $d -File -Recurse -Filter "*.dtsx" | ? { $_.FullName -notlike "*\obj\*" } 

            foreach ($f in $files){
                $version = ($f | select-xml -XPath "/DTS:Executable/DTS:Property[@DTS:Name='PackageFormatVersion']" -Namespace $ns).Node.InnerText


                switch($version){

                    3 {
                        $pipelines = ($f | select-xml -XPath "//DTS:Executable[@DTS:ExecutableType='SSIS.Pipeline.2']" -Namespace $ns).Count
                        

                        foreach ($conn in ($f | select-xml -XPath "/DTS:Executable/DTS:ConnectionManager" -Namespace $ns)){
                            $connectionType = $conn.Node.SelectSingleNode("./DTS:Property[@DTS:Name='CreationName']", $xnm).InnerText
                            $objectName = $conn.Node.SelectSingleNode("./DTS:Property[@DTS:Name='ObjectName']", $xnm).InnerText
                            $connectionString = $conn.Node.SelectSingleNode(".//DTS:Property[@DTS:Name='ConnectionString']", $xnm).InnerText
                        }

                        $executeSQLTasks = ($f | select-xml -XPath "//DTS:Executable" -Namespace $ns)
                            
                            
                        $counter = 0
                        foreach ($e in $executeSQLTasks){
                            if ($e.Node.Attributes["DTS:ExecutableType"].Value -like "Microsoft.SqlServer.Dts.Tasks.ExecuteSQLTask.ExecuteSQLTask*"){
                                $counter++
                            }
                        }
                        $executeSQL = $counter

                        $ComponentTypes = ($f | select-xml -XPath "//component" `
                                   | % { Get-SsisComponentName -id "$($_.Node.Attributes['componentClassID'].Value)" } )


                    }


                    6 {



                        $pipelines = ($f | select-xml -XPath "//DTS:Executable[@DTS:CreationName='SSIS.Pipeline.3']" -Namespace $ns).Count

                        foreach ($conn in ($f | select-xml -XPath "//DTS:ConnectionManagers/DTS:ConnectionManager" -Namespace $ns)){
                            $connectionType = $conn.Node.Attributes["DTS:CreationName"].Value
                            $objectName = $conn.Node.Attributes["DTS:ObjectName"].Value
                            $connectionString = $conn.Node.SelectSingleNOde("./DTS:ObjectData/DTS:ConnectionManager",$xnm).Attributes["DTS:ConnectionString"].Value
                        }

                        $executeSQLTasks = ($f | select-xml -XPath "//DTS:Executable" -Namespace $ns)
                            
                        $counter = 0
                        foreach ($e in $executeSQLTasks){
                            if ($e.Node.Attributes["DTS:ExecutableType"].Value -like "Microsoft.SqlServer.Dts.Tasks.ExecuteSQLTask.ExecuteSQLTask*"){
                                $counter++
                            }
                        }
                        $executeSQL = $counter

                        $ComponentTypes = ($f | select-xml -XPath "//component" `
                                   | % { Get-SsisComponentName -id $_.Node.Attributes['componentClassID'].Value } )

                    }

                    8 {


                        $pipelines = ($f | select-xml -XPath "//DTS:Executable[@DTS:CreationName='Microsoft.Pipeline']" -Namespace $ns).Count


                        foreach ($conn in ($f | select-xml -XPath "//DTS:ConnectionManagers/DTS:ConnectionManager" -Namespace $ns)){
                            $connectionType = $conn.Node.Attributes["DTS:CreationName"].Value
                            $objectName = $conn.Node.Attributes["DTS:ObjectName"].Value
                            $connectionString = $conn.Node.SelectSingleNOde("./DTS:ObjectData/DTS:ConnectionManager",$xnm).Attributes["DTS:ConnectionString"].Value
                        }

                        $executeSQL = ($f | select-xml -XPath "//DTS:Executable[@DTS:ExecutableType='Microsoft.ExecuteSQLTask']" -Namespace $ns).Count

                        $ComponentTypes = ($f | select-xml -XPath "//component" `
                                   | % { [String] $_.Node.Attributes['componentClassID'].Value } )

                    }

                }


                $TaskTypes = ($f | select-xml -XPath "//DTS:Executable" -Namespace $ns `
                           | % { [String] $_.Node.Attributes['DTS:ExecutableType'].Value } )

                

                # OUTPUT THE SUMMARY OBJECT TO THE PIPELINE

                New-Object -TypeName PSObject -Property @{
                    Name = $f;
                    FullName = $f.fullname;
                    Pipelines = $pipelines;
                    ExecSQL = $executeSQL;
                    Version = $version;
                    TaskTypes = $TaskTypes;
                    ComponentTypes = $ComponentTypes
                }

            }


        }

    }

    END {}
}

#$summaries = Get-SsisSummary -Directory "C:\DEVELOPMENT\SSIS_CARDANO\SSIS"

$summaries = Get-SsisSummary -Directory "C:\git\ssispackageinfo\ssis_test_projects"


$summaries

<#
$summaries | 
    Group-Object -property Version | 
    %{ New-Object -Type PSObject -Property @{ "Count" = $_.Count; "VersionNumber" = $_.Name } }

#>
