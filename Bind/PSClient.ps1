
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

            $stream = $s.GetStream()
            $transmitter = New-Object System.IO.StreamWriter($stream)
            $receiver    = New-Object System.IO.StreamReader($stream)
            $cmd         = Read-Host "[*]>>> "
            $cmd         = [System.Text.Encoding]::Unicode.GetBytes($cmd)
            $cmd         = [Convert]::ToBase64String($cmd)
            $transmitter.WriteLine($cmd)
            $transmitter.Flush()

            if($cmd | Select-String 'exit')
            {
                $s.Close()
            }

            $intake      = $receiver.ReadLine()
            $intake      = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($intake))
            $response    = $intake

            if($intake)
            {
                Write-Host $response
            }
    }
}

PSClient localhost 8080