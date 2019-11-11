; Load Sprite, and Map data into defined memory locations

* = $D000
PLAYER_SPRITE:
    !binary "../sprites/player_sprites.bin"

ENEMY_SPRITE:
    !binary "../sprites/enemy_sprites.bin"

* = $8000       ; Map and Color data starts at $8000
MAP: 
    !binary "../maps/map.bin"

START_MENU:    
    !binary "../maps/menu_start.bin"

BONUS_SCREEN:
    !binary "../maps/bonus_screen.bin"

EXPLOSION_1:
    !binary "../animations/explosion_1.bin"

EXPLOSION_2:
    !binary "../animations/explosion_2.bin"

EXPLOSION_3:
    !binary "../animations/explosion_3.bin"

EXPLOSION_4:
    !binary "../animations/explosion_4.bin"

EXPLOSION_5:
    !binary "../animations/explosion_5.bin"

CHAR_COLORS:
    !binary "../char_set/char_attributes.bin"

* = $F000       ; Character set starts at $F000
CHAR_SET:
    !binary "../char_set/char_set.bin"


