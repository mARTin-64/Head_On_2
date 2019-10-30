; Define some Labels
SCREEN_RAM   = $C000  ; Define label for screen memory location
COLOR_RAM    = $D800   ; Define label for colors memory location
BG_COLOR     = $D021    ; Define label for background color memory location
BORDER_COLOR = $D020    ; Define label for border color memory location

SPRITE_COLOR1 = $D027
SPRITE_COLOR2 = $D028
SPRITE_COLLISION =$D01E

MEMORY_REGISTER = $D018 ; Define label for for memory register location
RASTER_Y        = $D012

SPRITE_MSB      = $D010
ENABLE_SPRITES  = $D015
SPRITE_POINTERS = SCREEN_RAM + $3F8

PL_X =      $D000 ;\
PL_Y =      $D001 ; Player X and Y screen cordinates

PLAYER_ACTIVE = %00000001
ENEMY_ACTIVE  = %00000010

PLAYER_STATE_1 = $00000001
PLAYER_STATE_2 = $00000010
PLAYER_STATE_3 = $00000100
PLAYER_STATE_4 = $00001000
JOY_P_2 =   $DC00

SOLID =      %00010000
POINT_5 =              %00100000
POINT_25 =             %01000000

OFFSET_XL =     $18 ; Const 
OFFSET_XR =     $11 ; Const 
OFFSET_XDL =    $19 ; Const 
OFFSET_XDR =    $10 ; Const 

OFFSET_YU =     $32 ; Const 
OFFSET_YD =     $2B ; Const 
OFFSET_YDU =    $33 ; Const 
OFFSET_YDD =    $2A ; Const 

MAIN_MENU =     $01 ; Const
PLAY    =       $02 ; Const
VICTORY =       $04 ; Const
CRASH   =       $08 ; Const
LOOSE   =       $10 ; Const

YES = $01
NO  = $00

EN0_X = $D002  ;\
EN0_Y = $D003  ; Enemy X and Y screen cordinates

EN1_X = $D004  ;\
EN1_Y = $D005  ; Enemy X and Y sc
