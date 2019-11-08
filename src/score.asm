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
    sty COUNTER
    sty MILISEC
    sty SECONDS

.Loop_Bonus
    ldx #$00  
    sty TEMP1

.Add_10
        
    stx TEMP3
    jsr DrawBonusLogo 
    ldx TEMP3
-    
    lda CODE_FLAG
    beq -
    dec CODE_FLAG
    
    jsr Timer
    lda COUNTER  
    and #$07
    bne -
    
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
    
    stx TEMP2
    jsr ScoreDisplay
    jsr ClearBonusLogo
-    
    lda CODE_FLAG
    beq -
    dec CODE_FLAG
    
    jsr Timer
    lda COUNTER 
    and #$03
    bne - 
    
    ldx TEMP2
    inx
    cpx #10
    beq + 
    jmp .Add_10
+
    ldy TEMP1
    iny 
    cpy Bonus
    
    bne .Loop_Bonus
    jsr DrawBonusLogo 
    lda #$00
    sta COUNTER
    sta MILISEC
    sta SECONDS
-
    lda CODE_FLAG
    beq -
    dec CODE_FLAG
    
    jsr Timer
    lda SECONDS
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




