
Clear-Host

$g_location = (Split-Path $MyInvocation.MyCommand.Definition).ToString()


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

$summaries = Get-SsisSummary -Directory "C:\DEVELOPMENT\SSIS_CARDANO\SSIS"

#$summaries = Get-SsisSummary -Directory "C:\git\ssispackageinfo\ssis_test_projects"


$packageSummary = ( 
      $summaries `
    | Group-Object -property Version `
    | %{ New-Object -Type PSObject -Property @{ "Package Version" = $_.Name;"Total Packages" = $_.Count } } `
    | ConvertTo-Html -Fragment -Property "Package Version","Total Packages"
)


$componentSummary = (
      $summaries.ComponentTypes `
    | Group-Object `
    | %{ New-Object -Type PSObject -Property @{ "Component" = $_.Name;"Count" = $_.Count } } `
    | Sort-Object -Property Count -Descending `
    | ConvertTo-Html -Fragment -Property "Component","Count" `
)


$taskSummary = (
      $summaries.TaskTypes `
    | Group-Object `
    | %{ New-Object -Type PSObject -Property @{ "Task" = $_.Name;"Count" = $_.Count } } `
    | Sort-Object -Property Count -Descending `
    | ConvertTo-Html -Fragment -Property "Task","Count" `
)


"<h1>SSIS Package Viewer</h1>" | Out-File c:\temp\ssis.html -Force
"<h2>Package Versions</h2>" | Out-File c:\temp\ssis.html -Append
$packageSummary | Out-File c:\temp\ssis.html -Append
"<h2>Tasks in use</h2>" | Out-File c:\temp\ssis.html -Append
$taskSummary | Out-File c:\temp\ssis.html -Append
"<h2>Pipeline components in use</h2>" | Out-File c:\temp\ssis.html -Append
$componentSummary | Out-File c:\temp\ssis.html -Append


& c:\temp\ssis.html

