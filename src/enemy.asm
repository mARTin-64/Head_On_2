!zone Enemy {

.Turbo: !byte $01
ENEMY_X     = POINTER4
ENEMY_Y     = POINTER6
EN_DIR      = POINTER7
EN_TURBO    = POINTER8
EN_MSB      = POINTER9

EnemyInit:
    lda #$46
    sta SPRITE_POINTERS + 1
    
    lda #175
    sta Enemy_X  
    lda #234
    sta Enemy_Y
    
    lda MV_LT
    sta Enemy_Dir
    
    lda #$01
    sta CheckZone
   
    lda SPRITE_MSB
    and #%11111101
    sta SPRITE_MSB
    sta Enemy_MSB

    rts

EnemyUpdate:
    lda #ENEMY_ACTIVE
    sta ENTITY_TO_UPDATE
    
;SetupEnemy:
;    lda #<Enemy_X, x
;    sta ENEMY_X
;    lda #>Enemy_X, x
;    sta ENEMY_X + 1
;    
;    lda #<Enemy_Y, x
;    sta ENEMY_Y
;    lda #>Enemy_Y, x
;    sta ENEMY_Y + 1
;    
;    lda #<Enemy_Dir, x
;    sta EN_DIR
;    lda #>Enemy_Dir, x
;    sta EN_DIR + 1
;
;    lda #<Enemy_MSB, x
;    sta EN_MSB
;    lda #>Enemy_MSB, x
;    sta EN_MSB + 1
       
     jsr GetBehaviour
    
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
    sbc #$01
    sta Enemy_Y, x
    
    lda Enemy_Turbo 
    cmp .Turbo 
    bne EGoDown
    
    lda Enemy_Y, x
    sec
    sbc #$01
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
    adc #$01
    sta Enemy_Y, x

    lda Enemy_Turbo
    cmp .Turbo 
    bne EGoLeft 
    
    lda Enemy_Y, x
    clc
    adc #$01
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
    lda Enemy_Turbo 
    cmp .Turbo 
    bne ENoturbo
    
    lda Enemy_X, x
    sec
    sbc #02
    sta Enemy_X, x
    bcs EGoRight
    jmp ESetMSB0

ENoturbo:
    lda Enemy_X, x
    sec
    sbc #$01
    sta Enemy_X, x
    bcs EGoRight 

ESetMSB0:
    lda #%00000000 
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
    lda (EN_TURBO), y
    cmp .Turbo 
    clc
    bne ENoturbo1 
    
    lda Enemy_X, x
    adc #$01
    sta Enemy_X, x
    bcc EEnd 
    jmp ESetMSB1

ENoturbo1:
    lda Enemy_X, x
    adc #$01
    sta Enemy_X, x
    bcc EEnd 

ESetMSB1: 
    lda #%00000010 
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
    lda Enemy_X, x
    sta EN0_X 
    lda Enemy_Y, x
    sta EN0_Y
    
    inc CurrentEnemy
    ldx CurrentEnemy
    cpx ACTIVE_ENEMYES
    beq +
    rts
+
    lda #$00
    sta CurrentEnemy
    rts

;--------------------------------------------------------
;--Update Enemy Behaviours    
;--------------------------------------------------------
GetBehaviour:
    ldx CurrentEnemy
    lda Enemy_Dir
    
    cmp MV_DN
    beq ELeft
    cmp MV_LT
    beq EDown
    cmp MV_RT
    beq EUp
    cmp MV_UP
    beq ERight

    rts

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
    bne ETurbo

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
    beq ETurbo
    cmp MV_RT
    beq ETurbo
    
    lda #NO
    sta CheckZone
    jsr CheckMoveLeft
    bne ETurbo
    
    ldx CurrentEnemy
    lda Enemy_X, x
    sec
    sbc #01
    sta Enemy_X, x
    bcs ETurbo 
    
    lda #%00000000
    sta Enemy_MSB
    ora Player_MSB
    sta SPRITE_MSB
    
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

    lda #%00000010
    sta Enemy_MSB
    ora Player_MSB
    sta SPRITE_MSB
    
    rts

ETurbo:    

    rts

ETurboOff:

    rts

}
