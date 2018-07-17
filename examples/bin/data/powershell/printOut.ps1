
#$file = (get-item '.\test.jpg')
#$img = [System.Drawing.Image]::Fromfile($file)
#Write-Output $img.Size.Width
#$img | Out-Printer -Name ('Adobe PDF')

#入力
param(
  [parameter(mandatory, HelpMessage="you must set file path")]
  [string]$imageName,
  [parameter(mandatory, HelpMessage="you must set printer name")]
  [string]$printer,
  [bool]$fitImageToPaper = $true
)



#プリント関数
function printImage($imageName, $printer, $fitImageToPaper) {

    #例外が発生した際のメッセージ 処理を止める場合はbreak 続ける場合はcontinue
    trap {
      Write-Host "error"
      break
    }
 
    [void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")


    #プリンタをセット
    $doc = new-object System.Drawing.Printing.PrintDocument
    $doc.PrinterSettings.PrinterName = $printer
    

    #印刷するファイル名を取得 
    $doc.DocumentName = [System.IO.Path]::GetFileName($imageName)



    #印刷開始時のイベント
    $doc.add_BeginPrint({
      Write-Host "==================== $($doc.DocumentName) ===================="
    })

    #印刷終了時のイベント
    $doc.add_EndPrint({
        Write-Host "xxxxxxxxxxxxxxxxxxxx $($doc.DocumentName) xxxxxxxxxxxxxxxxxxxx"
    })


    #印刷出力時のイベント
    $doc.add_PrintPage({

        Write-Host "Printing $imageName..."
        #PrintPageEventArgs クラス
        #印刷する出力を指定するプロパティ
        #GraphicsはPrintPageEventArgsのプロパティ
        $g = $_.Graphics
        #余白
        $pageBounds = $_.MarginBounds
      
        #印刷する画像
        $file = (get-item $imageName)
        $img = [System.Drawing.Image]::Fromfile($file);
        #$img = new-object Drawing.Bitmap($imageName)

        #画像のサイズ
        $adjustedImageSize = $img.Size
        #比率
        $ratio = [double] 1;
      

        #ページの隅にあわせるかどうか
        if ($fitImageToPaper) {

          $fitWidth = [bool] ($img.Size.Width > $img.Size.Height)

          if (($img.Size.Width -le $_.MarginBounds.Width) -and
          ($img.Size.Height -le $_.MarginBounds.Height)) {
        
            $adjustedImageSize = new-object System.Drawing.SizeF($img.Size.Width, $img.Size.Height)
       
          } else {
        
          if ($fitWidth) {
         
            $ratio = [double] ($_.MarginBounds.Width / $img.Size.Width);
        
          } else {
         
            $ratio = [double] ($_.MarginBounds.Height / $img.Size.Height)
        
          }
        
          $adjustedImageSize = new-object System.Drawing.SizeF($_.MarginBounds.Width, [float]($img.Size.Height * $ratio))
    
        }
    
      }


      # サイズの調整
      $recDest = new-object Drawing.RectangleF($pageBounds.Location, $adjustedImageSize)
      $recSrc = new-object Drawing.RectangleF(0, 0, $img.Width, $img.Height)
      
      # このGraphicsで細かなページ設定ができる
      # 以下は　指定したイメージを座標ペアで指定された位置に描画
      $_.Graphics.DrawImage($img, $recDest, $recSrc, [Drawing.GraphicsUnit]"Pixel")
      

      #取得またはその他のページを印刷するかどうかを示す値を設定
      $_.HasMorePages = $false; # nothing else to print
     })


    #プリントする
    $doc.Print()
}

#プリント
printImage $imageName $printer $fitImageToPaper