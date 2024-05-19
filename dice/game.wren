import "xs" for Input, Render, Data
import "xs_math" for Vec2, Math
import "xs_ec"for Entity, Component
import "xs_components" for Renderable

import "hex" for HexGrid, HexTile, HexCoordinate
import "team" for Team

import "random" for Random

var IS_NOT_PLAYING  = -1
var IS_COMPUTER     = 0
var IS_PLAYER       = 1

var TEAM1 = IS_PLAYER
var TEAM2 = IS_COMPUTER
var TEAM3 = IS_COMPUTER
var TEAM4 = IS_COMPUTER
var TEAM5 = IS_COMPUTER
var TEAM6 = IS_COMPUTER
var TEAM7 = IS_NOT_PLAYING
var TEAM8 = IS_NOT_PLAYING

System.print("Game compiled")

class GameState {
    static choose_own_cell          { 0 }
    static attack_enemy_cell        { 1 }
    static switching_turn           { 2 }
    static game_over                { 3 }
}

class AnimationState {
    static no_animation             { 0 }
    static attacking                { 1 }
}

class Game {
    // The config method is called before the device, window, renderer
    // and most other systems are created. You can use it to change the
    // window title and size (for example).
    static config() {
        System.print("config")
        
        // This can be saved to the system.json using the
        // Data UI. This code overrides the values from the system.json
        // and can be removed if there is no need for that
        Data.setString("Title", "xs - hello", Data.system)
        Data.setNumber("Width", 1280, Data.system)
        Data.setNumber("Height", 720, Data.system)
        Data.setNumber("Multiplier", 1, Data.system)
        Data.setBool("Fullscreen", false, Data.system)
    }

