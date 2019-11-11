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
DrawGame:
.Row    = TEMP5
    
    lda #$00
    sta .Row
    
    lda #<SCREEN_RAM
    sta Screen + 1 
    sta Color + 1

    lda #>SCREEN_RAM
    sta Screen + 2
    lda #>COLOR_RAM
    sta Color + 2

    lda GAME_STATE
    cmp #MAIN_MENU
    bne +
    lda #<START_MENU
    sta Data + 1
    lda #>START_MENU
    sta Data + 2
    
    jmp Done
+
    cmp #BONUS_SCR
    bne +
    jmp BonusScreen
    
+    
    cmp #PLAY
    bne +    
    lda #<MAP
    sta Data + 1
    lda #>MAP
    sta Data + 2

Done:
    ldy #00 
-   
Data:
    lda $B00B, y   
    tax
Screen:    
    sta $B00B, y
    lda CHAR_COLORS, x
Color:
    sta $B00B, y
    iny
    cpy #40
    bne Data
    
    ; INCREASE TILE LOCATION
    clc
    lda Data + 1
    adc #$28
    sta Data + 1
    lda Data + 2
    adc #$00
    sta Data + 2
    
    ; INCREASE SCREEN AND COLOR RAM LOCATIONS
    clc
    lda Screen + 1
    adc #$28
    sta Screen + 1
    sta Color  + 1
    bcc +
    inc Screen + 2 
    inc Color  + 2
+
    inc .Row
    ldx .Row
    cpx #25
    bne Done

    rts

DrawLives:
    lda PlayerLives
    cmp #$01
    bne +
    rts
+
    ldy #$01
-    
    lda #$07
    sta SCREEN_RAM + 536, y
    tax
    lda CHAR_COLORS, x
    sta COLOR_RAM + 536, y

    iny
    cpy PlayerLives
    bne -
    
    rts

BonusScreen:
;-----BONUS SIGN 
    ldy #$00
-    
    lda BONUS_SCREEN, y
    sta SCREEN_RAM + 377, y
    tax
    lda CHAR_COLORS, x
    sta COLOR_RAM + 377, y
    
    lda BONUS_SCREEN + 10, y
    sta SCREEN_RAM + 417, y
    tax
    lda CHAR_COLORS, x
    sta COLOR_RAM + 417, y

;-----BONUS TEXT
    lda BONUS_SCREEN + 20, y
    sta SCREEN_RAM + 611, y
    sta SCREEN_RAM + 691, y
    tax
    lda CHAR_COLORS, x
    sta COLOR_RAM + 611, y
    sta COLOR_RAM + 691, y
    
    iny
    cpy #$0a
    bne -

;-----BONUS NUMBER
    lda Bonus
    clc 
    adc #10
    sta SCREEN_RAM + 459
    lda #10
    sta SCREEN_RAM + 460
    sta SCREEN_RAM + 461
    
    lda #$07 
    sta COLOR_RAM + 459
    sta COLOR_RAM + 460
    sta COLOR_RAM + 461

;-----POINTS PER (dots and value)
    ldy #$00
-    
    lda #$08
    sta SCREEN_RAM + 622, y
    tax
    lda CHAR_COLORS, x 
    sta COLOR_RAM + 622, y

    lda #$09
    sta SCREEN_RAM + 702, y
    tax
    lda CHAR_COLORS, x
    sta COLOR_RAM + 702, y 
    
    iny
    cpy #$03
    bne -

;-----EQUAL SIGN
    lda #46
    sta SCREEN_RAM + 626
    sta SCREEN_RAM + 706
    tax
    lda CHAR_COLORS, x
    sta COLOR_RAM + 626
    sta COLOR_RAM + 706

;-----Display values 
    ldy #$00
    
    lda Value_Small
    pha
    lsr
    lsr
    lsr
    lsr
    beq +
    jsr ShowValue
+
    pla
    and #$0f
    jsr ShowValue
    
    ldy #80

    lda Value_Big + 1
    beq +
    jsr ShowValue
+    
    sed
    lda Value_Big
    clc
    adc Value_Big + 1 
    cld
    pha
    lsr
    lsr
    lsr
    lsr
    jsr ShowValue
    pla
    and #$0f
    jsr ShowValue
    
    rts

