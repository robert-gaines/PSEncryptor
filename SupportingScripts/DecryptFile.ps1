
function DecryptFile($key_file,$file)
{
    $key = Get-Content $key_file

    $segments            = $file.Split('.')
    $decrypted_file_name = $segments[0]+"."+$segments[1]
    $base_path           = (Get-Location).Path
    $out_path            = $base_path+"\"+$decrypted_file_name 

    $cipher = New-Object System.Security.Cryptography.AesCryptoServiceProvider
    $cipher.Key = $key

    $ct_file_content = Get-Content $file
    $ct_file_content = [System.Convert]::FromBase64String($ct_file_content)
    $cipher.IV       = $ct_file_content[0..15]

    $decipher_obj  = $cipher.CreateDecryptor()
    $pre_pt_bytes  = $decipher_obj.TransformFinalBlock($ct_file_content, 16, $ct_file_content.Length-16)
    
    $plaintext     = [System.Text.Encoding]::UTF8.GetString($pre_pt_bytes)
    Set-Content -Path $out_path -Value $plaintext 
    Remove-Item $file
    $cipher.Dispose()

}

DecryptFile 'aes.key' 'test.txt.enc'