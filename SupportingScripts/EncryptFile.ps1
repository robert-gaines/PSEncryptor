
function EncryptFile($file)
{
    $new_file_name = $file+'.enc'

    $prng   = New-Object System.Security.Cryptography.RNGCryptoServiceProvider
    $cipher = New-Object System.Security.Cryptography.AesCryptoServiceProvider

    $key = [System.Byte[]]::new(32) 

    $prng.GetBytes($key)

    $cur_path = (Get-Location).Path
    $filename = 'aes.key'
    $key_path = $cur_path+"\"+$filename

    $key | Out-File -FilePath $key_path 

    $iv = [System.Byte[]]::new(16)

    $prng.GetBytes($iv)

    $cipher.Key = $key
    $cipher.IV  = $iv

    $file_content  = Get-Content $file -Encoding Byte
    $cipher_obj    = $cipher.CreateEncryptor()
    $enc_bytes     = $cipher_obj.TransformFinalBlock($file_content, 0, $file_content.Length)
    [byte[]]$enc_bytes_iv   = $cipher.IV+$enc_bytes
    $ciphertext = [System.Convert]::ToBase64String($enc_bytes_iv)
    $base_path  = (Get-Location).Path
    $out_path   = $base_path+"\"+$new_file_name
    Set-Content -Path $out_path -Value $ciphertext 
    Remove-Item $file
    $cipher.Dispose()
    $prng.Dispose()
} 

EncryptFile 'test.txt'