
$printers = Get-WmiObject -Class Win32_Printer

Write-Host $printers

Write-Host "========== printer list ==========" -ForegroundColor Magenta
0..($printers.Count -1 ) | %{

    Write-Host $printers[$_].name -ForegroundColor Green

    $value = $printers[$_].name + ":" + $printers[$_].Default + ":"

    foreach($pkSize in $printers[$_].PrinterPaperNames){
        
        $value += $pkSize + ","
        
    }

    $value.Remove($value.Length - 1, 1)

    if($_ -eq 0) {

        Set-Content -path ./printerList.ini -value $value -encoding String

    }
    else {

        Add-Content -path ./printerList.ini -value $value -encoding String

    }

}

Write-Host "====================" -ForegroundColor Magenta

exit