ShowValue:
    clc
    adc #10
    sta SCREEN_RAM + 628, y
    tax
    lda CHAR_COLORS, x
    sta COLOR_RAM + 628, y
    iny
    
    rts

DrawBonusLogo:
    ldy #$00
-    
    lda BONUS_SCREEN, y
    sta SCREEN_RAM + 377, y
    tax
    lda CHAR_COLORS, x
    sta COLOR_RAM + 377, y
    
    lda BONUS_SCREEN + 10, y
    sta SCREEN_RAM + 417, y
    tax
    lda CHAR_COLORS, x
    sta COLOR_RAM + 417, y
       
    iny
    cpy #$06
    bne -

;-----BONUS NUMBER
    lda Bonus
    clc 
    adc #10
    sta SCREEN_RAM + 459
    lda #10
    sta SCREEN_RAM + 460
    sta SCREEN_RAM + 461
    lda #$07 
    sta COLOR_RAM + 459
    sta COLOR_RAM + 460
    sta COLOR_RAM + 461
   
    rts

ClearBonusLogo:
    ldy #$00
-    
    lda #$00
    sta SCREEN_RAM + 377, y
    sta SCREEN_RAM + 417, y
    sta SCREEN_RAM + 457, y
    iny
    cpy #$06
    bne -
    rts

DrawGameOver:
;-----Redraw map
    lda #PLAY
    sta GAME_STATE
    jsr DrawGame
    lda #LOOSE
    sta GAME_STATE

;-----Draw text (GAME OVER)    
    ldy #$00
-   
    lda BONUS_SCREEN + 30, y
    sta SCREEN_RAM + 378, y
    tax
    lda CHAR_COLORS, x
    sta COLOR_RAM + 378, y

    lda BONUS_SCREEN + 40, y
    sta SCREEN_RAM + 418, y
    tax
    lda CHAR_COLORS, x
    sta COLOR_RAM + 418, y

    iny 
    cpy #$04
    bne -

;-----Draw scores
    jsr DrawScore1
    jsr DrawScore2
    jsr DrawScore3
    jsr DrawHighScore
    inc Enable_Blink
-    
    jsr ReadKey 
    lda GAME_STATE
    cmp #BONUS_SCR
    bne -
    
    dec Enable_Blink
    
    rts

DrawScore1:
    ldy #22
    ldx #0

-    
    lda Score1, x
    pha
    and #$0f
    jsr DrawDigit1
    
    pla
    lsr
    lsr
    lsr
    lsr
    jsr DrawDigit1
    
    inx
    cpx #3
    bne -

    rts

DrawDigit1:
    clc
    adc #10
    sta SCREEN_RAM + 440, y
    lda #$07
    sta COLOR_RAM + 440, y
    dey
    
    rts

DrawScore2:
    ldy #22
    ldx #0

-    
    lda Score2, x
    pha
    and #$0f
    jsr DrawDigit2
    
    pla
    lsr
    lsr
    lsr
    lsr
    jsr DrawDigit2
    
    inx
    cpx #3
    bne -

    rts

DrawDigit2:
    clc
    adc #10
    sta SCREEN_RAM + 480, y
    lda #$07
    sta COLOR_RAM + 480, y
    dey
    
    rts

DrawScore3:
    ldy #22
    ldx #0

-    
    lda Score3, x
    pha
    and #$0f
    jsr DrawDigit3
    
    pla
    lsr
    lsr
    lsr
    lsr
    jsr DrawDigit3
    
    inx
    cpx #3
    bne -

    rts

DrawDigit3:
    clc
    adc #10
    sta SCREEN_RAM + 520, y
    lda #$07
    sta COLOR_RAM + 520, y
    dey
    
    rts

DrawHighScore:
    ldy #22      ; Screen offset
    ldx #0      ; Score byte index

-    
    lda HighScore, x
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

ClearHighScore:
    ldx #$00
-
    lda #00
    sta SCREEN_RAM + 617, x
    inx
    cpx #$06
    bne -
    
    rts

Explosion_1:
.LoopCounter:   !byte $00, $00
;-----Get the coordinates at player position    
    lda #PLAYER_ACTIVE
    sta ENTITY_TO_UPDATE

    ldx #OFFSET_XR - 1
    
    lda PL_Y
    cmp #234
    bne +
    inc .LoopCounter + 1
    inc .LoopCounter + 1
