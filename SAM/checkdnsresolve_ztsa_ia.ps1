# Define categories and their respective URLs
$categories = @{
    "Service Exceptions" = @(
        "prod.ztsaagent.trendmicro.com",
        "upload.sg.xdr.trendmicro.com",
        "event-sg.ztsaagent.trendmicro.com"
    )
    "Authentication" = @(
        "agent-sg-rel.ztna.trendmicro.com",
        "signin.v1.trendmicro.com",
        "tm.login.trendmicro.com",
        "iamservice.trendmicro.com"
    )
    "Authentication (Google reCAPTCHA)" = @(
        "www.gstatic.com",
        "fonts.gstatic.com",
        "www.google.com",
        "www.recaptcha.net"
    )
}

# Function to resolve public IPs using the system's default DNS
function Get-ResolvedIPs {
    param ([string]$URL)

    try {
        $resolvedIPs = Resolve-DnsName -Name $URL -ErrorAction Stop | 
                       Where-Object { $_.QueryType -eq "A" } | 
                       Select-Object -ExpandProperty IPAddress
        
        if ($resolvedIPs) {
            return ($resolvedIPs | Sort-Object -Unique)  # Return unique IPs
        } else {
            Write-Host "    [WARNING] No IPs resolved for $URL" -ForegroundColor Yellow
            return @()
        }
    }
    catch {
        Write-Host "    [ERROR] Failed to resolve $URL" -ForegroundColor Red
        return @()
    }
}

# Function to test connectivity to each IP
function Test-URLConnection {
    param (
        [string]$IP
    )

    $result = Test-NetConnection -ComputerName $IP -Port 443 -WarningAction SilentlyContinue
    return [PSCustomObject]@{
        IP                = $IP
        TcpTestSucceeded  = $result.TcpTestSucceeded
    }
}

# Initialize an array to store results
$results = @{}
$uniqueIPs = @{}

# Loop through each category and test connection for its URLs
foreach ($category in $categories.Keys) {
    Write-Host "`n[INFO] Testing category: $category" -ForegroundColor Cyan

    foreach ($url in $categories[$category]) {
        Write-Host "  [INFO] Resolving IPs for $url..."
        $resolvedIPs = Get-ResolvedIPs -URL $url

        foreach ($ip in $resolvedIPs) {
            $testResult = Test-URLConnection -IP $ip

            # Determine color based on test success
            if ($testResult.TcpTestSucceeded) {
                Write-Host "    [SUCCESS] Connected to $ip" -ForegroundColor Green
            } else {
                Write-Host "    [FAILURE] Failed to connect to $ip" -ForegroundColor Red
            }

            # Store results
            if (-not $results[$url]) {
                $results[$url] = @()
            }
            $results[$url] += [PSCustomObject]@{
                Category          = $category
                URL               = $url
                ResolvedIP        = $ip
                TcpTestSucceeded  = $testResult.TcpTestSucceeded
            }

            # Add unique IPs for firewall allowlist
            if (-not $uniqueIPs[$url]) {
                $uniqueIPs[$url] = @()
            }
            if ($ip -notin $uniqueIPs[$url]) {
                $uniqueIPs[$url] += $ip
            }
        }
    }
}

# Display results in a structured table format
Write-Host "`n[RESULTS] Connection Test Summary:`n" -ForegroundColor Green
$results.Values | ForEach-Object { $_ } | Format-Table -Property Category, URL, ResolvedIP, TcpTestSucceeded -AutoSize

# Output unique IPs for firewall allowlist
Write-Host "`n[INFO] Unique IPs for Firewall Allowlist:" -ForegroundColor Cyan
foreach ($url in $uniqueIPs.Keys) {
    Write-Host "$url -> $($uniqueIPs[$url] -join ', ')"
}

# Export results to a CSV file
$exportData = $results.Values | ForEach-Object { $_ }
$exportData | Export-Csv -Path "ResolvedIPs.csv" -NoTypeInformation -Force
Write-Host "`n[INFO] Results exported to 'ResolvedIPs.csv'" -ForegroundColor Yellow
