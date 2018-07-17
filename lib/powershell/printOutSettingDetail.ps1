
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



function printImage($imageName, $printer, $paperSize, $MarginTop, $MarginBottom, $MarginRight, $MarginLeft, $landscape, $color, $fitImageToPaper) {


    trap {
      Write-Host "error"
      break
    }
 
    [void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")


    $doc = new-object System.Drawing.Printing.PrintDocument
    $doc.PrinterSettings.PrinterName = $printer
    

    $doc.DocumentName = [System.IO.Path]::GetFileName($imageName)


    foreach($pSize in $doc.PrinterSettings.PaperSizes){

        if($paperSize -eq $pSize.Kind){
        
            $doc.DefaultPageSettings.PaperSize = $pSize
        
        }

    }


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
    

    $doc.DefaultPageSettings.Landscape = $landscape


    $doc.DefaultPageSettings.Color = $color


    $doc.add_BeginPrint({
      Write-Host "==================== $($doc.DocumentName) ===================="
    })


    $doc.add_EndPrint({
        Write-Host "xxxxxxxxxxxxxxxxxxxx $($doc.DocumentName) xxxxxxxxxxxxxxxxxxxx"
    })


    $doc.add_PrintPage({

        Write-Host "Printing $imageName..."

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

        $file = (get-item $imageName)
        $img = [System.Drawing.Image]::Fromfile($file);

        $dustImageSize = $img.Size
      

        if ($fitImageToPaper) {

          $fitWidth = [bool] ($img.Size.Width > $img.Size.Height)
          
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
 
          Write-Host "===== dust image size =====" -ForegroundColor Magenta
          Write-Host $dustImageSize

        }


      $recDest = new-object Drawing.RectangleF($pageBounds.Location, $dustImageSize)
      #$recDest = new-object Drawing.RectangleF($pageBounds.Location, $pageBounds.Size)
      $recSrc = new-object Drawing.RectangleF(0, 0, $img.Width, $img.Height)
      

      Write-Host "===== rec  size =====" -ForegroundColor Magenta
      Write-Host $recDest
      Write-Host $recSrc


      $g = $_.Graphics
      $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality

      $g.DrawImage($img, $recDest, $recSrc, [System.Drawing.GraphicsUnit]::Pixel)
      
      
      $_.HasMorePages = $false; # nothing else to print
     })


    $doc.Print()

}

printImage $imageName $printer $paperSize $MarginTop $MarginBottom $MarginRight $MarginLeft $landscape $color $fitImageToPaper

