;--------------------------------------------------------
;--Draw player score on screen
;--------------------------------------------------------
!zone Score {
UpdateScore:
    sed
    
    lda Value_Small 
    sta POINT_VALUE

    lda POINT_TYPE
    and #POINT_SMALL
    clc
    bne + 
    lda Value_Big
    sta POINT_VALUE

;-----Set carry if Value_Big + 1 is not 0
    clc
    lda Value_Big + 1
    beq +
    sec
+
    lda Score
    adc POINT_VALUE
    sta Score
    lda Score + 1
    adc #0
    sta Score + 1
    lda Score + 2
    adc #0
    sta Score + 2
    
    cld
    
    jsr ScoreDisplay
    
    rts

AddBonus:
    ldx #$00
-
    lda #$00
    sta PL_DIR
    sta Enemy_Dir, x
    inx 
    cpx ACTIVE_ENEMIES
    bne -

    ldy #$00

.Loop_Bonus
    ldx #$00  
    tya
    pha

.Add_10
    +GetRaster($ff)
    inc COUNTER
    lda COUNTER
    and #$1f
    bne .Add_10
    
    sed
    
    lda Score
    clc
    adc #10
    sta Score
    lda Score + 1
    adc #0
    sta Score + 1
    lda Score + 2
    adc #0
    sta Score + 2
     
    cld
    
    txa
    pha
    jsr ScoreDisplay
    pla
    tax
    inx
    cpx #10
    beq + 
    jmp .Add_10
+
    pla
    tay
    iny 
    cpy Bonus
    bne .Loop_Bonus
    lda #$00
    sta COUNTER + 1
-
    +GetRaster($ff)
    jsr Timer
    lda COUNTER + 1
    cmp #$02
    bne -

    rts

ScoreDisplay:
    ldy #22      ; Screen offset
    ldx #0      ; Score byte index

-    
    lda Score, x
    pha
    and #$0f
    jsr ShowDigit
    
    pla
    lsr
    lsr
    lsr
    lsr
    jsr ShowDigit
    
    inx
    cpx #3
    bne -

    rts

ShowDigit:
    clc
    adc #10
    sta SCREEN_RAM + 600, y
    lda #$01
    sta COLOR_RAM + 600, y
    dey
    
    rts
}