+  
    ldy #OFFSET_YU 
    jsr GetCollisionPoint

    ldy COLLISION_Y 
    dey

;-----Store coordinates
    lda ScreenRowLSB, y
    sta COLLISION_LOOKUP
    lda ScreenRowMSB, y
    sta COLLISION_LOOKUP + 1
   
    lda ColorRowLSB, y
    sta COLOR_LOOKUP
    lda ColorRowMSB, y
    sta COLOR_LOOKUP + 1

;-----Offset position for animation
    lda COLLISION_X 
    sec
    sbc #$02
    tay

    ldx #$00
    stx TEMPX

;-----Start 1st explosion animation
.loop_small:
    lda EXPLOSION_1, x
    sta (COLLISION_LOOKUP), y 
    stx TEMPX

    tax 
    lda CHAR_COLORS, x
    sta (COLOR_LOOKUP), y
    
    ldx TEMPX
    iny
    inx
    
    inc .LoopCounter
    lda .LoopCounter
    cmp #$04 
    bne .loop_small ;-----Loop 4 columns

;-----Setup new row
    lda #$00
    sta .LoopCounter
    tya
    clc
    adc #$24
    tay
    
    inc .LoopCounter + 1
    lda .LoopCounter + 1
    cmp #$05 
    bne .loop_small ;-----Loop 6 rows

;------Setup color animation
    ldx #$01

.color_setup_1:
    lda PL_Y
    cmp #234
    bne +
    lda #$02
    sta .LoopCounter + 1
    jmp ++
+
    lda #$00
    sta .LoopCounter + 1
++
    lda COLLISION_X
    sec
    sbc #$02
    tay

;-----Loop through colors
.color_change:
    lda CODE_FLAG
    beq .color_change
    dec CODE_FLAG

    dec Color_Timer
    bne .color_change

;-----Rows and columns
.color_loop:
    lda ColorTable, x
    sta (COLOR_LOOKUP), y
    iny
    inc .LoopCounter
    lda .LoopCounter
    cmp #$04  
    bne .color_loop
    
    lda #$00
    sta .LoopCounter
    
    tya
    clc
    adc #$24
    tay
    
    inc .LoopCounter + 1
    lda .LoopCounter + 1
    cmp #$05
    bne .color_loop
   
    lda Color_Timer + 1
    sta Color_Timer
   
    inx
    cpx #$03
    bne .color_setup_1
    
    lda #$00
    sta .LoopCounter
    sta .LoopCounter + 1
 
    lda #$00
    sta Expl_Index
   
    rts
 
Explosion_2:
;-----Get the coordinates at player position    
    lda #PLAYER_ACTIVE
    sta ENTITY_TO_UPDATE
    
    inc Expl_Extend_Flag
;-----Check if player is at top row
    ldx #OFFSET_XL
    lda PL_Y
    cmp #66
    bcs +   ; If not then skip this part
    ldy #OFFSET_YU
    jmp .done2 
+
;-----Get coordinate one row above player
    ldy #(OFFSET_YU + 8) 
    lda PL_Y
    cmp #218
    bcc +
    dec Expl_Extend_Flag
+
    cmp #226    ; If player is at the bottom then else...
    bcc +
    inc .LoopCounter + 1
    dec Expl_Extend_Flag
+  
    cmp #234
    bcc .done2
    inc .LoopCounter + 1

.done2:
    jsr GetCollisionPoint

    ldy COLLISION_Y 
    dey
;-----Store coordinates
    lda ScreenRowLSB, y
    sta COLLISION_LOOKUP
    lda ScreenRowMSB, y
    sta COLLISION_LOOKUP + 1
   
    lda ColorRowLSB, y
    sta COLOR_LOOKUP
    lda ColorRowMSB, y
    sta COLOR_LOOKUP + 1

;-----Get offset player cordinates for extended explosion data
    ldx #OFFSET_XL
    ldy #(OFFSET_YU - 40) 
    
    jsr GetCollisionPoint
    ldy COLLISION_Y
    dey

