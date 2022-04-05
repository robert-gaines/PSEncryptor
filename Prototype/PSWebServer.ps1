Add-Type -AssemblyName System.Web

function main()
{
    $addr = 'localhost'
    $port = 8000
    $serverObject = New-Object System.Net.HTTPListener
    $serverObject.Prefixes.Add("http://"+$addr+":"+$port+'/')
    $serverObject.Start()
    New-PSDrive -Name PSWebServerSite -PSProvider FileSystem -Root $PWD.Path
    $context = $serverObject.GetContext()
    $url     = $context.Request.Url.LocalPath
    $content = Get-Content -Encoding Byte -Path "PSWebServerSite:$url"
    $context.Response.ContentType = [System.Web.MimeMapping]::GetMimeMapping("PSWebServerSite:$url")
    $context.Response.OutputStream.Write($content, 0, $Content.Length)
    $context.Response.close()
}

main