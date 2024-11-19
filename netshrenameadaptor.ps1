# Define variables for current and new adapter names
$currentName = "Local Area Connection 2"
$newName = "SWGAdapter"
$outputPath = "$env:USERPROFILE\Desktop\netsh_result.txt"  # Text file save path

# Function to run netsh command and rename adapter
function Rename-NetworkAdapter {
    Write-Output "Renaming adapter '$currentName' to '$newName'..."
    $netshCommand = "netsh interface set interface name=`"$currentName`" newname=`"$newName`""
    $result = cmd.exe /c $netshCommand  # Run the command and capture output
    $result | Out-File -FilePath $outputPath -Encoding UTF8  # Save the output to a file
    Write-Output "Command output saved to $outputPath"
}

# Main execution
try {
    Rename-NetworkAdapter
} catch {
    Write-Error "An error occurred: $_"
}