;-----Store 2nd coordinates
    lda ScreenRowLSB, y
    sta COLLISION_LOOKUP2
    lda ScreenRowMSB, y
    sta COLLISION_LOOKUP2 + 1
   
    lda ColorRowLSB, y
    sta COLOR_LOOKUP2
    lda ColorRowMSB, y
    sta COLOR_LOOKUP2 + 1
     
    ldx #36
    stx TEMPX1

;-----Offset position for animation
    lda COLLISION_X 
    sec
    sbc #$02
    tay

    lda PL_Y
    cmp #66
    bcs +
    ldx #06
    stx TEMPX
    inc .LoopCounter + 1
    jmp .loop_2
+    
    ldx #$00
    stx TEMPX

;-----Start explosion animation
.loop_2:
    lda EXPLOSION_2, x
    sta (COLLISION_LOOKUP), y 
    stx TEMPX

    tax 
    lda CHAR_COLORS, x
    sta (COLOR_LOOKUP), y

;-----Explosion Extended    
    lda Expl_Extend_Flag
    beq +
    ldx TEMPX1
    lda EXPLOSION_2, x
    sta (COLLISION_LOOKUP2), y
    tax
    lda CHAR_COLORS, x
    sta (COLOR_LOOKUP2), y
    ldx TEMPX1
    inx 
    stx TEMPX1
+
    ldx TEMPX
    iny
    inx
    
    inc .LoopCounter
    lda .LoopCounter
    cmp #$06 
    bne .loop_2 ;-----Loop 6 columns

;-----Setup new row
    lda Expl_Extend_Flag
    beq +
    dec Expl_Extend_Flag
+
    lda #$00
    sta .LoopCounter
    tya
    clc
    adc #$22
    tay
    
    inc .LoopCounter + 1
    lda .LoopCounter + 1
    cmp #$06 
    bne .loop_2 ;-----Loop 6 rows

;------Setup color animation
    ldx #$00

.color_setup_2:
    lda #$00
    sta .LoopCounter + 1

    inc Expl_Extend_Flag
    
    lda PL_Y
    cmp #66
    bcs +
    lda #$01
    sta .LoopCounter + 1
    jmp .done_2 
+
    lda PL_Y
    cmp #218
    bcc +
    dec Expl_Extend_Flag
+
    cmp #226
    bcc +
    inc .LoopCounter + 1
    dec Expl_Extend_Flag
+   
    cmp #234
    bcc +
    inc .LoopCounter + 1
+
.done_2:
    lda COLLISION_X
    sec
    sbc #$02
    tay
    
;-----Loop through colors
.color_next_2:
    lda CODE_FLAG
    beq .color_next_2
    dec CODE_FLAG

    dec Color_Timer
    bne .color_next_2
    
.color_loop_2:
    lda ColorTable, x
    sta (COLOR_LOOKUP), y
    lda Expl_Extend_Flag
    beq +
    lda ColorTable, x
    sta (COLOR_LOOKUP2), y
+
    iny
    inc .LoopCounter
    lda .LoopCounter
    cmp #$06 
    bne .color_loop_2
    
    lda #$00
    sta .LoopCounter
    sta Expl_Extend_Flag
    
    tya
    clc
    adc #$22
    tay
    
    inc .LoopCounter + 1
    lda .LoopCounter + 1
    cmp #$06
    bne .color_loop_2
     
    lda Color_Timer + 1
    sta Color_Timer

    inc Expl_Extend_Flag
    inx
    cpx #$03
    beq +
    jmp .color_setup_2
+    
    lda #$00
    sta .LoopCounter
    sta .LoopCounter + 1
    sta Expl_Extend_Flag

    lda Color_Timer + 1
    sta Color_Timer
    
    rts

Explosion_3:
;-----Get the coordinates at player position    
    lda #PLAYER_ACTIVE
    sta ENTITY_TO_UPDATE
    
    inc Expl_Extend_Flag
    inc Expl_Extend_Flag
;-----Check if player is at top row
    ldx #OFFSET_XL
    lda PL_Y
    cmp #66
    bcs +   ; If not then skip this part
    ldy #OFFSET_YU
    jmp .done3 
+
;-----Get coordinate one row above player
    ldy #(OFFSET_YU + 8) 
    
    lda PL_Y
    cmp #210
    bcc +
    dec Expl_Extend_Flag
