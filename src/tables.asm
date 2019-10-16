!zone Tables {

ScreenRowLSB:
    !byte ( SCREEN_RAM +   0 ) & 0x00ff
    !byte ( SCREEN_RAM +  40 ) & 0x00ff
    !byte ( SCREEN_RAM +  80 ) & 0x00ff
    !byte ( SCREEN_RAM + 120 ) & 0x00ff
    !byte ( SCREEN_RAM + 160 ) & 0x00ff
    !byte ( SCREEN_RAM + 200 ) & 0x00ff
    !byte ( SCREEN_RAM + 240 ) & 0x00ff
    !byte ( SCREEN_RAM + 280 ) & 0x00ff
    !byte ( SCREEN_RAM + 320 ) & 0x00ff
    !byte ( SCREEN_RAM + 360 ) & 0x00ff
    !byte ( SCREEN_RAM + 400 ) & 0x00ff
    !byte ( SCREEN_RAM + 440 ) & 0x00ff
    !byte ( SCREEN_RAM + 480 ) & 0x00ff
    !byte ( SCREEN_RAM + 520 ) & 0x00ff
    !byte ( SCREEN_RAM + 560 ) & 0x00ff
    !byte ( SCREEN_RAM + 600 ) & 0x00ff
    !byte ( SCREEN_RAM + 640 ) & 0x00ff
    !byte ( SCREEN_RAM + 680 ) & 0x00ff
    !byte ( SCREEN_RAM + 720 ) & 0x00ff
    !byte ( SCREEN_RAM + 760 ) & 0x00ff
    !byte ( SCREEN_RAM + 800 ) & 0x00ff
    !byte ( SCREEN_RAM + 840 ) & 0x00ff
    !byte ( SCREEN_RAM + 880 ) & 0x00ff
    !byte ( SCREEN_RAM + 920 ) & 0x00ff
    !byte ( SCREEN_RAM + 960 ) & 0x00ff
ScreenRowMSB:
    !byte ( ( SCREEN_RAM +   0 ) & 0xff00 ) >> 8
    !byte ( ( SCREEN_RAM +  40 ) & 0xff00 ) >> 8
    !byte ( ( SCREEN_RAM +  80 ) & 0xff00 ) >> 8
    !byte ( ( SCREEN_RAM + 120 ) & 0xff00 ) >> 8
    !byte ( ( SCREEN_RAM + 160 ) & 0xff00 ) >> 8
    !byte ( ( SCREEN_RAM + 200 ) & 0xff00 ) >> 8
    !byte ( ( SCREEN_RAM + 240 ) & 0xff00 ) >> 8
    !byte ( ( SCREEN_RAM + 280 ) & 0xff00 ) >> 8
    !byte ( ( SCREEN_RAM + 320 ) & 0xff00 ) >> 8
    !byte ( ( SCREEN_RAM + 360 ) & 0xff00 ) >> 8
    !byte ( ( SCREEN_RAM + 400 ) & 0xff00 ) >> 8
    !byte ( ( SCREEN_RAM + 440 ) & 0xff00 ) >> 8
    !byte ( ( SCREEN_RAM + 480 ) & 0xff00 ) >> 8
    !byte ( ( SCREEN_RAM + 520 ) & 0xff00 ) >> 8
    !byte ( ( SCREEN_RAM + 560 ) & 0xff00 ) >> 8
    !byte ( ( SCREEN_RAM + 600 ) & 0xff00 ) >> 8
    !byte ( ( SCREEN_RAM + 640 ) & 0xff00 ) >> 8
    !byte ( ( SCREEN_RAM + 680 ) & 0xff00 ) >> 8
    !byte ( ( SCREEN_RAM + 720 ) & 0xff00 ) >> 8
    !byte ( ( SCREEN_RAM + 760 ) & 0xff00 ) >> 8
    !byte ( ( SCREEN_RAM + 800 ) & 0xff00 ) >> 8
    !byte ( ( SCREEN_RAM + 840 ) & 0xff00 ) >> 8
    !byte ( ( SCREEN_RAM + 880 ) & 0xff00 ) >> 8
    !byte ( ( SCREEN_RAM + 920 ) & 0xff00 ) >> 8
    !byte ( ( SCREEN_RAM + 960 ) & 0xff00 ) >> 8
}


