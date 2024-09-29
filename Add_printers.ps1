function AddPrinter {
    param (
        $PrinterValues
    )

    $tempPath = $env:TEMP

    # Create a temporary directory for printer drivers if it doesn't exist
    if (-not(Test-Path "$tempPath\PrinterSetup")) {
        New-Item -ItemType Directory -Path "$tempPath\PrinterSetup" -Force
    }

    cd "$tempPath\PrinterSetup\"
    
    # Download printer driver from specified URL
    Invoke-WebRequest -Uri $PrinterValues.printerDriver -OutFile $(split-path -path $PrinterValues.printerDriver -leaf)

    # Unzip the downloaded driver
    Expand-Archive -Path $(Split-Path -Path $PrinterValues.printerDriver -Leaf) -Force

    # Install the printer driver using the provided .inf file
    pnputil.exe -a ".\$($PrinterValues.infPath)"

    # Add the printer driver, port, and printer
    Add-PrinterDriver -Name $PrinterValues.driverName 
    Add-PrinterPort -Name $PrinterValues.printer_Ip -PrinterHostAddress $PrinterValues.printer_Ip
    Add-Printer -Name $PrinterValues.Name -DriverName $PrinterValues.driverName -PortName $PrinterValues.printer_Ip
}

# Define the printer configuration for multiple printers
$PrinterValuesList = @(
    [PSCustomObject]@{
        Name  = 'Finance-Canon'
        printerDriver = 'https://cs-print-drivers.s3.eu-central-1.amazonaws.com/drivers/Finance-driver.zip'
        infPath = "Finance-driver\Finance_driver\x64\Driver\CNP60MA64.inf"
        driverName = "Canon Generic Plus PCL6"
        printer_Ip =  "10.10.110.46"
    },
    [PSCustomObject]@{
        Name  = 'Canon-South'
        printerDriver = "https://cs-print-drivers.s3.eu-central-1.amazonaws.com/drivers/South-driver.zip"
        infPath = "South-driver\South-driver\cnnv4_cb3_bmfld.inf"
        driverName = "Canon MF8200C Series V4"
        printer_Ip =  "10.10.110.155"
    },
    [PSCustomObject]@{
        Name  = 'HR-Canon'
        printerDriver = 'https://cs-print-drivers.s3.eu-central-1.amazonaws.com/drivers/HR-driver.zip'
        infPath = "HR-driver\HR-driver\P664UKAL.inf"
        driverName = "Canon iR2220/iR3320 PCL6"
        printer_Ip =  "10.10.110.148"
    },
    [PSCustomObject]@{
        Name  = 'Split-Canon'
        printerDriver = 'https://cs-print-drivers.s3.eu-central-1.amazonaws.com/drivers/Split-driver.zip'
        infPath = "Split-driver\Split-driver\P664UKAL.inf"
        driverName = "Canon Generic Plus PCL6"
        printer_Ip =  "10.10.115.172"
    }
)

$allPrintersInstalled = Get-Printer
$allPorts = Get-PrinterPort
$allPrinterDrivers = Get-PrinterDriver

# Remove any existing printers, ports, and drivers
foreach ($printer in $allPrintersInstalled) {
    if ($printer.Name -in $PrinterValuesList.Name) {
        Remove-Printer -Name $printer.Name
    }
}

foreach ($port in $allPorts) {
    if ($port.Name -in $PrinterValuesList.printer_Ip) {
        Remove-PrinterPort -Name $port.Name
    }
}

foreach ($driver in $allPrinterDrivers) {
    if ($driver.Name -in $PrinterValuesList.driverName) {
        Remove-PrinterDriver -Name $driver.Name
    }
}

# Add the new printers
foreach ($printerValues in $PrinterValuesList) {
    AddPrinter -PrinterValues $printerValues
}

# Clean up temporary files
foreach ($printerValues in $PrinterValuesList) {
    $driverFolder = $(Split-Path -Path $printerValues.printerDriver -Leaf).Replace('.zip','')
    if (Test-Path -Path $driverFolder -PathType Container) {
        Remove-Item -Path $driverFolder -Recurse
    }
}