+
    cmp #218
    bcc +
    dec Expl_Extend_Flag
+
    cmp #226    ; If player is at the bottom then else...
    bcc +
    inc .LoopCounter + 1
    dec Expl_Extend_Flag
+  
    cmp #234
    bcc .done3
    inc .LoopCounter + 1
    dec Expl_Extend_Flag
.done3:
    jsr GetCollisionPoint

    ldy COLLISION_Y 
    dey
;-----Store coordinates
    lda ScreenRowLSB, y
    sta COLLISION_LOOKUP
    lda ScreenRowMSB, y
    sta COLLISION_LOOKUP + 1
   
    lda ColorRowLSB, y
    sta COLOR_LOOKUP
    lda ColorRowMSB, y
    sta COLOR_LOOKUP + 1

;-----Get offset player cordinates for extended explosion data
    ldx #OFFSET_XL
    ldy #(OFFSET_YU - 40) 
    
    jsr GetCollisionPoint
    ldy COLLISION_Y
    dey

;-----Store 2nd coordinates
    lda ScreenRowLSB, y
    sta COLLISION_LOOKUP2
    lda ScreenRowMSB, y
    sta COLLISION_LOOKUP2 + 1
   
    lda ColorRowLSB, y
    sta COLOR_LOOKUP2
    lda ColorRowMSB, y
    sta COLOR_LOOKUP2 + 1
     
    ldx #36
    stx TEMPX1

;-----Offset position for animation
    lda COLLISION_X 
    sec
    sbc #$02
    tay

    lda PL_Y
    cmp #66
    bcs +
    ldx #06
    stx TEMPX
    inc .LoopCounter + 1
    jmp .loop_3
+    
    ldx #$00
    stx TEMPX

;-----Start explosion animation
.loop_3:
    lda EXPLOSION_3, x
    sta (COLLISION_LOOKUP), y 
    stx TEMPX

    tax 
    lda CHAR_COLORS, x
    sta (COLOR_LOOKUP), y

;-----Explosion Extended    
    lda Expl_Extend_Flag
    beq +
    ldx TEMPX1
    lda EXPLOSION_3, x
    sta (COLLISION_LOOKUP2), y
    tax
    lda CHAR_COLORS, x
    sta (COLOR_LOOKUP2), y
    ldx TEMPX1
    inx 
    stx TEMPX1
+
    ldx TEMPX
    iny
    inx
    
    inc .LoopCounter
    lda .LoopCounter
    cmp #$06 
    bne .loop_3 ;-----Loop 6 columns

;-----Setup new row
    lda Expl_Extend_Flag
    beq +
    dec Expl_Extend_Flag
+
    lda #$00
    sta .LoopCounter
    tya
    clc
    adc #$22
    tay
    
    inc .LoopCounter + 1
    lda .LoopCounter + 1
    cmp #$06 
    bne .loop_3 ;-----Loop 6 rows

    lda #$00
    sta .LoopCounter
    sta .LoopCounter + 1
    sta Expl_Extend_Flag

    lda #$0D 
    sta Color_Timer
-    
    lda CODE_FLAG
    beq -
    dec CODE_FLAG

    dec Color_Timer
    bne -
 
    rts

Explosion_4:
;-----Get the coordinates at player position    
    lda #PLAYER_ACTIVE
    sta ENTITY_TO_UPDATE
    
    inc Expl_Extend_Flag
    inc Expl_Extend_Flag
;-----Check if player is at top row
    ldx #OFFSET_XL
    lda PL_Y
    cmp #66
    bcs +   ; If not then skip this part
    ldy #OFFSET_YU
    jmp .done4 
+
;-----Get coordinate one row above player
    ldy #(OFFSET_YU + 8) 
    
    lda PL_Y
    cmp #210
    bcc +
    dec Expl_Extend_Flag
+
    cmp #218
    bcc +
    dec Expl_Extend_Flag
+
    cmp #226    ; If player is at the bottom then else...
    bcc +
    inc .LoopCounter + 1
    dec Expl_Extend_Flag
+  
    cmp #234
    bcc .done4
    inc .LoopCounter + 1
    dec Expl_Extend_Flag

.done4:
    jsr GetCollisionPoint

    ldy COLLISION_Y 
    dey
