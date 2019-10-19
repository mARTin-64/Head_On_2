; Define some Labels
TEMP1 = $02 ; ZP
TEMP2 = $03 ; ZP
TEMP3 = $04 ; ZP
TEMP4 = $05 ; ZP
TEMP5 = $06 ; ZP
TEMP6 = $07 ; ZP

SCREEN_RAM   = $C000  ; Define label for screen memory location
COLOR_RAM    = $D800   ; Define label for colors memory location
BG_COLOR     = $D021    ; Define label for background color memory location
BORDER_COLOR = $D020    ; Define label for border color memory location

MEMORY_REGISTER = $D018 ; Define label for for memory register location
RASTER_Y        = $D012

SPRITE_MSB      = $D010
ENABLE_SPRITES  = $D015
SPRITE_POINTERS = SCREEN_RAM + $3F8

JOY_P_2 =   $DC00
JOY_ZP =    $10 ; ZP

PL_X =      $D000 ;\
PL_Y =      $D001 ; Player X and Y screen cordinates
PL_DIR =    $08 ; ZP
PL_TURBO =  $09 ; ZP

OFFSET_XL =     $18 ; Const 
OFFSET_XR =     $11 ; Const 
OFFSET_XDL =    $19 ; Const 
OFFSET_XDR =    $10 ; Const 

OFFSET_YU =     $32 ; Const 
OFFSET_YD =     $2B ; Const 
OFFSET_YDU =    $33 ; Const 
OFFSET_YDD =    $2A ; Const 

COLLISION_LOOKUP = $0A ; ZP
COLLISION_X      = $11   ; ZP
COLLISION_Y      = $12   ; ZP

X_OFFSET = $0B  ; ZP
Y_OFFSET = $0C  ; ZP

POINT_COUNTER = $0D ; ZP
POINT_TYPE =    $0E ; ZP
POINT_VALUE =   $0F ; ZP
GAME_STATE =    $1A ; ZP

PLAY    =       $01 ; Const
VICTORY =       $02 ; Const
LOOSE   =       $04 ; Const

EN0_X = $D002  ;\
EN0_Y = $D003  ; Enemy X and Y screen cordinates
