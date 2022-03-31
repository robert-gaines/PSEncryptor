function main()
{
    $key = Get-Content "C:\Users\amnesiac\Desktop\PowerShells\SupportingScripts\aes.key"
    $cipher = New-Object System.Security.Cryptography.AesCryptoServiceProvider
    $cipher.Key = $key

    $base_path = "C:\Users\amnesiac\Desktop"

    Get-ChildItem -Path $base_path | Foreach-Object {
                                                            $current_file = $_.FullName
                                                            
                                                            if($current_file | Select-String '.enc')
                                                            {
                                                                Write-Host $current_file
                                                                $segments            = $current_file.Split('.')
                                                                $decrypted_file_name = $segments[0]+"."+$segments[1]
                                                                Write-Host $decrypted_file_name
                                                                $ct_file_content = Get-Content $current_file
                                                                $ct_file_content = [System.Convert]::FromBase64String($ct_file_content)
                                                                $cipher.IV       = $ct_file_content[0..15]
                                                            
                                                                $decipher_obj  = $cipher.CreateDecryptor()
                                                                $plaintext  = $decipher_obj.TransformFinalBlock($ct_file_content, 16, $ct_file_content.Length-16)
                                                                Set-Content -Path $decrypted_file_name -Value $plaintext -Encoding Byte
                                                                Remove-Item $current_file
                                                            }
                                                    }
    $cipher.Dispose()
}

main