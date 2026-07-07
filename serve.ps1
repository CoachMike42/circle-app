$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$port = 5175
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()
Write-Host "Serving $root on http://localhost:$port/"
$mime = @{ ".html"="text/html"; ".js"="text/javascript"; ".json"="application/json"; ".svg"="image/svg+xml"; ".css"="text/css" }
while ($listener.IsListening) {
    $ctx = $listener.GetContext()
    $req = $ctx.Request
    $res = $ctx.Response
    $path = $req.Url.LocalPath
    if ($path -eq "/") { $path = "/index.html" }
    $file = Join-Path $root ($path.TrimStart("/"))
    if (Test-Path $file -PathType Leaf) {
        $ext = [System.IO.Path]::GetExtension($file)
        $ct = $mime[$ext]
        if (-not $ct) { $ct = "application/octet-stream" }
        $res.ContentType = $ct
        $bytes = [System.IO.File]::ReadAllBytes($file)
        $res.ContentLength64 = $bytes.Length
        $res.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
        $res.StatusCode = 404
    }
    $res.OutputStream.Close()
}
