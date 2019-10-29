;--------------------------------------------------------
;--Main game draw map and menu routines                    
;--------------------------------------------------------
!zone SCREEN {

;--------------------------------------------------------
;--Clear the visible screen routine     
;--------------------------------------------------------
ClearScreen:

    lda #$00
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
    
    ldy #250            ; Our map data is loaded to $8000 location. See "assets.asm
-                       ; Loop through Map bytes and store them in Screen RAM
    lda MAP, y          ; This is currently drawing map from 4 locations on screen
    tax                 ; and setting right colors for characters. I will later 
    sta SCREEN_RAM, y   ; change this code to be self modifying.
    lda CHAR_COLORS, x
    sta COLOR_RAM, y 
    lda MAP + 250, y 
    tax
    sta SCREEN_RAM + 250, y
    lda CHAR_COLORS, x
    sta COLOR_RAM + 250, y
    lda MAP + 500, y
    tax
    sta SCREEN_RAM + 500, y
    lda CHAR_COLORS, x
    sta COLOR_RAM + 500, y
    lda MAP + 750, y
    tax
    sta SCREEN_RAM + 750, y
    lda CHAR_COLORS, x
    sta COLOR_RAM + 750, y
    dey
    bne -
    
    rts

}


