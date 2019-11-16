!zone Enemy {

.Turbo: !byte $01
.Temp_X = TEMP1
.Temp_Y = TEMP2
.Temp_Dir = TEMP3

EnemyInit:
    ldx #$00

.Loop   
    lda #$46
    sta SPRITE_POINTERS + 1, x
    
    lda ENABLE_SPRITES
    ora ENEMY_MSB_SET, x
    sta ENABLE_SPRITES

    cpx #$00
    bne +
    lda #176
    sta .Temp_X
    lda #234
    sta .Temp_Y
    lda MV_LT
    sta .Temp_Dir
    jmp .Set
+
    cpx #$01
    bne +
    ;lda #184
    lda #185
    sta .Temp_X
    lda #58
    ;lda #218
    sta .Temp_Y
    lda MV_RT
    sta .Temp_Dir
    jmp .Set
+
    cpx #$02
    bne +
    lda #64
    sta .Temp_X
    lda #146
    sta .Temp_Y
    lda MV_UP
    sta .Temp_Dir
    jmp .Set
+   
    cpx #$03
    bne +
    lda #248
    sta .Temp_X
    lda #146
    sta .Temp_Y
    lda MV_LT
    sta .Temp_Dir

.Set:    
    txa 
    asl
    tay
    lda .Temp_X 
    sta EN0_X, y
    sta Enemy_X, x

    lda .Temp_Y
    sta Enemy_Y, x
    sta EN0_Y, y 
    
    lda .Temp_Dir
    sta Enemy_Dir, x
    
    lda #$01
    sta CheckZone
    sta CheckSnap

    lda SPRITE_MSB
    and ENEMY_MSB_UNSET, x
    sta SPRITE_MSB
    sta Enemy_MSB

    lda #$00
    sta MSB_Carry, x
    
    inx
    cpx ACTIVE_ENEMIES
    beq +
    jmp .Loop
+
    rts

EnemyUpdate:
    lda #ENEMY_ACTIVE
    sta ENTITY_TO_UPDATE
    
    lda COUNTER
    and #$07
    beq +
    jsr GetBehaviour
+    
    ldx CurrentEnemy

EGoUp:
    lda Enemy_Dir, x   
    cmp MV_UP 
    bne EGoDown 
   
    lda #$44
    sta SPRITE_POINTERS + 1, x
    jsr CheckMoveUp
    bne EC_UP 
   
    ldx CurrentEnemy
    lda Enemy_Y, x
    sec
    sbc Enemy_Speed, x
    sta Enemy_Y, x
    jmp EEnd

EC_UP:
    jsr ESnapUpDown
	bne EGoUp

    jsr CheckMoveRight
    bne +
    ldx CurrentEnemy
    lda MV_RT
    sta Enemy_Dir, x 
    jmp EGoRight
    
+   
    jsr CheckMoveLeft
    bne +
    ldx CurrentEnemy
    lda MV_LT
    sta Enemy_Dir, x
    jmp EGoLeft
+

EGoDown:
    lda Enemy_Dir, x 
    cmp MV_DN
    bne EGoLeft
    
    lda #$45
    sta SPRITE_POINTERS + 1, x
    
    jsr CheckMoveDown
    bne EC_DN 
    
    ldx CurrentEnemy
    lda Enemy_Y, x
    clc
    adc Enemy_Speed, x 
    sta Enemy_Y, x

    jmp EEnd

EC_DN:
    jsr ESnapUpDown
    bne EGoDown

    jsr CheckMoveLeft
    bne +
    ldx CurrentEnemy
    lda MV_LT
    sta Enemy_Dir, x
    jmp EGoLeft
+
    jsr CheckMoveRight
    bne +
    ldx CurrentEnemy
    lda MV_RT
    sta Enemy_Dir, x
    jmp EGoRight
+   
    jmp EEnd

EGoLeft:    
    ldx CurrentEnemy
    lda Enemy_Dir, x 
    cmp MV_LT
    bne EGoRight
    
    lda #$46    
    sta SPRITE_POINTERS + 1, x
    
    jsr CheckMoveLeft
    bne EC_LT
    
    ldx CurrentEnemy
    lda Enemy_X, x
    sec
    sbc Enemy_Speed, x 
    sta Enemy_X, x
    bcs EGoRight
    lda MSB_Carry, x
    sbc #$00
    sta MSB_Carry, x
    lda Enemy_MSB 
    eor ENEMY_MSB_SET, x
    sta Enemy_MSB 
    ora Player_MSB
    sta SPRITE_MSB
    jmp EEnd 

EC_LT:
    jsr ESnapLeftRight
    bne EGoLeft
    
    jsr CheckMoveUp
    bne +
    ldx CurrentEnemy
    lda MV_UP
    sta Enemy_Dir, x
    jmp EGoUp
+
    jsr CheckMoveDown
    bne +
    ldx CurrentEnemy
    lda MV_DN
    sta Enemy_Dir, x
    jmp EGoDown
+
    jmp EEnd

EGoRight: 
    lda Enemy_Dir, x 
    cmp MV_RT
    bne EEnd
    
    lda #$47
    sta SPRITE_POINTERS + 1, x 
    
    jsr CheckMoveRight
    bne EC_RT 
    
    ldx CurrentEnemy
    lda Enemy_X, x
    clc
    adc Enemy_Speed, x 
    sta Enemy_X, x
    bcc EEnd 
    lda MSB_Carry, x
    adc #$00
    sta MSB_Carry, x
    lda Enemy_MSB
    ora ENEMY_MSB_SET, x
    sta Enemy_MSB
    ora Player_MSB
    sta SPRITE_MSB
    jmp EEnd 

EC_RT:
    jsr ESnapLeftRight
    bne EGoRight

    jsr CheckMoveUp
    bne +
    ldx CurrentEnemy
    lda MV_UP
    sta Enemy_Dir, x
    jmp EGoUp
+
    jsr CheckMoveDown
    bne +
    ldx CurrentEnemy
    lda MV_DN
    sta Enemy_Dir, x
    jmp EGoDown
+   

EEnd:
    lda CurrentEnemy
    asl
    tay
    lda Enemy_X, x
    sta EN0_X, y 
    lda Enemy_Y, x
    sta EN0_Y, y
    
    inc CurrentEnemy
    ldx CurrentEnemy
    cpx ACTIVE_ENEMIES
    beq +
    jmp EnemyUpdate 
+
    lda #$00
    sta CurrentEnemy
    rts

;--------------------------------------------------------
;--Update Enemy Behaviours    
;--------------------------------------------------------
GetBehaviour:

;-----First change rotation if it is the same as player
.on_rotation:
    jsr GetEnemyState
    lda ENEMY_STATE, x
    cmp PLAYER_STATE
    bne .on_position 
    lda Enemy_MSB, x
    bne .move_right
    lda Enemy_X, x
    cmp #160
    bcs .move_right
    jmp ELeft

.move_right:
    jmp ERight    

;-----If rotation is differend then move based on position
.on_position:
    lda Enemy_Dir, x
    cmp MV_DN
    beq .check_x
    lda Enemy_Y, x
    cmp Player_Y
    bcc +
    jmp EUp
+
    jmp EDown

.check_x
    lda Enemy_MSB, x
    bne ELeft 
    lda Enemy_X, x
    cmp Player_X
    bcc +
    jmp ELeft 
+    
    jmp ERight
;    ldx CurrentEnemy
;    lda Enemy_Dir, x
;    
;    cmp MV_DN
;    bne +
;    jmp ELeft
;+    
;    cmp MV_LT
;    beq EDown
;    cmp MV_RT
;    beq EUp
;    cmp MV_UP
;    bne +
;    jmp ERight
;+
;    rts

EUp:
    lda Enemy_Dir, x 
    cmp MV_UP
    beq +  
    cmp MV_DN
    beq + 

    lda #NO
    sta CheckZone
    jsr CheckMoveUp
    bne + 
    
    ldx CurrentEnemy
    lda Enemy_Y, x
    sec
    sbc #$01
    sta Enemy_Y, x
+
    rts

EDown:
    lda Enemy_Dir, x
    cmp MV_UP
    beq + 
    cmp MV_DN
    beq +

    lda #NO
    sta CheckZone
    jsr CheckMoveDown
    bne + 

    ldx CurrentEnemy
    lda Enemy_Y, x
    clc 
    adc #$01
    sta Enemy_Y, x
+    
    rts

ELeft:
    lda Enemy_Dir, x 
    cmp MV_LT
    beq +
    cmp MV_RT
    beq +
    
    lda #NO
    sta CheckZone
    jsr CheckMoveLeft
    bne +
    
    ldx CurrentEnemy
    lda Enemy_X, x
    sec
    sbc #01
    sta Enemy_X, x
    bcs + 
    
    lda MSB_Carry, x
    sbc #$00
    sta MSB_Carry, x
    lda Enemy_MSB 
    eor ENEMY_MSB_SET, x
    sta Enemy_MSB 
    ora Player_MSB
    sta SPRITE_MSB
+
    rts

ERight:
    lda Enemy_Dir, x
    cmp MV_LT
    beq ETurbo
    cmp MV_RT
    beq ETurbo
   
    lda #NO
    sta CheckZone
    jsr CheckMoveRight
    bne ETurbo
    
    ldx CurrentEnemy
    lda Enemy_X, x
    clc
    adc #$01
    sta Enemy_X, x
    bcc ETurbo 

    lda MSB_Carry, x
    adc #$00
    sta MSB_Carry, x
    lda Enemy_MSB
    ora ENEMY_MSB_SET, x
    sta Enemy_MSB
    ora Player_MSB
    sta SPRITE_MSB
    
    rts

ETurbo: 
    
    rts

GetEnemyState:
    ldx CurrentEnemy
    lda Enemy_Y, x
    cmp #150
    bcs .is_bottom 
    lda Enemy_Dir, x
    cmp MV_LT
    bne +
    lda #IS_CCW
    sta ENEMY_STATE, x
    rts
+
    cmp MV_RT
    bne .check_lr
    lda #IS_CW
    sta ENEMY_STATE, x
    rts

.is_bottom:
    lda Enemy_Dir, x
    cmp MV_LT
    bne + 
    lda #IS_CW
    sta ENEMY_STATE, x 
    rts
+
    cmp MV_RT
    bne .check_lr
    lda #IS_CCW
    sta ENEMY_STATE, x
    rts

.check_lr:
    lda Enemy_MSB, x
    bne .is_right
    lda Enemy_X, x
    cmp #200
    bcs .is_right
    lda Enemy_Dir, x
    cmp MV_UP
    bne +
    lda #IS_CW
    sta ENEMY_STATE, x
    rts
+
    cmp MV_DN
    bne .is_right
    lda #IS_CCW
    sta ENEMY_STATE, x
    rts

.is_right:
    lda Enemy_Dir, x
    cmp MV_DN
    bne + 
    lda #IS_CW
    sta ENEMY_STATE, x 
    rts
+
    cmp MV_UP
    bne +
    lda #IS_CCW
    sta ENEMY_STATE, x
+    
    rts


}
