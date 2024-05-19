

class Team {

    construct new(sprite, is_player, color) {
        _sprite = sprite
        _territory = 0
        _is_player = is_player
        _is_alive = true
        _color = color
    }

    index { _index}

    sprite { _sprite}

    territory { _territory}

    is_player { _is_player}

    is_alive { _is_alive}

    color { _color }

    change_territory(int) {
        _territory = _territory + int
        if (_territory <= 0) {
            System.print("Team has been eliminated")
            _is_alive = false
        }
    }

}