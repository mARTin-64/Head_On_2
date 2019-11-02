;--------------------------------------------------------
;--Draw player score on screen
;--------------------------------------------------------
!zone Score {
UpdateScore:
    sed
    
    lda Value_Small 
    sta POINT_VALUE

    lda POINT_TYPE
    and #POINT_5
    bne + 
    lda Value_Big
    sta POINT_VALUE
+
    clc
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
