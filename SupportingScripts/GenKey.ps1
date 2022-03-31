
function GenKey()
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
}

GenKey