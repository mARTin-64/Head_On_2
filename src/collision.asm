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
    lda #YES
    sta CheckZone

    jsr GetCollisionPoint
    jsr GetCharacter
    tax
    lda CHAR_COLORS, x
    ora TEMP4
    and #$f0
    and #COLLISION_SOLID

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
    lda #YES
    sta CheckZone
    
    jsr GetCollisionPoint 
    jsr GetCharacter
    tax
    lda CHAR_COLORS, x
    ora TEMP4
    and #$f0
    and #COLLISION_SOLID 
     
    rts

CheckMoveLeft:
    ldx #OFFSET_XDL
    ldy #OFFSET_YU
    
    lda CheckZone
    bne +
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
    lda #YES
    sta CheckZone

    jsr GetCollisionPoint
    jsr GetCharacter
    tax
    lda CHAR_COLORS, x
    ora TEMP4
    and #$f0
    and #COLLISION_SOLID
   
    rts

CheckMoveRight:
    ldx #OFFSET_XDR
    ldy #OFFSET_YU
    
    lda CheckZone
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
    lda #YES
    sta CheckZone

    jsr GetCollisionPoint 
    jsr GetCharacter
    tax
    lda CHAR_COLORS, x
    ora TEMP4
    and #$f0
    and #COLLISION_SOLID
   
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
ENTITY_X = POINTER1
ENTITY_Y = POINTER2
    
    stx X_OFFSET
    sty Y_OFFSET

    cmp #$00
    bne SetupEntity1

SetupEntity0:
    lda PlayerX
    sta ENTITY_X
    lda PlayerY
    sta ENTITY_Y
    jmp SetupComplete

SetupEntity1:
    lda Enemy0_X
    sta ENTITY_X
    lda Enemy0_Y
    sta ENTITY_Y

SetupComplete:
    lda PlayerX
    sec
    sbc X_OFFSET 
    sta ENTITY_POSITION
    
    lda SPRITE_MSB
    sbc #00
    lsr
    lda ENTITY_POSITION 
    ror
    lsr
    lsr
    tax                     ; Return position X in X register
    stx COLLISION_X

    lda PlayerY
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

}