    // The init method is called when all system have been created.
    // You can initialize you game specific data here.
    static init() {
        // The "__" means that __time is a static variable (belongs to the class)
        __time = 0

        __random = Random.new()

        __game_state = GameState.choose_own_cell

        __teams = []

        var image_team0 = Render.loadImage("[game]/assets/OSHD - Background/tile_type0.png")
        var image_team1 = Render.loadImage("[game]/assets/OSHD - Background/tile_type1.png")
        var image_team2 = Render.loadImage("[game]/assets/OSHD - Background/tile_type2.png")
        var image_team3 = Render.loadImage("[game]/assets/OSHD - Background/tile_type3.png")
        var image_team4 = Render.loadImage("[game]/assets/OSHD - Background/tile_type4.png")
        var image_team5 = Render.loadImage("[game]/assets/OSHD - Background/tile_type5.png")
        var image_team6 = Render.loadImage("[game]/assets/OSHD - Background/tile_type6.png")
        var image_team7 = Render.loadImage("[game]/assets/OSHD - Background/tile_type7.png")

        if (TEAM1 != IS_NOT_PLAYING) { __teams.add(Team.new(Render.createSprite(image_team0, 0, 0, 1, 1), TEAM1 == IS_PLAYER, 0xF5AD1EFF)) }
        if (TEAM2 != IS_NOT_PLAYING) { __teams.add(Team.new(Render.createSprite(image_team1, 0, 0, 1, 1), TEAM2 == IS_PLAYER, 0x910C0CFF)) }
        if (TEAM3 != IS_NOT_PLAYING) { __teams.add(Team.new(Render.createSprite(image_team2, 0, 0, 1, 1), TEAM3 == IS_PLAYER, 0x57305EFF)) }
        if (TEAM4 != IS_NOT_PLAYING) { __teams.add(Team.new(Render.createSprite(image_team3, 0, 0, 1, 1), TEAM4 == IS_PLAYER, 0x3F8B0DFF)) }
        if (TEAM5 != IS_NOT_PLAYING) { __teams.add(Team.new(Render.createSprite(image_team4, 0, 0, 1, 1), TEAM5 == IS_PLAYER, 0x493426FF)) }
        if (TEAM6 != IS_NOT_PLAYING) { __teams.add(Team.new(Render.createSprite(image_team5, 0, 0, 1, 1), TEAM6 == IS_PLAYER, 0x1E70A1FF)) }
        if (TEAM7 != IS_NOT_PLAYING) { __teams.add(Team.new(Render.createSprite(image_team6, 0, 0, 1, 1), TEAM7 == IS_PLAYER, 0xA4DA64FF)) }
        if (TEAM8 != IS_NOT_PLAYING) { __teams.add(Team.new(Render.createSprite(image_team7, 0, 0, 1, 1), TEAM8 == IS_PLAYER, 0xACAEACFF)) }

        var image_die0 = Render.loadImage("[game]/assets/OSHD - Icons/die/die0.png")
        var image_die1 = Render.loadImage("[game]/assets/OSHD - Icons/die/die1.png")
        var image_die2 = Render.loadImage("[game]/assets/OSHD - Icons/die/die2.png")
        var image_die3 = Render.loadImage("[game]/assets/OSHD - Icons/die/die3.png")
        var image_die4 = Render.loadImage("[game]/assets/OSHD - Icons/die/die4.png")
        var image_die5 = Render.loadImage("[game]/assets/OSHD - Icons/die/die5.png")
        var image_die6 = Render.loadImage("[game]/assets/OSHD - Icons/die/die6.png")

        __dice_sprites = []

        __dice_sprites.add(Render.createSprite(image_die0, 0, 0, 1, 1))
        __dice_sprites.add(Render.createSprite(image_die1, 0, 0, 1, 1))
        __dice_sprites.add(Render.createSprite(image_die2, 0, 0, 1, 1))
        __dice_sprites.add(Render.createSprite(image_die3, 0, 0, 1, 1))
        __dice_sprites.add(Render.createSprite(image_die4, 0, 0, 1, 1))
        __dice_sprites.add(Render.createSprite(image_die5, 0, 0, 1, 1))
        __dice_sprites.add(Render.createSprite(image_die6, 0, 0, 1, 1))

        __upper_msg = ""

        __active_attacking_team_index = 0
        __selected_tile_attack_from = null
        __selected_tile_attack_to = null
        __tiles_to_attack = []
        __warning_shown_dt = 0

        var image_selected_tile = Render.loadImage("[game]/assets/OSHD - Icons/selection-2.png")
        __selected_tile_sprite = Render.createSprite(image_selected_tile, 0, 0, 1, 1)

        var image_tile_to_attack = Render.loadImage("[game]/assets/OSHD - Icons/selection-1.png")
        __tiles_to_attack_sprite = Render.createSprite(image_tile_to_attack, 0, 0, 1, 1)

        var image_tile_attack_from_animation = Render.loadImage("[game]/assets/OSHD - Icons/attack-2.png")
        __animated_attack_from_sprite = Render.createSprite(image_tile_attack_from_animation, 0, 0, 1, 1)

        var image_tile_attack_to_animation = Render.loadImage("[game]/assets/OSHD - Icons/attack-1.png")
        __animated_attack_to_sprite = Render.createSprite(image_tile_attack_to_animation, 0, 0, 1, 1)

        __attack_team_roll_result = []
        __defense_team_roll_result = []

        var image_mouse_hover = Render.loadImage("[game]/assets/OSHD - Icons/selection-mouse.png")
        __mouse_sprite = Render.createSprite(image_mouse_hover, 0, 0, 1, 1)

        
        __mouse_hex_position = HexCoordinate.new(0, 0)

        __hex_grid = HexGrid.new(Data.getNumber("Grid width"), Data.getNumber("Grid height"), null)

        __animation_dt_time = 0
        __active_animation_state = AnimationState.no_animation

        restrict_grid()
        populate_grid(__teams.count)

        for (team in __teams) {
            place_dice(team)
        }

        reset_msg()
    }

    static update(dt) {

        var mouse_pos = Vec2.new(Input.getMouseX().round, Input.getMouseY().round)
        __mouse_hex_position = __hex_grid.getHex(mouse_pos)

        if (__warning_shown_dt != 0) {__warning_shown_dt = __warning_shown_dt + dt}

        if (__active_animation_state == AnimationState.attacking) {
            __animation_dt_time = __animation_dt_time + dt
            return
        }

        if (__game_state == GameState.game_over) return

        var atacking_team = __teams[__active_attacking_team_index]

        if (atacking_team.is_player) {
            update_player_team(atacking_team)
        } else {
            update_bot_team(atacking_team)
        }
    }

