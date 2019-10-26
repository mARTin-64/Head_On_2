!zone Collision {
;--------------------------------------------------------
;--Collect points, update score and game state
;--------------------------------------------------------
CheckScorePoints:
    ldx #OFFSET_XL - 4
    ldy #OFFSET_YU - 4
    
    jsr GetCollisionPoint 
    jsr GetCharacter
    tax
    lda CHAR_COLORS, x
    and #$f0
    and #(POINT_5 + POINT_25)
    sta POINT_TYPE
    bne +
    rts    
+
    ldy COLLISION_X
    lda #$00
    sta (COLLISION_LOOKUP), y
    
    jsr UpdateScore 
    
    inc POINT_COUNTER 
    lda POINT_COUNTER
    cmp #108
    beq +
    
    rts
+
    lda #VICTORY
    sta GAME_STATE
    
    rts

;--------------------------------------------------------
;--Check forward collision for each direction
;--------------------------------------------------------
CheckMoveUp:
    ldx #OFFSET_XR
    ldy #OFFSET_YDU
    
    lda CheckZone 
    bne +
    lda PL_DIR
    cmp MV_RT
    beq +
    dex
+
    lda CheckSnap
    bne +
    dex
+   
    jsr GetCollisionPoint 
    jsr GetCharacter
    tax
    lda CHAR_COLORS, x
    sta TEMP4
    
    ldx #OFFSET_XL
    ldy #OFFSET_YDU
    
    lda CheckZone 
    bne +
    lda PL_DIR
    cmp MV_LT
    beq +
    inx
+
    lda CheckSnap
    bne +
    inx
    lda #YES
    sta CheckSnap
+  
    lda #YES
    sta CheckZone

    jsr GetCollisionPoint
    jsr GetCharacter
    tax
    lda CHAR_COLORS, x
    ora TEMP4
    and #$f0
    and #SOLID

    rts

CheckMoveDown:
    ldx #OFFSET_XL
    ldy #OFFSET_YDD
    
    lda CheckZone
    bne +
    lda PL_DIR
    cmp MV_LT
    beq +
    inx
+    
    lda CheckSnap
    bne +
    inx
    iny
+ 
    jsr GetCollisionPoint
    jsr GetCharacter
    tax
    lda CHAR_COLORS, x
    sta TEMP4 

    ldx #OFFSET_XR
    ldy #OFFSET_YDD
    
    lda CheckZone
    bne +
    lda PL_DIR
    cmp MV_RT
    beq +
    dex
+ 
    lda CheckSnap
    bne +
    dex
    iny
    lda #YES
    sta CheckSnap
+   
    lda #YES
    sta CheckZone

    jsr GetCollisionPoint 
    jsr GetCharacter
    tax
    lda CHAR_COLORS, x
    ora TEMP4
    and #$f0
    and #SOLID 
     
    rts

CheckMoveLeft:
    ldx #OFFSET_XDL
    ldy #OFFSET_YU
    
    lda CheckZone
    bne +
    iny
+
    lda CheckSnap
    bne +
    dex
    iny
+  
    jsr GetCollisionPoint 
    jsr GetCharacter
    tax
    lda CHAR_COLORS, x
    sta TEMP4
    
    ldx #OFFSET_XDL
    ldy #OFFSET_YD

    lda CheckZone
    bne +
    dey
+
    lda CheckSnap
    bne +
    dex
    dey
    lda #YES
    sta CheckSnap
+  
    lda #YES
    sta CheckZone

    jsr GetCollisionPoint
    jsr GetCharacter
    tax
    lda CHAR_COLORS, x
    ora TEMP4
    and #$f0
    and #SOLID
   
    rts

CheckMoveRight:
    ldx #OFFSET_XDR
    ldy #OFFSET_YU
   
    lda CheckZone
    bne +
    iny
+
    lda CheckSnap
    bne +
    iny
+
    jsr GetCollisionPoint
    jsr GetCharacter
    tax
    lda CHAR_COLORS, x
    sta TEMP4 
    
    ldx #OFFSET_XDR
    ldy #OFFSET_YD
    
    lda CheckZone
    bne +
    dey
+
    lda CheckSnap
    bne +
    dey
    lda #YES
    sta CheckSnap
+
    lda #YES
    sta CheckZone

    jsr GetCollisionPoint 
    jsr GetCharacter
    tax
    lda CHAR_COLORS, x
    ora TEMP4
    and #$f0
    and #SOLID
   
    rts 

;--------------------------------------------------------
;--Read character at player position              
;--------------------------------------------------------
GetCharacter:
    ; X register - character X position
    ; Y register - character Y position

    ;---ldy COLLISION_Y---DEBUG
    
    lda ScreenRowLSB, y
    sta COLLISION_LOOKUP
    lda ScreenRowMSB, y
    sta COLLISION_LOOKUP + 1

    ;DEBUG----------------------
    ;ldy COLLISION_X
    ;lda #$7
    ;sta (.COLLISION_LOOKUP), y
    ;---------------------------
    
    txa
    tay
    lda (COLLISION_LOOKUP), y ; Return character in Accumulator
   
    rts 

;--------------------------------------------------------
;--Get player character cordinates      
;--------------------------------------------------------
GetCollisionPoint:
; Store Loaded X and Y positions from X and Y registers

ENTITY_POSITION = TEMP1
Entity_X = POINTER1
Entity_Y = POINTER2
Entity_MSB = POINTER3

    stx X_OFFSET
    sty Y_OFFSET

    lda ENTITY_TO_UPDATE 
    cmp #PLAYER_ACTIVE
    bne +

SetupPlayer:
    lda Player_X
    sta Entity_X
    lda Player_Y
    sta Entity_Y
    lda Player_MSB
    sta Entity_MSB

    jmp SetupComplete
+
    jsr SetupEntity

SetupComplete:
    lda Entity_X
    sec
    sbc X_OFFSET 
    sta ENTITY_POSITION
    
    lda Entity_MSB
    sbc #00
    lsr
    lda ENTITY_POSITION 
    ror
    lsr
    lsr
    tax                     ; Return position X in X register
    stx COLLISION_X

    lda Entity_Y
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
    sty COLLISION_Y

    rts

;--------------------------------------------------------
;--Snap Player moving Up   
;--------------------------------------------------------
SnapUpDown: 
    lda #NO
    sta CheckSnap
    jsr CheckMoveLeft
    sta FreeZoneLeft

    lda #NO
    sta CheckSnap
    jsr CheckMoveRight
    and FreeZoneLeft
    bne ++ 
    
    lda FreeZoneLeft
    bne +
 
    lda Player_X
    sec
    sbc #$08
    and #$f8
    clc
    adc #$08
    sta Player_X
    lda #$01

    rts
+
    lda Player_X
    clc
    adc #$08
    and #$f8
    sta Player_X
    lda #$01
   
    rts

++:
    
    lda Player_Y 
    and #$f8
    ora #$02
    sta Player_Y
    lda #$00 
    
    rts

SnapLeftRight:
    lda #NO
    sta CheckSnap
    jsr CheckMoveDown
    sta FreeZoneDown
    
    lda #NO
    sta CheckSnap
    jsr CheckMoveUp
    and FreeZoneDown
    bne ++ 
    
    lda FreeZoneDown
    bne +

    lda Player_Y 
    clc
    adc #$03
    and #$f8
    ora #$2
    sta Player_Y
    lda #$01 
    
    rts  
+
    lda Player_Y 
    sec
    sbc #$03
    and #$f8
    ora #$2
    sta Player_Y
    lda #$01 
 
    rts

++:
    lda Player_X
    sec
    sbc #$02
    and #$f8
    clc
    adc #$08
    sta Player_X
    lda #$00 
    
    rts

;--------------------------------------------------------
;--Setup current entity  
;--------------------------------------------------------
SetupEntity:
    ldy CurrentEnemy

Spr0:    
    lda (ENEMY_X), y
    sta Entity_X
    lda (EN_MSB), y
    lsr
    sta Entity_MSB

Rest:    
    lda (ENEMY_Y), y
    sta Entity_Y


UpdateNext:
    iny
    cpy ACTIVE_ENEMYES
    bcs +
    rts
+   
    ldy #$00
    sty CurrentEnemy
    rts
}