;-----Store coordinates
    lda ScreenRowLSB, y
    sta COLLISION_LOOKUP
    lda ScreenRowMSB, y
    sta COLLISION_LOOKUP + 1
   
    lda ColorRowLSB, y
    sta COLOR_LOOKUP
    lda ColorRowMSB, y
    sta COLOR_LOOKUP + 1

;-----Get offset player cordinates for extended explosion data
    ldx #OFFSET_XL
    ldy #(OFFSET_YU - 40) 
    
    jsr GetCollisionPoint
    ldy COLLISION_Y
    dey

;-----Store 2nd coordinates
    lda ScreenRowLSB, y
    sta COLLISION_LOOKUP2
    lda ScreenRowMSB, y
    sta COLLISION_LOOKUP2 + 1
   
    lda ColorRowLSB, y
    sta COLOR_LOOKUP2
    lda ColorRowMSB, y
    sta COLOR_LOOKUP2 + 1
     
    ldx #36
    stx TEMPX1

;-----Offset position for animation
    lda COLLISION_X 
    sec
    sbc #$02
    tay

    lda PL_Y
    cmp #66
    bcs +
    ldx #06
    stx TEMPX
    inc .LoopCounter + 1
    jmp .loop_4
+    
    ldx #$00
    stx TEMPX

;-----Start explosion animation
.loop_4:
    lda EXPLOSION_4, x
    sta (COLLISION_LOOKUP), y 
    stx TEMPX

    tax 
    lda CHAR_COLORS, x
    sta (COLOR_LOOKUP), y

;-----Explosion Extended    
    lda Expl_Extend_Flag
    beq +
    ldx TEMPX1
    lda EXPLOSION_4, x
    sta (COLLISION_LOOKUP2), y
    tax
    lda CHAR_COLORS, x
    sta (COLOR_LOOKUP2), y
    ldx TEMPX1
    inx 
    stx TEMPX1
+
    ldx TEMPX
    iny
    inx
    
    inc .LoopCounter
    lda .LoopCounter
    cmp #$06 
    bne .loop_4 ;-----Loop 6 columns

;-----Setup new row
    lda Expl_Extend_Flag
    beq +
    dec Expl_Extend_Flag
+
    lda #$00
    sta .LoopCounter
    tya
    clc
    adc #$22
    tay
    
    inc .LoopCounter + 1
    lda .LoopCounter + 1
    cmp #$06 
    bne .loop_4 ;-----Loop 6 rows

;------Setup color animation
    ldx #$00
    
    lda Color_Timer + 1
    sta Color_Timer

.color_setup_4:
    lda #$00
    sta .LoopCounter + 1
    sta Expl_Extend_Flag
    inc Expl_Extend_Flag
    inc Expl_Extend_Flag
    
    lda PL_Y
    cmp #66
    bcs +
    inc .LoopCounter + 1
    jmp .done_4 
+
    lda PL_Y
    cmp #210
    bcc +
    dec Expl_Extend_Flag
+    
    cmp #218
    bcc +
    dec Expl_Extend_Flag
+
    cmp #226
    bcc +
    inc .LoopCounter + 1
    dec Expl_Extend_Flag
+   
    cmp #234
    bcc +
    inc .LoopCounter + 1
+
.done_4:
    lda COLLISION_X
    sec
    sbc #$02
    tay
    
;-----Loop through colors
.color_next_4:
    lda CODE_FLAG
    beq .color_next_4
    dec CODE_FLAG

    dec Color_Timer
    bne .color_next_4
    
.color_loop_4:
    lda ColorTable2, x
    sta (COLOR_LOOKUP), y
    lda Expl_Extend_Flag
    beq +
    lda ColorTable2, x
    sta (COLOR_LOOKUP2), y
+
    iny
    inc .LoopCounter
    lda .LoopCounter
    cmp #$06 
    bne .color_loop_4
    
    lda #$00
    sta .LoopCounter
    
    lda Expl_Extend_Flag
    beq +
    dec Expl_Extend_Flag
+

    tya
    clc
    adc #$22
    tay
    
    inc .LoopCounter + 1
    lda .LoopCounter + 1
    cmp #$06
    bne .color_loop_4
     
    lda Color_Timer + 1
    sta Color_Timer

    inx
    cpx #$03
    beq +
    jmp .color_setup_4
