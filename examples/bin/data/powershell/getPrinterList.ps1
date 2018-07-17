
#基本的に配列で格納される
$printers = Get-WmiObject -Class Win32_Printer

#デバイスの名前 基本これでマッチングさせる
Write-Host $printers

Write-Host "========== printer list ==========" -ForegroundColor Magenta
#0から（printersの個数-）回forを回すset
0..($printers.Count -1 ) | %{

    Write-Host $printers[$_].name -ForegroundColor Green

    $value = $printers[$_].name + ":" + $printers[$_].Default + ":"

    foreach($pkSize in $printers[$_].PrinterPaperNames){
        
        $value += $pkSize + ","
        
    }

    $value.Remove($value.Length - 1, 1)

    #改行しない場合は単純に"+"を使えばよさげ Add-Content と ">"は出力される文字コードが違う
    if($_ -eq 0) {
        #$printers[$_].name + ":" + $printers[$_].Default > "printerList.txt"
        #($printers[$_].name).toString() > "printerList.ini"
        Set-Content -path ./printerList.ini -value $value -encoding String
    }
    else {
        #$printers[$_].name + ":" + $printers[$_].Default >> "printerList.txt"
        #$printers[$_].name >> "printerList.ini"
        Add-Content -path ./printerList.ini -value $value -encoding String
    }

}

Write-Host "====================" -ForegroundColor Magenta

exit

#temp = "@powershell -NoProfile -ExecutionPolicy unrestricted -Command \"./data/powershell/printOut.ps1\" ./data/testImage/test.jpg \"Adobe PDF\""