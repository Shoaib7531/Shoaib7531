# Satark.AI Multi-Device Static HTTP Server (TcpListener 0.0.0.0)
param([int]$Port = 8085)

$baseDir = "C:\Users\ratho\.gemini\antigravity\scratch\satark-prototype"
$ipAddress = [System.Net.IPAddress]::Any
$listener = New-Object System.Net.Sockets.TcpListener($ipAddress, $Port)

try {
    $listener.Start()
    Write-Host "TCP Server listening on 0.0.0.0:$Port"
} catch {
    Write-Host "Failed to start on $($Port): $_"
    exit 1
}

$mimeTypes = @{
    ".html" = "text/html; charset=utf-8"
    ".css"  = "text/css; charset=utf-8"
    ".js"   = "application/javascript; charset=utf-8"
    ".json" = "application/json; charset=utf-8"
    ".png"  = "image/png"
    ".svg"  = "image/svg+xml"
    ".ico"  = "image/x-icon"
}

while ($true) {
    try {
        $client = $listener.AcceptTcpClient()
        $stream = $client.GetStream()
        $reader = New-Object System.IO.StreamReader($stream)
        
        $requestLine = $reader.ReadLine()
        if ([string]::IsNullOrEmpty($requestLine)) {
            $client.Close()
            continue
        }
        
        $parts = $requestLine.Split(" ")
        $urlPath = if ($parts.Length -ge 2) { $parts[1] } else { "/" }
        
        $qIdx = $urlPath.IndexOf('?')
        if ($qIdx -ge 0) { $urlPath = $urlPath.Substring(0, $qIdx) }
        
        if ($urlPath -eq "/" -or [string]::IsNullOrWhiteSpace($urlPath)) {
            $urlPath = "/index.html"
        }
        
        $relPath = $urlPath.TrimStart('/').Replace('/', '\')
        $filePath = Join-Path $baseDir $relPath
        
        if (Test-Path $filePath -PathType Leaf) {
            $ext = [System.IO.Path]::GetExtension($filePath).ToLower()
            $contentType = if ($mimeTypes.ContainsKey($ext)) { $mimeTypes[$ext] } else { "application/octet-stream" }
            $fileBytes = [System.IO.File]::ReadAllBytes($filePath)
            
            $header = "HTTP/1.1 200 OK`r`nContent-Type: $contentType`r`nContent-Length: $($fileBytes.Length)`r`nAccess-Control-Allow-Origin: *`r`nConnection: close`r`n`r`n"
            $headerBytes = [System.Text.Encoding]::ASCII.GetBytes($header)
            
            $stream.Write($headerBytes, 0, $headerBytes.Length)
            $stream.Write($fileBytes, 0, $fileBytes.Length)
            $stream.Flush()
        } else {
            $notFound = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found")
            $header = "HTTP/1.1 404 Not Found`r`nContent-Type: text/plain`r`nContent-Length: $($notFound.Length)`r`nConnection: close`r`n`r`n"
            $headerBytes = [System.Text.Encoding]::ASCII.GetBytes($header)
            $stream.Write($headerBytes, 0, $headerBytes.Length)
            $stream.Write($notFound, 0, $notFound.Length)
            $stream.Flush()
        }
        
        $client.Close()
    } catch {
        # ignore transient client disconnects
    }
}
