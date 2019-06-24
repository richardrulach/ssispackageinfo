
        clear-host

function Get-SsisSummary {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string[]] $Directory 
    )

    BEGIN {}

    PROCESS {

        $ns = @{DTS = "www.microsoft.com/SqlServer/Dts"}

        foreach ($d in $Directory){
            write-host "$d"
            $files = Get-ChildItem -Path $d -File -Recurse -Filter "*.dtsx" | ? { $_.FullName -notlike "*\obj\*" } 

            foreach ($f in $files){
                $version = ($f | select-xml -XPath "/DTS:Executable/DTS:Property[@DTS:Name='PackageFormatVersion']" -Namespace $ns).Node.InnerText


                switch($version){

                    3 {
                        $pipelines = ($f | select-xml -XPath "//DTS:Executable[@DTS:ExecutableType='SSIS.Pipeline.2']" -Namespace $ns).Count
                        
                        $executeSQLTasks = ($f | select-xml -XPath "//DTS:Executable" -Namespace $ns)
                            
                        $counter = 0
                        foreach ($e in $executeSQLTasks){
                            if ($e.Node.Attributes["DTS:ExecutableType"].Value -like "Microsoft.SqlServer.Dts.Tasks.ExecuteSQLTask.ExecuteSQLTask*"){
                                $counter++
                            }
                        }
                        $executeSQL = $counter

                    }


                    6 {
                        $pipelines = ($f | select-xml -XPath "//DTS:Executable[@DTS:CreationName='SSIS.Pipeline.3']" -Namespace $ns).Count

                        $executeSQLTasks = ($f | select-xml -XPath "//DTS:Executable" -Namespace $ns)
                            
                        $counter = 0
                        foreach ($e in $executeSQLTasks){
                            if ($e.Node.Attributes["DTS:ExecutableType"].Value -like "Microsoft.SqlServer.Dts.Tasks.ExecuteSQLTask.ExecuteSQLTask*"){
                                $counter++
                            }
                        }
                        $executeSQL = $counter

                    }

                    8 {
                        $pipelines = ($f | select-xml -XPath "//DTS:Executable[@DTS:CreationName='Microsoft.Pipeline']" -Namespace $ns).Count
                        $executeSQL = ($f | select-xml -XPath "//DTS:Executable[@DTS:ExecutableType='Microsoft.ExecuteSQLTask']" -Namespace $ns).Count
                    }

                }



                # OUTPUT THE SUMMARY OBJECT TO THE PIPELINE

                New-Object -TypeName PSObject -Property @{
                    Name = $f;
                    FullName = $f.fullname;
                    Pipelines = $pipelines;
                    ExecSQL = $executeSQL;
                    Version = $version
                }

            }


        }

    }

    END {}
}

#$summaries = Get-SsisSummary -Directory "C:\DEVELOPMENT\SSIS_CARDANO\SSIS"

$summaries = Get-SsisSummary -Directory "C:\git\ssispackageinfo\ssis_test_projects"

$summaries | 
    Group-Object -property Version | 
    %{ New-Object -Type PSObject -Property @{ "Count" = $_.Count; "VersionNumber" = $_.Name } }