    static update_player_team(atacking_team) {

        if (__game_state == GameState.choose_own_cell) {
            
            if (Input.getMouseButtonOnce(0)) { // mouse pressed

                var tile = __hex_grid[__mouse_hex_position.q, __mouse_hex_position.r]

                if (tile == null || tile == -1) {
                    System.print("Please, select a tile")
                    __upper_msg = "Please, select a tile"
                    __warning_shown_dt = 0.01
                    return
                }

                if (atacking_team != tile.team) {

                    System.print("Please, select your own tile first")
                    __upper_msg = "Please, select your own tile first"
                    __warning_shown_dt = 0.01
                    return
                }

                if (tile.num_dice == 1) {
                    System.print("Please, select a tile with more than one die")
                    __upper_msg = "Please, select a tile with more than one die"
                    __warning_shown_dt = 0.01
                    return
                }

                var neighbours = get_neighbours(tile)

                for (neighbour in neighbours) {
                    if (neighbour.team == atacking_team || neighbour.team == -1) continue

                    __tiles_to_attack.add(neighbour)
                }

                if (__tiles_to_attack.count == 0) {
                    System.print("There are no enemies to attack from this tile")
                    __upper_msg = "There are no enemies to attack from this tile"
                    __warning_shown_dt = 0.01
                    return
                }

                __selected_tile_attack_from = tile
                change_state(GameState.attack_enemy_cell)
            }

            if (Input.getKeyOnce(Input.keyEnter)) {
                change_state(GameState.switching_turn)
            }

        } else if (__game_state == GameState.attack_enemy_cell) {
            if (Input.getMouseButtonOnce(0)) { // mouse pressed

                var tile = __hex_grid[__mouse_hex_position.q, __mouse_hex_position.r]

                if (!__tiles_to_attack.contains(tile)) {
                    System.print("You can attack only nearby enemy tiles")
                    __upper_msg = "You can attack only nearby enemy tiles"
                    __warning_shown_dt = 0.01
                    return
                }

                attack(__selected_tile_attack_from, tile)
                change_state(GameState.choose_own_cell)             
            }

            if (Input.getKey(Input.keyEscape)) { // cancels the selection
                __tiles_to_attack.clear()
                change_state(GameState.choose_own_cell)
                System.print("You have canceled the attack")
                __upper_msg = "You have canceled the attack"
                __warning_shown_dt = 0.01
            }

        } else if (__game_state == GameState.switching_turn) {
            place_dice(atacking_team)
            __active_attacking_team_index = (__active_attacking_team_index + 1) % __teams.count
            change_state(GameState.choose_own_cell)

        }
    }

    static update_bot_team(atacking_team) {
        var mouse_pos = Vec2.new(Input.getMouseX().round, Input.getMouseY().round)
        __mouse_hex_position = __hex_grid.getHex(mouse_pos)


        if (__game_state == GameState.choose_own_cell) {

            var team_tiles = get_team_tiles(atacking_team)


            // take the tile to attack from
            for (team_tile in team_tiles) {

                if (team_tile.num_dice == 1) continue

                var neighbours = get_neighbours(team_tile)
                
                for (neighbour in neighbours) {
                    if (neighbour.team == atacking_team || neighbour.team == -1) continue

                    if (neighbour.num_dice <= team_tile.num_dice) {
                        attack(team_tile, neighbour)
                        return
                    }
                }
            }

            change_state(GameState.switching_turn)

        } else if (__game_state == GameState.switching_turn) {
            switch_turn()
        }
    }

    static render() {

        for (i in 0..(__hex_grid.width-1)) {
            for (j in 0..(__hex_grid.height-1)) {
                render_cell(i, j)
            }
        }


        if (__active_animation_state == AnimationState.attacking) {

            var animation_time = 0
            if (__teams[__active_attacking_team_index].is_player){
                animation_time = Data.getNumber("Player attacking animation seconds")
            } else {
                animation_time = Data.getNumber("Bot attacking animation seconds")
            }

            if (__animation_dt_time >= animation_time) {
                __active_animation_state = AnimationState.no_animation
                __animation_dt_time = 0
                post_attack(__selected_tile_attack_from, __selected_tile_attack_to)
            } else {
                render_attack_animation(__animation_dt_time / animation_time)
            }
        } else {
            var pixel_pos = __hex_grid.get_position(__mouse_hex_position)
            Render.sprite(__mouse_sprite, pixel_pos.x, pixel_pos.y, 0, Data.getNumber("Sprite scale"),Render.spriteCenter)

            if (__game_state == GameState.attack_enemy_cell) {
                render_selection_to_attack()
            }
        }

        if (__active_animation_state == AnimationState.no_animation) {
            render_die_animation(1.01, __attack_team_roll_result, true)
            render_die_animation(1.01, __defense_team_roll_result, false)
        }

        var attack_result = 0
        var defense_result = 0

        for (roll in __attack_team_roll_result) {
            attack_result = attack_result + roll
        }

        for (roll in __defense_team_roll_result) {
            defense_result = defense_result + roll
        }

        // Rendering team logo

        Render.sprite(__teams[__active_attacking_team_index].sprite, Data.getNumber("Team logo pos x"), Data.getNumber("Team logo pos y"), 0, 0.7,Render.spriteCenter)
        Render.setColor(0xFFFFFFFF)
        Render.shapeText(__teams[__active_attacking_team_index].territory.toString, Data.getNumber("Team logo pos x") - 17, Data.getNumber("Team logo pos y") + 13, 4)



        Render.setColor(0x00FF00FF)
        Render.shapeText(attack_result.toString, -500, 100, 2)
        Render.setColor(0xFF0000FF)
        Render.shapeText(defense_result.toString,-500,-100, 2)

        
        Render.setColor(__teams[__active_attacking_team_index].color)
        if (__warning_shown_dt != 0) {
            Render.setColor(0xFFFF00FF)

            if (__warning_shown_dt >= Data.getNumber("Seconds warning is present")) {
                reset_msg()
                Render.setColor(__teams[__active_attacking_team_index].color)
            }
        }

        Render.shapeText(__upper_msg, Data.getNumber("Upper msg pos x"), Data.getNumber("Upper msg pos y"), 3)
    }

