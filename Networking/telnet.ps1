
# This script Tests functionality of an SMTP server, used in an enviroment where virtual SMTP server was still in use via IIS


# Ensure Telnet client is enabled
Enable-WindowsOptionalFeature -Online -FeatureName TelnetClient

# SMTP Server Settings
$smtpServer = "(Local-SMTPServer-Name)"
$smtpPort = 587  
$senderEmail = "(Sender-Email)"
$recipientEmail = "(Recipient-Email)"

# Email Content
$subject = "Test Email from PowerShell"
$body = "This is a test email sent via PowerShell and Telnet."

# Telnet Connection and Commands
$telnet = New-Object System.Net.Sockets.TcpClient($smtpServer, $smtpPort)
$stream = $telnet.GetStream()
$writer = New-Object System.IO.StreamWriter($stream)
$reader = New-Object System.IO.StreamReader($stream)

# Read initial greeting from server
$reader.ReadLine()

# Send SMTP commands
$writer.WriteLine("HELO $smtpServer")
$reader.ReadLine()
$writer.WriteLine("MAIL FROM: <$senderEmail>")
$reader.ReadLine()
$writer.WriteLine("RCPT TO: <$recipientEmail>")
$reader.ReadLine()
$writer.WriteLine("DATA")
$reader.ReadLine()
$writer.WriteLine("Subject: $subject")
$writer.WriteLine()
$writer.WriteLine($body)
$writer.WriteLine(".")
$reader.ReadLine()

# Close the connection
$writer.WriteLine("QUIT")
$telnet.Close()
