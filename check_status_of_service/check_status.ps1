# Write a PowerShell script that checks the status of a Windows service and restarts it if it is not running.
# This script uses the Get-Service cmdlet to check the status of the specified service. If the service is not running, it uses the Restart-Service cmdlet to restart the service and logs the action to a specified log file. It also sends an email notification to a specified recipient using the Send-MailMessage cmdlet.
# To improve the script, it uses Select-Object -ExpandProperty to get the status of the service as a string, rather than an object. It also uses the Tee-Object cmdlet to log the output to a file and display it in the console. Finally, it adds email notification functionality using the Send-MailMessage cmdlet.


# Set the name of the service to check and restart
$serviceName = "MyService"

# Set the path and name of the log file
$logFilePath = "C:\logs\ServiceRestart.log"

# Set the recipient and sender email addresses for notifications
$recipientEmail = "admin@example.com"
$senderEmail = "noreply@example.com"
$smtpServer = "smtp.example.com"

# Check the service status
$serviceStatus = Get-Service -Name $serviceName | Select-Object -ExpandProperty Status

# If the service is not running, restart it
if ($serviceStatus -ne "Running") {
    Write-Output "$(Get-Date): $serviceName is not running, restarting..." | Tee-Object -FilePath $logFilePath -Append
    Restart-Service -Name $serviceName
    Write-Output "$(Get-Date): $serviceName has been restarted" | Tee-Object -FilePath $logFilePath -Append

    # Send a notification email
    $subject = "Service Restarted: $serviceName"
    $body = "The $serviceName service has been restarted on $(Get-Date)."
    Send-MailMessage -To $recipientEmail -From $senderEmail -Subject $subject -Body $body -SmtpServer $smtpServer
} else {
    Write-Output "$(Get-Date): $serviceName is running" | Tee-Object -FilePath $logFilePath -Append
}