;--------------------------------------------------------
;--Main game routines                    
;--------------------------------------------------------

!zone SCREEN {

;--------------------------------------------------------
;--Clear the visible screen routine     
;--------------------------------------------------------
ClearScreen1:

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

.CHECK_LT = %0100
.CHECK_RT = %1000
.CHECK_UP = %0001
.CHECK_DN = %0010

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
    
    ;lda .MV_RT
    ;sta PL_DIR
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
    lda PlayerUpCollision
    and #.COLLISION_SOLID
    bne CheckSide0 

    dec .PlayerY
    lda PL_TURBO
    cmp .Turbo 
    bne GoDown
   
    dec .PlayerY
    jmp End

CheckSide0:
    jsr CheckSideLeft
    bne +
    lda .MV_LT
    sta PL_DIR
+
    jsr CheckSideRight
    bne +
    lda .MV_RT
    sta PL_DIR
+   

GoDown:
    lda PL_DIR
    cmp .MV_DN
    bne GoLeft
    
    lda #$41
    sta SPRITE_POINTERS + 0
    
    jsr CheckMoveDown
    lda PlayerDownCollision
    and #.COLLISION_SOLID
    bne CheckSide1 

    inc .PlayerY
    lda PL_TURBO
    cmp .Turbo 
    bne GoLeft 
    
    inc .PlayerY
    jmp End

CheckSide1:
    jsr CheckSideLeft
    bne +
    lda .MV_LT
    sta PL_DIR
+
    jsr CheckSideRight
    bne +
    lda .MV_RT
    sta PL_DIR
+   
    jmp End

GoLeft:    
    lda PL_DIR
    cmp .MV_LT
    bne GoRight
    
    lda #$42
    sta SPRITE_POINTERS + 0
    
    jsr CheckMoveLeft
    lda PlayerLeftCollision
    and #.COLLISION_SOLID
    bne CheckSide2
    
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
    bcs End 

SetMSB0:
    lda #%00000001
    eor #%11111111
    and .PlayerX + 1
    sta SPRITE_MSB
    
    jmp End 

CheckSide2:
    jsr CheckSideUp
    bne +
    lda .MV_UP
    sta PL_DIR
+
    jsr CheckSideDown
    bne +
    lda .MV_DN
    sta PL_DIR
+
    jmp End

GoRight: 
    lda PL_DIR
    cmp .MV_RT
    bne End
    
    lda #$43
    sta SPRITE_POINTERS + 0
    
    jsr CheckMoveRight
    lda PlayerRightCollision 
    and #.COLLISION_SOLID
    bne CheckSide3 
    
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

CheckSide3:
    jsr CheckSideUp
    bne +
    lda .MV_UP
    sta PL_DIR
+
    jsr CheckSideDown
    bne +
    lda .MV_DN
    sta PL_DIR
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
    lda .MV_UP
    sta PL_DIR

Down:
    lda JOY_ZP
    and #.JOY_DN
    bne Left
    lda .MV_DN
    sta PL_DIR

Left:
    lda JOY_ZP
    and #.JOY_LT
    bne Right
    lda .MV_LT
    sta PL_DIR

Right:
    lda JOY_ZP
    and #.JOY_RT
    bne Turbo
    lda .MV_RT
    sta PL_DIR

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
    sta PlayerRightCollision
    
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
    ora PlayerRightCollision
    and #$f0
    sta PlayerRightCollision

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
    sta PlayerLeftCollision
    
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
    ora PlayerLeftCollision
    and #$f0
    sta PlayerLeftCollision

    rts

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
    sta PlayerUpCollision
    
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
    ora PlayerUpCollision
    and #$f0
    sta PlayerUpCollision

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
    sta PlayerDownCollision
    
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
    ora PlayerDownCollision
    and #$f0
    sta PlayerDownCollision
    
    rts

CheckSideUp:
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
    sta TEMP3
    
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
    ora TEMP3
    and #$f0
    and #.COLLISION_SOLID
    bne +
    rts
+
    lda .CHECK_UP
    ;sta PlayerUpSide
    
    rts

CheckSideDown:
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
    sta TEMP3
    
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
    ora TEMP3
    and #$f0
    and #.COLLISION_SOLID
    bne +
    rts
+
    lda .CHECK_DN
    ;sta PlayerDownSide
    
    rts

CheckSideLeft:
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
    sta TEMP3
   
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
    ora TEMP3
    and #$f0
    and #.COLLISION_SOLID
    bne +
    rts
+
    lda .CHECK_LT
    ;sta PlayerDownSide
    
    rts

CheckSideRight:
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
    sta TEMP3
 
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
    ora TEMP3
    and #$f0
    and #.COLLISION_SOLID
    bne +
    rts
+
    lda .CHECK_RT
    ;sta PlayerDownSide
    
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
