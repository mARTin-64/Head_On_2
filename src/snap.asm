;--------------------------------------------------------
;--Snap Player on collision in free zone   
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
;--Snap Enemy on collision in freezone   
;--------------------------------------------------------
ESnapUpDown: 
    lda #NO
    sta CheckSnap
    jsr CheckMoveLeft
    sta FreeZoneLeft

    lda #NO
    sta CheckSnap
    jsr CheckMoveRight
    and FreeZoneLeft
    bne ++ 
    
    ldx CurrentEnemy 
    lda FreeZoneLeft
    bne +
    lda Enemy_X, x
    sec
    sbc #$08
    and #$f8
    clc
    adc #$08
    sta Enemy_X, x
    lda #$01

    rts
+
    lda Enemy_X, x
    clc
    adc #$08
    and #$f8
    sta Enemy_X, x
    lda #$01
   
    rts

++:
    ldx CurrentEnemy
    lda Enemy_Y, x 
    and #$f8
    ora #$02
    sta Enemy_Y, x
    lda #$00 
    
    rts

ESnapLeftRight:
    lda #NO
    sta CheckSnap
    jsr CheckMoveDown
    sta FreeZoneDown
    
    lda #NO
    sta CheckSnap
    jsr CheckMoveUp
    and FreeZoneDown
    bne ++ 
    
    ldx CurrentEnemy 
    lda FreeZoneDown
    bne +

    lda Enemy_Y, x
    clc
    adc #$03
    and #$f8
    ora #$2
    sta Enemy_Y, x
    lda #$01 
    
    rts  
+
    lda Enemy_Y, x
    sec
    sbc #$03
    and #$f8
    ora #$2
    sta Enemy_Y, x
    lda #$01 
 
    rts

++:
    ldx CurrentEnemy
    lda Enemy_X, x
    sec
    sbc #$02
    and #$f8
    clc
    adc #$08
    sta Enemy_X, x
    lda #$00 
    
    rts