+    
    lda #$00
    sta .LoopCounter
    sta .LoopCounter + 1
    sta Expl_Extend_Flag

    lda Color_Timer + 1
    sta Color_Timer
    
    rts

Explosion_5:
;-----Get the coordinates at player position    
    lda #PLAYER_ACTIVE
    sta ENTITY_TO_UPDATE
    
    inc Expl_Extend_Flag
    inc Expl_Extend_Flag
;-----Check if player is at top row
    ldx #OFFSET_XL
    lda PL_Y
    cmp #66
    bcs +   ; If not then skip this part
    ldy #OFFSET_YU
    jmp .done5 
+
;-----Get coordinate one row above player
    ldy #(OFFSET_YU + 8) 
    
    lda PL_Y
    cmp #210
    bcc +
    dec Expl_Extend_Flag
+
    cmp #218
    bcc +
    dec Expl_Extend_Flag
+
    cmp #226    ; If player is at the bottom then else...
    bcc +
    inc .LoopCounter + 1
    dec Expl_Extend_Flag
+  
    cmp #234
    bcc .done5
    inc .LoopCounter + 1
    dec Expl_Extend_Flag

.done5:
    jsr GetCollisionPoint

    ldy COLLISION_Y 
    dey
;-----Store coordinates
    lda ScreenRowLSB, y
    sta COLLISION_LOOKUP
    lda ScreenRowMSB, y
    sta COLLISION_LOOKUP + 1
   
    lda ColorRowLSB, y
    sta COLOR_LOOKUP
    lda ColorRowMSB, y
    sta COLOR_LOOKUP + 1

;-----Get offset player cordinates for extended explosion data
    ldx #OFFSET_XL
    ldy #(OFFSET_YU - 40) 
    
    jsr GetCollisionPoint
    ldy COLLISION_Y
    dey

;-----Store 2nd coordinates
    lda ScreenRowLSB, y
    sta COLLISION_LOOKUP2
    lda ScreenRowMSB, y
    sta COLLISION_LOOKUP2 + 1
   
    lda ColorRowLSB, y
    sta COLOR_LOOKUP2
    lda ColorRowMSB, y
    sta COLOR_LOOKUP2 + 1
     
    ldx #36
    stx TEMPX1

;-----Offset position for animation
    lda COLLISION_X 
    sec
    sbc #$02
    tay

    lda PL_Y
    cmp #66
    bcs +
    ldx #06
    stx TEMPX
    inc .LoopCounter + 1
    jmp .loop_5
+    
    ldx #$00
    stx TEMPX

;-----Start explosion animation
.loop_5:
    lda EXPLOSION_5, x
    sta (COLLISION_LOOKUP), y 
    stx TEMPX

    tax 
    lda CHAR_COLORS, x
    sta (COLOR_LOOKUP), y

;-----Explosion Extended    
    lda Expl_Extend_Flag
    beq +
    ldx TEMPX1
    lda EXPLOSION_5, x
    sta (COLLISION_LOOKUP2), y
    tax
    lda CHAR_COLORS, x
    sta (COLOR_LOOKUP2), y
    ldx TEMPX1
    inx 
    stx TEMPX1
+
    ldx TEMPX
    iny
    inx
    
    inc .LoopCounter
    lda .LoopCounter
    cmp #$06 
    bne .loop_5 ;-----Loop 6 columns

;-----Setup new row
    lda Expl_Extend_Flag
    beq +
    dec Expl_Extend_Flag
+
    lda #$00
    sta .LoopCounter
    tya
    clc
    adc #$22
    tay
    
    inc .LoopCounter + 1
    lda .LoopCounter + 1
    cmp #$06 
    bne .loop_5 ;-----Loop 6 rows

    lda #$00
    sta .LoopCounter
    sta .LoopCounter + 1
    sta Expl_Extend_Flag
    
    sta COUNTER
    sta MILISEC
    sta SECONDS

    lda Color_Timer + 1
    sta Color_Timer
    
-    
    lda CODE_FLAG
    beq -
    dec CODE_FLAG
    
    jsr Timer
    lda MILISEC
    cmp #$09
    bne -
    
    rts
 
}

