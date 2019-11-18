;--------------------------------------------------------
;--Player routines                       
;--------------------------------------------------------
!zone Player { 

; Declaring some local variables    
.Turbo: !byte $01
.JOY_UP = %00001
.JOY_DN = %00010
.JOY_LT = %00100
.JOY_RT = %01000
.JOY_FR = %10000

;--------------------------------------------------------
;--Routine for intializing player          
;--------------------------------------------------------
PlayerInit:
    lda #$43
    sta SPRITE_POINTERS

    lda #185
    sta Player_X 
    sta PL_X
    lda #234
    sta Player_Y
    sta PL_Y
    lda MV_RT
    sta PL_DIR
    
    lda #$01
    sta CheckZone
    sta CheckSnap
    
    lda ENABLE_SPRITES
    ora #%00000001
    sta ENABLE_SPRITES

    lda #$00
    sta POINT_COUNTER

    lda SPRITE_MSB
    and #%11111110
    sta SPRITE_MSB
    sta Player_MSB

    rts

;--------------------------------------------------------
;--Player controll and display routines 
;--------------------------------------------------------
PlayerUpdate:
    lda #PLAYER_ACTIVE
    sta ENTITY_TO_UPDATE

    jsr GetPlayerState 

;;-----DEBUG---------------    
;    lda PLAYER_STATE
;    clc 
;    adc #10
;    sta SCREEN_RAM + 2
;    lda #$01
;    sta COLOR_RAM + 2 
;;-------------------------

    lda Speed_Flag
    bne +
    lda JOY_P_2
    and #.JOY_FR
    beq .skip

    lda COUNTER
    and #$01
    bne +
    rts   
+
    lda COUNTER
    and #$07
    beq +
    jsr ReadJoystick
+    
.skip:

GoUp:
    lda PL_DIR
    cmp MV_UP 
    bne GoDown 
    
    lda #$40
    sta SPRITE_POINTERS 
    
    jsr CheckMoveUp
    bne C_UP 

    lda Player_Y
    sec
    sbc Speed
    sta Player_Y

    jmp End

C_UP:
    jsr SnapUpDown
    bne GoUp
    
    jsr CheckMoveRight
    bne +
    lda MV_RT
    sta PL_DIR
    jmp GoRight
    
+   
    jsr CheckMoveLeft
    bne +
    lda MV_LT
    sta PL_DIR
    jmp GoLeft
+

GoDown:
    lda PL_DIR
    cmp MV_DN
    bne GoLeft
    
    lda #$41
    sta SPRITE_POINTERS 
    
    jsr CheckMoveDown
    bne C_DN 

    lda Player_Y
    clc
    adc Speed
    sta Player_Y 
    jmp End

C_DN:
    jsr SnapUpDown
    bne GoDown
    
    jsr CheckMoveLeft
    bne +
    lda MV_LT
    sta PL_DIR
    jmp GoLeft
+
    jsr CheckMoveRight
    bne +
    lda MV_RT
    sta PL_DIR
    jmp GoRight
+   
    jmp End

GoLeft:    
    lda PL_DIR
    cmp MV_LT
    bne GoRight
    
    lda #$42
    sta SPRITE_POINTERS 
    
    jsr CheckMoveLeft
    bne C_LT

    lda Player_X
    sec
    sbc Speed
    sta Player_X
    bcs GoRight
    
    lda #%00000000
    sta Player_MSB
    ora Enemy_MSB
    sta SPRITE_MSB
    
    jmp End 

C_LT:
    jsr SnapLeftRight
    bne GoLeft
    
    jsr CheckMoveUp
    bne +
    lda MV_UP
    sta PL_DIR
    jmp GoUp
+
    jsr CheckMoveDown
    bne +
    lda MV_DN
    sta PL_DIR
    jmp GoDown
+
    jmp End

GoRight: 
    lda PL_DIR
    cmp MV_RT
    bne End
    
    lda #$43
    sta SPRITE_POINTERS 
    
    jsr CheckMoveRight
    bne C_RT 
    
    lda Player_X
    clc
    adc Speed
    sta Player_X
    bcc End
    lda #%00000001
    sta Player_MSB
    ora Enemy_MSB
    sta SPRITE_MSB
    jmp End 

C_RT:
    jsr SnapLeftRight
    bne GoRight
    
    jsr CheckMoveUp
    bne +
    lda MV_UP
    sta PL_DIR
    jmp GoUp
+
    jsr CheckMoveDown
    bne +
    lda MV_DN
    sta PL_DIR
    jmp GoDown
+   

End:
    lda Player_X
    sta PL_X 
    lda Player_Y
    sta PL_Y
    
    jsr CheckScorePoints
    jsr CheckSpriteCollision

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
   
    lda PL_DIR
    cmp MV_UP
    beq +  
    cmp MV_DN
    beq + 

    lda #NO
    sta CheckZone
    jsr CheckMoveUp
    bne + 
    dec Player_Y
+
    jmp Turbo

Down:
    lda JOY_ZP
    and #.JOY_DN
    bne Left
    
    lda PL_DIR
    cmp MV_UP
    beq Left 
    cmp MV_DN
    beq Turbo

    lda #NO
    sta CheckZone
    jsr CheckMoveDown
    bne Turbo
    inc Player_Y

Left:
    lda JOY_ZP
    and #.JOY_LT
    bne Right

    lda PL_DIR
    cmp MV_LT
    beq Turbo
    cmp MV_RT
    beq Turbo
    
    lda #NO
    sta CheckZone
    jsr CheckMoveLeft
    bne Turbo
    
    lda Player_X
    sec
    sbc #01
    sta Player_X
    bcs Turbo 
    
    lda #%00000000
    sta Player_MSB
    ora Enemy_MSB
    sta SPRITE_MSB
 
Right:
    lda JOY_ZP
    and #.JOY_RT
    bne Turbo
 
    lda PL_DIR
    cmp MV_LT
    beq Turbo
    cmp MV_RT
    beq Turbo
   
    lda #NO
    sta CheckZone
    jsr CheckMoveRight
    bne Turbo
  
    lda Player_X
    clc
    adc #$01
    sta Player_X
    bcc Turbo 

    lda #%00000001
    sta Player_MSB
    ora Enemy_MSB
    sta SPRITE_MSB

Turbo:    
    lda JOY_P_2
    and #.JOY_FR
    bne TurboOff 
    ;lda COUNTER
    ;and #$03
    ;beq TurboOff
    lda Speed
    cmp #$03
    beq +
    inc Speed
+    
    rts

TurboOff:
    lda Speed
    cmp #$01
    beq +
    dec Speed
+    
    rts

GetPlayerState:
    lda Player_Y
    cmp #150
    bcs .is_bottom 
    lda PL_DIR
    cmp MV_LT
    bne +
    lda #IS_CCW
    sta PLAYER_STATE
    rts
+
    cmp MV_RT
    bne .check_lr 
    lda #IS_CW
    sta PLAYER_STATE
    rts

.is_bottom:
    lda PL_DIR
    cmp MV_LT
    bne + 
    lda #IS_CW
    sta PLAYER_STATE
    rts
+
    cmp MV_RT
    bne .check_lr
    lda #IS_CCW
    sta PLAYER_STATE
    rts

.check_lr:
    lda Player_MSB
    bne .is_right
    lda Player_X
    cmp #200
    bcs .is_right
    lda PL_DIR
    cmp MV_UP
    bne +
    lda #IS_CW
    sta PLAYER_STATE
    rts
+
    cmp MV_DN
    bne .is_right 
    lda #IS_CCW
    sta PLAYER_STATE
    rts

.is_right:
    lda PL_DIR
    cmp MV_DN
    bne + 
    lda #IS_CW
    sta PLAYER_STATE
    rts
+
    cmp MV_UP
    bne +
    lda #IS_CCW
    sta PLAYER_STATE
+    
    rts


}
