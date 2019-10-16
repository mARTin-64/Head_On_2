;--------------------------------------------------------
;--Main game routines                    
;--------------------------------------------------------

!zone SCREEN {

;--------------------------------------------------------
;--Clear the visible screen routine     
;--------------------------------------------------------
ClearScreen:

    lda #$07
    ldx #250
-
    dex                 ; Decreas value in X register by 1
    sta SCREEN_RAM, X       ;\
    sta SCREEN_RAM + 250, X ; Store loaded character to Screen RAM
    sta SCREEN_RAM + 500, X ; at multiple locations at once 
    sta SCREEN_RAM + 750, X ;/
    bne -               ; Go to - if X != 0

    rts

;--------------------------------------------------------
;--Routine for drawing game map         
;--------------------------------------------------------
DrawMap:
    
    ldy #$00            ; Our map data is loaded to $8000 location. See "assets.asm"
-                       ; Loop through Map bytes and store them in Screen RAM
    lda MAP, y          ; This is currently drawing map from 4 locations on screen
    tax                 ; and setting right colors for characters. I will later 
    sta SCREEN_RAM, y   ; change this code to be self modifying.
    lda CHAR_COLORS, x
    sta COLOR_RAM, y 
    lda MAP + $0100, y 
    tax
    sta SCREEN_RAM + $0100, y
    lda CHAR_COLORS, x
    sta COLOR_RAM + $0100, y
    lda MAP + $0200, y
    tax
    sta SCREEN_RAM + $0200, y
    lda CHAR_COLORS, x
    sta COLOR_RAM + $0200, y
    lda MAP + $0300, y
    tax
    sta SCREEN_RAM + $0300, y
    lda CHAR_COLORS, x
    sta COLOR_RAM + $0300, y
    iny 
    bne -
    
    rts

}

;--------------------------------------------------------
;--Player routines                       
;--------------------------------------------------------

