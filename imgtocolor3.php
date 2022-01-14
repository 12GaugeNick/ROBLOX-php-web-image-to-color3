<?php
    $Image = $_GET["Image"];

    ini_set('memory_limit', '1024M');
    
    function getPixel($Image, $X, $Y) {
        $rgb = imagecolorat($Image, $X, $Y);
        $r = ($rgb >> 16) & 0xFF;
        $g = ($rgb >> 8) & 0xFF;
        $b = $rgb & 0xFF;
        return array($r, $g, $b);
    }

function imagecreatefrombmp($filename) {
        $file = fopen( $filename, "rb" );
        $read = fread( $file, 10 );
        while( !feof( $file ) && $read != "" )
        {
            $read .= fread( $file, 1024 );
        }
        $temp = unpack( "H*", $read );
        $hex = $temp[1];
        $header = substr( $hex, 0, 104 );
        $body = str_split( substr( $hex, 108 ), 6 );
        if( substr( $header, 0, 4 ) == "424d" )
        {
            $header = substr( $header, 4 );
            // Remove some stuff?
            $header = substr( $header, 32 );
            // Get the width
            $width = hexdec( substr( $header, 0, 2 ) );
            // Remove some stuff?
            $header = substr( $header, 8 );
            // Get the height
            $height = hexdec( substr( $header, 0, 2 ) );
            unset( $header );
        }
        $x = 0;
        $y = 1;
        $image = imagecreatetruecolor( $width, $height );
        foreach( $body as $rgb )
        {
            $r = hexdec( substr( $rgb, 4, 2 ) );
            $g = hexdec( substr( $rgb, 2, 2 ) );
            $b = hexdec( substr( $rgb, 0, 2 ) );
            $color = imagecolorallocate( $image, $r, $g, $b );
            imagesetpixel( $image, $x, $height-$y, $color );
            $x++;
            if( $x >= $width )
            {
                $x = 0;
                $y++;
            }
        }
        return $image;
    }

function ImageToColor3($URL) {
        $Extension = pathinfo($URL, PATHINFO_EXTENSION);
        $Image;
        if ($Extension == "jpg" || $Extension == "jpeg") {
            $Image = imagecreatefromjpeg($URL);
        } elseif ($Extension == "png") {
            $Image = imagecreatefrompng($URL);
        } elseif ($Extension == "bmp") {
            $Image = imagecreatefrombmp($URL);
        } elseif ($Extension == "gif") {
            $Image = imagecreatefromgif($URL);
        } else {
            die("Extension not supported (yet).");
        }
        if (empty($Image)) {
            die("No image found.");
        }
        $ImageSize   = getimagesize($URL);
        $ImageWidth  = $ImageSize[0];
        $ImageHeight = $ImageSize[1];
        $Array = array();
        
        for($XPosition=0;$XPosition<$ImageWidth;$XPosition++) {
            for($YPosition=0;$YPosition<$ImageHeight;$YPosition++) {
                $Array[] = array($XPosition, $YPosition, getPixel($Image, $XPosition, $YPosition));
            }
        }
        
        echo(json_encode($Array));
    }
    
    
    if (!empty($Image)) {
        ImageToColor3($Image);
    }
?>