    static render_cell(i, j) {

        var tile = __hex_grid[i, j]

        if (tile == -1) return

        var team = tile.team

        var pixel_pos = __hex_grid.get_position(i, j)
        Render.sprite(team.sprite, pixel_pos.x, pixel_pos.y, 0, Data.getNumber("Sprite scale"),Render.spriteCenter)

        Render.setColor(0xFFFFFFFF)
        Render.shapeText(tile.num_dice.toString, pixel_pos.x-3, pixel_pos.y+6, 2)
    }

    static render_selection_to_attack() {
        // Tile to attack from
        var pixel_pos = __hex_grid.get_position(__selected_tile_attack_from.hex_pos)
        Render.sprite(__selected_tile_sprite, pixel_pos.x, pixel_pos.y, 0, Data.getNumber("Sprite scale"),Render.spriteCenter)

        for (tiles in __tiles_to_attack) {
            var pixel_pos = __hex_grid.get_position(tiles.hex_pos)
            Render.sprite(__tiles_to_attack_sprite, pixel_pos.x, pixel_pos.y, 0, Data.getNumber("Sprite scale"),Render.spriteCenter)
        }
    }

    static render_attack_animation(animation_percentage) {
        if (animation_percentage >= 0.0) {
            var pixel_pos = __hex_grid.get_position(__selected_tile_attack_from.hex_pos)
            Render.sprite(__animated_attack_from_sprite, pixel_pos.x, pixel_pos.y, 0, Data.getNumber("Sprite scale"),Render.spriteCenter)

            render_die_animation(animation_percentage * 2.5, __attack_team_roll_result, true)
        }

        if (animation_percentage >= 0.5) {
            var pixel_pos = __hex_grid.get_position(__selected_tile_attack_to.hex_pos)
            Render.sprite(__animated_attack_to_sprite, pixel_pos.x, pixel_pos.y, 0, Data.getNumber("Sprite scale"),Render.spriteCenter)

            render_die_animation((animation_percentage - 0.5) * 2.5, __defense_team_roll_result, false)

        }
    }

    static render_die_animation(animation_percentage, die_results, is_attacking) {

        var i = 0
        for (roll in die_results) {
            i = i + 1

            if (i / die_results.count < animation_percentage) {
                render_die(roll, i, is_attacking)
            } else {
                render_die(0, i, is_attacking)
            }
        }
    }

    static render_die(die_result, die_index, is_attacking) {
        die_index = die_index - 1
        if (is_attacking) {
            Render.sprite(__dice_sprites[die_result], Data.getNumber("Attack first die spot X") + (die_index % 4).round * 50, Data.getNumber("Attack first die spot Y") + ((die_index + 2) / 4).round * 50, 0, 0.5,Render.spriteCenter)
        } else {
            Render.sprite(__dice_sprites[die_result], Data.getNumber("Defense first die spot X") + (die_index % 4).round * 50, Data.getNumber("Defense first die spot Y") - ((die_index + 2) / 4).round * 50, 0, 0.5,Render.spriteCenter)
        }
    }