!zone Player { 

; Declaring some local variables    

.MV_UP: !byte $01
.MV_DN: !byte $02
.MV_LT: !byte $04
.MV_RT: !byte $08

.Turbo: !byte $01

.PlayerX: !byte $00, $00
.PlayerY: !byte $00, $00

;--------------------------------------------------------
;--Routine for intializing player          
;--------------------------------------------------------
PlayerInit:
.JOY_UP = %00001
.JOY_DN = %00010
.JOY_LT = %00100
.JOY_RT = %01000
.JOY_FR = %10000

.COLLISION_SOLID =      %00010000
.COLLISION_POINTS1 =    %00100000
.COLLISION_POINTS2 =    %01000000
    
    lda #$43
    sta SPRITE_POINTERS + 0
    lda ENABLE_SPRITES
    ora %00000001
    sta ENABLE_SPRITES
    
    lda #185
    sta .PlayerX 
    lda #234
    sta .PlayerY
    
    lda .MV_RT
    sta PL_DIR
    
    lda #$18
    sta X_OFFSET

    rts

;--------------------------------------------------------
;--Player controll and display routines 
;--------------------------------------------------------
PlayerUpdate:

    jsr ReadJoystick 

GoUp:
    lda PL_DIR
    cmp .MV_UP 
    bne GoDown 
   
    lda #$40
    sta SPRITE_POINTERS + 0
    
    jsr CheckMoveUp
    bne C_UP 

    dec .PlayerY
    lda PL_TURBO
    cmp .Turbo 
    bne GoDown
     
    dec .PlayerY
    jmp End

C_UP:
    lda .PlayerY 
    and #$f8
	ora #$02
    sta .PlayerY
	
    jsr CheckMoveLeft
    bne +
    lda .MV_LT
    sta PL_DIR
    jmp GoLeft
+
    jsr CheckMoveRight
    bne +
    lda .MV_RT
    sta PL_DIR
    jmp GoRight
+   

GoDown:
    lda PL_DIR
    cmp .MV_DN
    bne GoLeft
    
    lda #$41
    sta SPRITE_POINTERS + 0
    
    jsr CheckMoveDown
    bne C_DN 

    inc .PlayerY
    lda PL_TURBO
    cmp .Turbo 
    bne GoLeft 
    
    inc .PlayerY
    jmp End

C_DN:
    lda .PlayerY 
	and #$f8
	ora #$02
	sta .PlayerY 

    jsr CheckMoveLeft
    bne +
    lda .MV_LT
    sta PL_DIR
    jmp GoLeft
+
    jsr CheckMoveRight
    bne +
    lda .MV_RT
    sta PL_DIR
    jmp GoRight
+   
    jmp End

GoLeft:    
    lda PL_DIR
    cmp .MV_LT
    bne GoRight
    
    lda #$42
    sta SPRITE_POINTERS + 0
    
    jsr CheckMoveLeft
    bne C_LT

    clc
    lda PL_TURBO
    cmp .Turbo 
    bne NoTurbo0
    
    lda .PlayerX
    sec
    sbc #02
    sta .PlayerX
    bcs GoRight
    jmp SetMSB0

NoTurbo0:
    lda .PlayerX
    sec
    sbc #$01
    sta .PlayerX
    bcs GoRight 

SetMSB0:
    lda #%00000001
    eor #%11111111
    and .PlayerX + 1
    sta SPRITE_MSB
    
    jmp End 

C_LT:
    lda .PlayerX
    sec
    sbc #$02
    and #$f8
    clc
    adc #$08
    sta .PlayerX
    
    jsr CheckMoveUp
    bne +
    lda .MV_UP
    sta PL_DIR
    jmp GoUp
+
    jsr CheckMoveDown
    bne +
    lda .MV_DN
    sta PL_DIR
    jmp GoDown
+
    jmp End

GoRight: 
    lda PL_DIR
    cmp .MV_RT
    bne End
    
    lda #$43
    sta SPRITE_POINTERS + 0
    
    jsr CheckMoveRight
    bne C_RT 
    
    clc
    lda PL_TURBO
    cmp .Turbo 
    bne NoTurbo1 
    
    lda .PlayerX
    adc #$01
    sta .PlayerX
    bcc End 
    jmp SetMSB1

NoTurbo1:
    lda .PlayerX
    adc #$01
    sta .PlayerX
    bcc End 

SetMSB1:    
    lda #%00000001
    ora .PlayerX + 1
    sta .PlayerX + 1
    sta SPRITE_MSB
    jmp End 

C_RT:
    lda .PlayerX 
    sec
    sbc #$02
    and #$f8
    clc
    adc #$08
    sta .PlayerX
    
    jsr CheckMoveUp
    bne +
    lda .MV_UP
    sta PL_DIR
    jmp GoUp
+
    jsr CheckMoveDown
    bne +
    lda .MV_DN
    sta PL_DIR
    jmp GoDown
+

End:
    lda .PlayerX
    sta PL_X 
    lda .PlayerY
    sta PL_Y
    
    rts
;--------------------------------------------------------
;--Read joystick and store direction    
;--------------------------------------------------------
ReadJoystick:

    lda JOY_P_2
    sta JOY_ZP

Up:
    lda JOY_ZP
    and #.JOY_UP
    bne Down
    jsr CheckMoveUp
    bne Turbo
    dec .PlayerY

Down:
    lda JOY_ZP
    and #.JOY_DN
    bne Left
    jsr CheckMoveDown
    bne Turbo
    inc .PlayerY

Left:
    lda JOY_ZP
    and #.JOY_LT
    bne Right
    jsr CheckMoveLeft
    bne Turbo
    
    lda .PlayerX
    sec
    sbc #01
    sta .PlayerX
    bcs Right
    
    lda #%00000001
    eor #%11111111
    and .PlayerX + 1
    sta SPRITE_MSB
 
    ;lda .MV_LT
    ;sta PL_DIR

Right:
    lda JOY_ZP
    and #.JOY_RT
    bne Turbo
    jsr CheckMoveRight
    bne Turbo
  
    lda .PlayerX
    clc
    adc #$01
    sta .PlayerX
    bcc Turbo 

    lda #%00000001
    ora .PlayerX + 1
    sta .PlayerX + 1
    sta SPRITE_MSB
    
    ;lda .MV_RT
    ;sta PL_DIR

Turbo:    
    lda JOY_P_2
    and #.JOY_FR
    bne TurboOff 
    lda .Turbo
    sta PL_TURBO
    rts

TurboOff:
    lda #$00
    sta PL_TURBO
    
    rts

;--------------------------------------------------------
;--Check forward collision for each direction
;--------------------------------------------------------
CheckMoveUp:
    lda X_BORDER_OFFSET
    sec 
    sbc #7
    sta X_OFFSET
    
    lda Y_BORDER_OFFSET
    clc
    adc #1
    sta Y_OFFSET
    
    jsr GetCollisionPoint 
    jsr GetCharacter
    tax
    lda CHAR_COLORS, x
    sta TEMP4
    
    lda X_BORDER_OFFSET
    sta X_OFFSET
    
    lda Y_BORDER_OFFSET
    clc
    adc #1
    sta Y_OFFSET

    jsr GetCollisionPoint
    jsr GetCharacter
    tax
    lda CHAR_COLORS, x
    ora TEMP4
    and #$f0
    and #.COLLISION_SOLID

    rts

CheckMoveDown:
    lda X_BORDER_OFFSET
    sec
    sbc #7
    sta X_OFFSET
    
    lda Y_BORDER_OFFSET
    sec
    sbc #8
    sta Y_OFFSET
    
    jsr GetCollisionPoint
    jsr GetCharacter
    tax
    lda CHAR_COLORS, x
    sta TEMP4 
    
    lda X_BORDER_OFFSET
    sta X_OFFSET
    
    lda Y_BORDER_OFFSET
    sec
    sbc #8
    sta Y_OFFSET

    jsr GetCollisionPoint 
    jsr GetCharacter
    tax
    lda CHAR_COLORS, x
    ora TEMP4
    and #$f0
    and #.COLLISION_SOLID 
    
    rts

CheckMoveLeft:
    lda X_BORDER_OFFSET
    clc
    adc #1
    sta X_OFFSET
    
    lda Y_BORDER_OFFSET
    sta Y_OFFSET
    
    jsr GetCollisionPoint 
    jsr GetCharacter
    tax
    lda CHAR_COLORS, x
    sta TEMP4
    
    lda X_BORDER_OFFSET
    clc
    adc #1
    sta X_OFFSET
    
    lda Y_BORDER_OFFSET
    sec
    sbc #7
    sta Y_OFFSET

    jsr GetCollisionPoint
    jsr GetCharacter
    tax
    lda CHAR_COLORS, x
    ora TEMP4
    and #$f0
    and #.COLLISION_SOLID

    rts

CheckMoveRight:
    lda X_BORDER_OFFSET
    sec
    sbc #8
    sta X_OFFSET
    
    lda Y_BORDER_OFFSET
    sta Y_OFFSET
    
    jsr GetCollisionPoint
    jsr GetCharacter
    tax
    lda CHAR_COLORS, x
    sta TEMP4 
    
    lda X_BORDER_OFFSET
    sec
    sbc #8
    sta X_OFFSET
    
    lda Y_BORDER_OFFSET
    sec
    sbc #7
    sta Y_OFFSET

    jsr GetCollisionPoint 
    jsr GetCharacter
    tax
    lda CHAR_COLORS, x
    ora TEMP4
    and #$f0
    and #.COLLISION_SOLID

    rts

;--------------------------------------------------------
;--Read character at player position              
;--------------------------------------------------------
GetCharacter:
.COLLISION_LOOKUP = TEMP1
    ; X register - character X position
    ; Y register - character Y position

    ;---ldy COLLISION_Y---DEBUG
    
    lda ScreenRowLSB, y
    sta .COLLISION_LOOKUP
    lda ScreenRowMSB, y
    sta .COLLISION_LOOKUP + 1

    ;DEBUG----------------------
    ;ldy COLLISION_X
    ;lda #$7
    ;sta (.COLLISION_LOOKUP), y
    ;---------------------------
    
    txa
    tay
    lda (.COLLISION_LOOKUP), y ; Return character in Accumulator
   
    rts 

;--------------------------------------------------------
;--Get player character cordinates      
;--------------------------------------------------------
GetCollisionPoint:
    
    lda .PlayerX
    sec
    sbc X_OFFSET 
    sta TEMP5
    
    lda SPRITE_MSB
    sbc #00
    lsr
    lda TEMP5
    ror
    lsr
    lsr
    tax                     ; Return position X in X register
    
    lda .PlayerY
    cmp Y_BORDER_OFFSET
    bcs +
    lda Y_BORDER_OFFSET
+
    sec
    sbc Y_OFFSET
    lsr
    lsr
    lsr
    tay                     ; Return position Y in Y register
    
    rts

}
