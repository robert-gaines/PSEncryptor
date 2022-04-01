
function ScreenShot()
{
    [Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null

    function screenshot([Drawing.Rectangle]$bounds, $path) 
    {
        $bmp = New-Object Drawing.Bitmap $bounds.width, $bounds.height
        $graphics = [Drawing.Graphics]::FromImage($bmp)

        $graphics.CopyFromScreen($bounds.Location, [Drawing.Point]::Empty, $bounds.size)

        $bmp.Save($path)

        $graphics.Dispose()

        $bmp.Dispose()
    }

    $query = Get-CIMInstance -ClassName Win32_VideoController

    $x_sum = 0
    $y_sum = 0

    $query | Foreach-Object {
                                $x = $_.CurrentHorizontalResolution
                                $y = $_.CurrentVerticalResolution 

                                if($x -and $y)
                                {
                                    $x_sum += $x 
                                    $y_sum += $y
                                }

                            }

    $bounds = [Drawing.Rectangle]::FromLTRB(0, 0, $x_sum, $y_sum)
    $computerName = $env:COMPUTERNAME
    $dateTime = Get-Date -Format "MM_dd_yyyy_hh_mm_ss"
    $imageTitle = "Screen_Shot_"+$computerName+'_'+$dateTime+"_.jpg"

    $currentUser = $env:USERNAME

    screenshot $bounds ".\$imageTitle"

    #$imagePath = "C:\Users\$currentUser\Desktop\$imageTitle"
}

ScreenShot