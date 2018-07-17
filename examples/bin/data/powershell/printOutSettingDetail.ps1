
#����
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



#�v�����g�֐�
function printImage($imageName, $printer, $paperSize, $MarginTop, $MarginBottom, $MarginRight, $MarginLeft, $landscape, $color, $fitImageToPaper) {

    #��O�����������ۂ̃��b�Z�[�W �������~�߂�ꍇ��break ������ꍇ��continue
    trap {
      Write-Host "error"
      break
    }
 
    [void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")


    #�v�����^���Z�b�g
    $doc = new-object System.Drawing.Printing.PrintDocument
    $doc.PrinterSettings.PrinterName = $printer
    

    #�������t�@�C�������擾 
    $doc.DocumentName = [System.IO.Path]::GetFileName($imageName)


    #�p���T�C�Y�ݒ�
    foreach($pSize in $doc.PrinterSettings.PaperSizes){

        if($paperSize -eq $pSize.Kind){
        
            $doc.DefaultPageSettings.PaperSize = $pSize
        
        }

    }


    #�]���̐ݒ�
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
    
    #����
    $doc.DefaultPageSettings.Landscape = $landscape


    #�F
    $doc.DefaultPageSettings.Color = $color


    #����J�n���̃C�x���g
    $doc.add_BeginPrint({
      Write-Host "==================== $($doc.DocumentName) ===================="
    })

    #����I�����̃C�x���g
    $doc.add_EndPrint({
        Write-Host "xxxxxxxxxxxxxxxxxxxx $($doc.DocumentName) xxxxxxxxxxxxxxxxxxxx"
    })


    #����o�͎��̃C�x���g
    $doc.add_PrintPage({

        Write-Host "Printing $imageName..."
        #PrintPageEventArgs �N���X
        #�������o�͂��w�肷��v���p�e�B
        #������PrintPageEventArgs�̃v���p�e�B

        
        #�]��
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


        #�y�[�W�̍��v�̈��\���l�p�`�̗̈���擾
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

        #�������摜
        $file = (get-item $imageName)
        $img = [System.Drawing.Image]::Fromfile($file);


        #�摜�̃T�C�Y
        $dustImageSize = $img.Size
      

        #�y�[�W�̋��ɂ��킹�邩�ǂ���
        if ($fitImageToPaper) {

          $fitWidth = [bool] ($img.Size.Width > $img.Size.Height)
          
          #�䗦
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


      # �T�C�Y�̒���
      $recDest = new-object Drawing.RectangleF($pageBounds.Location, $dustImageSize)
      #$recDest = new-object Drawing.RectangleF($pageBounds.Location, $pageBounds.Size)
      $recSrc = new-object Drawing.RectangleF(0, 0, $img.Width, $img.Height)
      

      Write-Host "===== rec  size =====" -ForegroundColor Magenta
      Write-Host $recDest
      Write-Host $recSrc


      # ����Graphics�ōׂ��ȃy�[�W�ݒ肪�ł���
      # �ȉ��́@�w�肵���C���[�W�����W�y�A�Ŏw�肳�ꂽ�ʒu�ɕ`��
      $g = $_.Graphics
      $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality

      $g.DrawImage($img, $recDest, $recSrc, [System.Drawing.GraphicsUnit]::Pixel)
      
      
      #�擾�܂��͂��̑��̃y�[�W��������邩�ǂ����������l��ݒ�
      $_.HasMorePages = $false; # nothing else to print
     })




    #�v�����g����
    $doc.Print()

}

#�v�����g
#printImage 'C:\Users\iwax\develop\Openframeworks\apps\myApps\METoA\PrintOutSystem\bin\data\image\NewsPaper\draft.jpg' 'EPSON PX-M5081F Series' "B4" 0 0 0 0 0 1 1
#printImage 'C:\Users\iwax\develop\Openframeworks\apps\myApps\METoA\PrintOutSystem\bin\data\image\NewsPaper\draft.jpg' 'Adobe PDF' "B4" 0 0 0 0 0 1 1
printImage $imageName $printer $paperSize $MarginTop $MarginBottom $MarginRight $MarginLeft $landscape $color $fitImageToPaper

