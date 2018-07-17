
param(
  [parameter(mandatory, HelpMessage="you must set file path")]
  [string]$imageName,
  [parameter(mandatory, HelpMessage="you must set printer name")]
  [string]$printer,
  [bool]$fitImageToPaper = $true
)


function printImage($imageName, $printer, $fitImageToPaper) {

    trap {
      Write-Host "error"
      break
    }
 
    [void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")

    $doc = new-object System.Drawing.Printing.PrintDocument
    $doc.PrinterSettings.PrinterName = $printer
    
    $doc.DocumentName = [System.IO.Path]::GetFileName($imageName)

    $doc.add_BeginPrint({
      Write-Host "==================== $($doc.DocumentName) ===================="
    })

    $doc.add_EndPrint({
        Write-Host "xxxxxxxxxxxxxxxxxxxx $($doc.DocumentName) xxxxxxxxxxxxxxxxxxxx"
    })

    $doc.add_PrintPage({

        Write-Host "Printing $imageName..."

        $g = $_.Graphics

        $pageBounds = $_.MarginBounds
      
        $file = (get-item $imageName)
        $img = [System.Drawing.Image]::Fromfile($file);

        $adjustedImageSize = $img.Size
        $ratio = [double] 1;
      
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

      $recDest = new-object Drawing.RectangleF($pageBounds.Location, $adjustedImageSize)
      $recSrc = new-object Drawing.RectangleF(0, 0, $img.Width, $img.Height)
      
      $_.Graphics.DrawImage($img, $recDest, $recSrc, [Drawing.GraphicsUnit]"Pixel")
      
      $_.HasMorePages = $false; # nothing else to print
     })

    $doc.Print()
}

printImage $imageName $printer $fitImageToPaper