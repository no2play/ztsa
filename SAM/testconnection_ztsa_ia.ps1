# Define the categories and their respective URLs
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

# Function to test connection
function Test-URLConnection {
    param (
        [string]$URL
    )

    $result = Test-NetConnection -ComputerName $URL -Port 443 -WarningAction SilentlyContinue
    [PSCustomObject]@{
        URL               = $URL
        TcpTestSucceeded  = $result.TcpTestSucceeded
        RemoteAddress     = $result.RemoteAddress
    }
}

# Initialize an array to store the results
$results = @()

# Loop through each category and test connection for its URLs
foreach ($category in $categories.Keys) {
    Write-Host "`nTesting category: $category" -ForegroundColor Cyan

    foreach ($url in $categories[$category]) {
        $testResult = Test-URLConnection -URL $url
        
        # Determine color based on test success
        if ($testResult.TcpTestSucceeded) {
            Write-Host "  Connection to $url succeeded." -ForegroundColor Green
        } else {
            Write-Host "  Connection to $url failed!" -ForegroundColor Red
        }

        # Add results to array
        $results += [PSCustomObject]@{
            Category          = $category
            URL               = $testResult.URL
            TcpTestSucceeded  = $testResult.TcpTestSucceeded
            RemoteAddress     = $testResult.RemoteAddress
        }
    }
}

# Display results in a structured table format
Write-Host "`nConnection Test Results:" -ForegroundColor Green
$results | Format-Table -Property Category, URL, TcpTestSucceeded, RemoteAddress -AutoSize

# Optionally, export the results to a CSV file
# $results | Export-Csv -Path "CategorizedConnectionTestResults.csv" -NoTypeInformation -Force
# Write-Host "`nResults exported to 'CategorizedConnectionTestResults.csv'" -ForegroundColor Yellow
