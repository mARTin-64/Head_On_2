; Define some Labels
TEMP1 = $02
TEMP2 = $03
TEMP3 = $04
TEMP4 = $05
TEMP5 = $06
TEMP6 = $07

SCREEN_RAM = $C000  ; Define label for screen memory location
COLOR_RAM = $D800   ; Define label for colors memory location
BG_COLOR = $D021    ; Define label for background color memory location
BORDER_COLOR = $D020    ; Define label for border color memory location

MEMORY_REGISTER = $D018 ; Define label for for memory register location
RASTER_Y = $D012

SPRITE_MSB = $D010
ENABLE_SPRITES = $D015
SPRITE_POINTERS = SCREEN_RAM + $3F8

JOY_P_2 =   $DC00
JOY_ZP =    $10

PL_X =      $D000 ;\
PL_Y =      $D001 ; Player X and Y screen cordinates
PL_DIR =    $08
PL_TURBO =  $09

X_OFFSET = $0A
Y_OFFSET = $0B
EN0_X = $D002  ;\
EN0_Y = $D003  ; Enemy X and Y screen cordinates
