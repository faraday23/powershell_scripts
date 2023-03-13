# Write a script that monitors the event logs of a group of servers and sends an alert if a specific event is logged.
# This will create a text file in the C:\Logs directory called eventlog_alerts.txt that logs the output of the script, including any error messages or other output that might be useful for troubleshooting.

# Set the email parameters
$smtpServer = "smtp.example.com"
$smtpPort = 587
$smtpUsername = "alerts@example.com"
$smtpPassword = "password"
$from = "alerts@example.com"
$to = "admin@example.com"
$subject = "Event log alert"
$body = "The specified events have been logged in the event log."

# Set the event parameters
$eventLog = "Application"
$servers = @("server1.example.com", "server2.example.com")
$eventIDs = @(1000, 1001, 1002)
$eventCountThreshold = 3
$timeFrame = [System.TimeSpan]::FromMinutes(30)

# Start logging the output to a file
Start-Transcript -Path "C:\Logs\eventlog_alerts.txt"

# Loop through the servers and check the event log
foreach ($server in $servers) {
    $events = Get-WinEvent -FilterHashtable @{LogName=$eventLog; ID=$eventIDs; StartTime=(Get-Date).AddMinutes(-$timeFrame.TotalMinutes)} -ComputerName $server -ErrorAction SilentlyContinue

    # If the event is logged multiple times within the time frame, send an email alert
    if ($events.Count -ge $eventCountThreshold) {
        $smtp = New-Object Net.Mail.SmtpClient($smtpServer, $smtpPort)
        $smtp.EnableSsl = $true
        $smtp.Credentials = New-Object System.Net.NetworkCredential($smtpUsername, $smtpPassword)

        $message = New-Object System.Net.Mail.MailMessage($from, $to, $subject, $body)
        $message.IsBodyHtml = $false
        $smtp.Send($message)
    }
}

# Stop logging the output to the file
Stop-Transcript