    static restrict_grid() {
        for (i in 0..(__hex_grid.width-1)) {
            
            __hex_grid[i, 0] = -1
            __hex_grid[i, __hex_grid.height-1] = -1
        }

        for (j in 0..(__hex_grid.height-1)) {
            
            __hex_grid[0, j] = -1
            __hex_grid[__hex_grid.width-1, j] = -1
        }

        for (i in 1..(__hex_grid.width-2)) {
            for (j in 1..(__hex_grid.height-2)) {
                if (i + j - i/2 > Data.getNumber("Restriction top") && i + j - i/2 < Data.getNumber("Restriction bot")) continue

                __hex_grid[i, j] = -1
            }
        }

        var obstacles_to_place = Data.getNumber("Number of obstacles")

        while(obstacles_to_place != 0) {
            var obstacle_coords = HexCoordinate.new(__random.int(__hex_grid.width), __random.int(__hex_grid.height))

            if (__hex_grid[obstacle_coords.q, obstacle_coords.r] == null) {
                __hex_grid[obstacle_coords.q, obstacle_coords.r] = -1
                obstacles_to_place = obstacles_to_place - 1
            }
        }
    }

    static populate_grid(num_teams) {
        for (i in 0..(__hex_grid.width-1)) {
            for (j in 0..(__hex_grid.height-1)) {

                if (__hex_grid[i, j] == -1) continue

                var team_index = __random.int(num_teams)
                __hex_grid[i, j] = HexTile.new(__teams[team_index], 1, HexCoordinate.new(i, j))
                __teams[team_index].change_territory(1)
            }
        }
    }

    static attack(attack_tile, defend_tile) {

        //// Already marked
        __selected_tile_attack_from = attack_tile
        __selected_tile_attack_to = defend_tile

        __attack_team_roll_result  = roll_dice(attack_tile.num_dice)
        __defense_team_roll_result = roll_dice(defend_tile.num_dice)

        __active_animation_state = AnimationState.attacking
    }

    static post_attack(attack_tile, defend_tile) {

        var attack_result = 0
        var defense_result = 0

        for (roll in __attack_team_roll_result) {
            attack_result = attack_result + roll
        }

        for (roll in __defense_team_roll_result) {
            defense_result = defense_result + roll
        }

        if (attack_result > defense_result) {
            // Attack success

            defend_tile.team.change_territory(-1)
            attack_tile.team.change_territory( 1)

            defend_tile.set_team(attack_tile.team)

            defend_tile.set_num_dice(Math.max(1, attack_tile.num_dice - defend_tile.num_dice))

        } else {
            // Defense won

        }

        attack_tile.set_num_dice(1)
        __tiles_to_attack.clear()
    }

    static place_dice(team_to_serve) {

        var tiles = get_team_tiles(team_to_serve)

        var dice_to_place = tiles.count

        while (dice_to_place != 0) {
            var index = __random.int(tiles.count)
            var tile = tiles[index]

            if (tile.increment_dice()) {
                dice_to_place = dice_to_place - 1
            } else {
                tiles.removeAt(index)
            }

            if (tiles.count == 0) { dice_to_place = 0 }

        }
        System.print("Dice have been placed")
    }

    static roll_dice(num_dice) {

        var result = []

        for (i in 1..num_dice) {
            result.add(__random.int(6) + 1)
        }

        return result
    }

    static get_team_tiles(team_to_serve) {

        var tiles = []

        for (i in 0..(__hex_grid.width-1)) {
            for (j in 0..(__hex_grid.height-1)) {
                var tile = __hex_grid[i, j]

                if (tile == -1 || tile == null) continue

                if (tile.team == team_to_serve) {
                    tiles.add(tile)
                }
            }
        }

        return tiles
    }

    static get_neighbours(tile) {
        var neighbours = []
        for (i in 0..5) {
            var hex_pos = tile.hex_pos + HexCoordinate.direction(i)
            var tile = __hex_grid[hex_pos.q, hex_pos.r]
            if (tile == -1) continue

            neighbours.add(tile)
        }
        return neighbours
    }

    static switch_turn() {
        var atacking_team = __teams[__active_attacking_team_index]
        place_dice(atacking_team)

        for(i in 1..__teams.count) {
            var potential_next_team_index = (__active_attacking_team_index + i) % __teams.count
            if (__teams[potential_next_team_index].is_alive) {

                if (__active_attacking_team_index == potential_next_team_index) {
                    game_over(__active_attacking_team_index)
                    return
                }

                __active_attacking_team_index = potential_next_team_index
                change_state(GameState.choose_own_cell)
                reset_msg()

                return
            }

        }

        game_over(__active_attacking_team_index)
    }

    static game_over(team_index) {
        System.print("Team " + team_index.toString + " won the game")
        __upper_msg = "Team " + team_index.toString + " won the game"
        change_state(GameState.game_over)
    }

    static reset_msg() {
        __upper_msg = "It is Team " + __active_attacking_team_index.toString + " turn"
    }

    static change_state(state) {
        __game_state = state
        System.print("Game state has been changed to " + state.toString)
    }
}