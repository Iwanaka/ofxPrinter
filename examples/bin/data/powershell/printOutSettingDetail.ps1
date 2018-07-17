
#入力
param(
  [parameter(mandatory, HelpMessage="you must set file path")]
  [string]$imageName,
  [parameter(mandatory, HelpMessage="you must set printer name")]
  [string]$printer,
  [string]$paperSize = "A4",
  [int]$MarginTop = 100,
  [int]$MarginBottom = 100,
  [int]$MarginRight = 100,
  [int]$MarginLeft = 100,
  [bool]$landscape = $false,
  [bool]$color = $true,
  [bool]$fitImageToPaper = $true
)



#プリント関数
function printImage($imageName, $printer, $paperSize, $MarginTop, $MarginBottom, $MarginRight, $MarginLeft, $landscape, $color, $fitImageToPaper) {

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


    #用紙サイズ設定
    foreach($pSize in $doc.PrinterSettings.PaperSizes){

        if($paperSize -eq $pSize.Kind){
        
            $doc.DefaultPageSettings.PaperSize = $pSize
        
        }

    }


    #余白の設定
    Write-Host $doc.DefaultPageSettings.PrintableArea
    Write-Host $doc.DefaultPageSettings.Margins
    Write-Host $doc.DefaultPageSettings.HardMarginX
    Write-Host $doc.DefaultPageSettings.HardMarginY
    $doc.DefaultPageSettings.Margins.Top = $MarginTop
    $doc.DefaultPageSettings.Margins.Bottom = $MarginBottom
    $doc.DefaultPageSettings.Margins.Right = $MarginRight
    $doc.DefaultPageSettings.Margins.Left = $MarginLeft
    Write-Host $doc.OriginAtMargins
    $doc.OriginAtMargins = $true
    Write-Host $doc.OriginAtMargins
    Write-Host $doc.DefaultPageSettings.Margins
    Write-Host $doc.DefaultPageSettings.HardMarginX
    Write-Host $doc.DefaultPageSettings.HardMarginY
    
    #向き
    $doc.DefaultPageSettings.Landscape = $landscape


    #色
    $doc.DefaultPageSettings.Color = $color


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
        #これらはPrintPageEventArgsのプロパティ

        
        #余白
        $marginBounds = $_.MarginBounds
        Write-Host "===== page bounds =====" -ForegroundColor Magenta
        Write-Host $marginBounds
        Write-Host $marginBounds.Location
        Write-Host $marginBounds.Size
        
        Write-Host $marginBounds.Top
        Write-Host $marginBounds.Left
        Write-Host $marginBounds.Bottom
        Write-Host $marginBounds.Right

        Write-Host $marginBounds.Width
        Write-Host $marginBounds.Height


        #ページの合計領域を表す四角形の領域を取得
        $pageBounds = $_.pageBounds
        Write-Host "===== page bounds =====" -ForegroundColor Magenta
        Write-Host $pageBounds
        Write-Host $pageBounds.Location
        Write-Host $pageBounds.Size
        
        Write-Host $pageBounds.Top
        Write-Host $pageBounds.Left
        Write-Host $pageBounds.Bottom
        Write-Host $pageBounds.Right

        Write-Host $pageBounds.Width
        Write-Host $pageBounds.Height

        #印刷する画像
        $file = (get-item $imageName)
        $img = [System.Drawing.Image]::Fromfile($file);


        #画像のサイズ
        $dustImageSize = $img.Size
      

        #ページの隅にあわせるかどうか
        if ($fitImageToPaper) {

          $fitWidth = [bool] ($img.Size.Width > $img.Size.Height)
          
          #比率
          $widthRatio = [double] ($_.MarginBounds.Width / $img.Size.Width);
          $heightRatio = [double] ($_.MarginBounds.Height / $img.Size.Height)
          $ratio = [double] 1; 

           Write-Host "===== ratio =====" -ForegroundColor Magenta
           Write-Host $widthRatio
           Write-Host $heightRatio    

          if ($fitWidth) {
         
            $dustImageSize = new-object System.Drawing.SizeF([float]($img.Size.Width * $heightRatio), [float]($img.Size.Height * $heightRatio))

          } else {
            
            $dustImageSize = new-object System.Drawing.SizeF([float]($img.Size.Width * $widthRatio), [float]($img.Size.Height * $widthRatio))
          
          }

          #$dustImageSize.Width = $dustImageSize.Width * 0.98
          #$dustImageSize.Height = $dustImageSize.Height * 0.98
          
          Write-Host "===== dust image size =====" -ForegroundColor Magenta
          Write-Host $dustImageSize

        }


      # サイズの調整
      $recDest = new-object Drawing.RectangleF($pageBounds.Location, $dustImageSize)
      #$recDest = new-object Drawing.RectangleF($pageBounds.Location, $pageBounds.Size)
      $recSrc = new-object Drawing.RectangleF(0, 0, $img.Width, $img.Height)
      

      Write-Host "===== rec  size =====" -ForegroundColor Magenta
      Write-Host $recDest
      Write-Host $recSrc


      # このGraphicsで細かなページ設定ができる
      # 以下は　指定したイメージを座標ペアで指定された位置に描画
      $g = $_.Graphics
      $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality

      $g.DrawImage($img, $recDest, $recSrc, [System.Drawing.GraphicsUnit]::Pixel)
      
      
      #取得またはその他のページを印刷するかどうかを示す値を設定
      $_.HasMorePages = $false; # nothing else to print
     })




    #プリントする
    $doc.Print()

}

#プリント
#printImage 'C:\Users\iwax\develop\Openframeworks\apps\myApps\METoA\PrintOutSystem\bin\data\image\NewsPaper\draft.jpg' 'EPSON PX-M5081F Series' "B4" 0 0 0 0 0 1 1
#printImage 'C:\Users\iwax\develop\Openframeworks\apps\myApps\METoA\PrintOutSystem\bin\data\image\NewsPaper\draft.jpg' 'Adobe PDF' "B4" 0 0 0 0 0 1 1
printImage $imageName $printer $paperSize $MarginTop $MarginBottom $MarginRight $MarginLeft $landscape $color $fitImageToPaper

