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
                                                u$$$$        $$$$$u$u$u$$$       u$$$$
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
                                        1) Send 10 BTC to: {0}
                                        2) Receive keys and instructions
                                        3) Wait for your files to be decrypted 

'@ -f $walletAddr

Add-Type -AssemblyName System.Windows.Forms

$Label = New-Object System.Windows.Forms.Label
$Label.TabIndex = 1
$Label.Text = $Text
$Label.ForeColor = 'Black'
$Label.AutoSize = $True
$Label.Font = "Lucida Console, 16pt, style=Regular"
$Label.Location = '0, 30'

$Form = New-Object system.Windows.Forms.Form
$Form.AutoSize()
$Form.Controls.Add($Label)
$Form.WindowState = 'Maximized'
$Form.FormBorderStyle = 'None'
$Form.BackColor = "#DC143C"
$Form.Cursor=[System.Windows.Forms.Cursors]::WaitCursor
$Form.ShowDialog()

