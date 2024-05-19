import "xs" for Input, Render, Data
import "xs_ec"for Entity, Component
import "xs_math" for Vec2, Math



class HexCoordinate {
    construct new(q, r) {
        _q = q
        _r = r
    }

    construct new(hex) {
        _q = hex.q
        _r = hex.r
    }

    q=(value) { _q = value }
    q { _q }
    r=(value) { _r = value }
    r { _r }
    s { -q-r }

    +(other) { HexCoordinate.new(q + other.q, r + other.r) }
    -(other) { HexCoordinate.new(q - other.q, r - other.r) }

    ==(other) { (other != null && q == other.q && r == other.r) }

    static distance(a, b) {
        return ((a.q - b.q).abs  + (a.q + a.r - b.q - b.r).abs + (a.r - b.r).abs) / 2.0
    }

    static direction(direction) {
        if(__directions == null) {
            __directions = [
            HexCoordinate.new( 1,  0),
            HexCoordinate.new( 1, -1),
            HexCoordinate.new( 0, -1),
            HexCoordinate.new(-1,  0),
            HexCoordinate.new(-1,  1),
            HexCoordinate.new( 0,  1)]

            System.print("Directions have been created")
        }
        return __directions[direction % 6]
    }

    // getNeighbors() {
    //     var neighbors = []
    //     for(direction in 0..5) {
    //         neighbors.add(this + HexCoordinate.direction(direction))
    //     }
    //     return neighbors
    // }

    // getNeighbor(direction) {
    //     return this + HexCoordinate.direction(direction)
    // }

    toString { "[" + q.toString + ", " + r.toString + "]" }
}



class HexTile {
    construct new(team, num_dice, hex_position) {
        _team = team
        _num_dice = num_dice
        _hex_position = hex_position
    }

    team { _team}
    num_dice { _num_dice}
    hex_pos { _hex_position}

    set_team(team) { _team = team}

    increment_dice() {
        if (_num_dice == Data.getNumber("Max dice number")) {
            return false
        }

        _num_dice = _num_dice + 1
        return true
    }

    set_num_dice(int) { _num_dice = int }
}


class HexGrid {
    construct new(width, height, fill_value) {
        _grid = []
        _width = width
        _height = height

        _grid_offset = Vec2.new(0, 0)

        var n = _width * _height
        for (i in 1..n) {
            _grid.add(fill_value)
        }
    }

     /// The number of columns in the grid.
    width { _width }

    /// The number of rows in the grid.
    height { _height }

    offset(offset) { _grid_offset = offset }

    cell_size { Vec2.new(Data.getNumber("Cell size x"), Data.getNumber("Cell size y")) }

    get_position(hex_coord) {get_position(hex_coord.q, hex_coord.r)}

    get_position(q, r) {
        var v = Vec2.new(0, 0)
        v.x = cell_size.x * (3.0 / 2.0 * q) + Data.getNumber("Grid offset x")
        v.y = -cell_size.y * (3.sqrt * (r + q / 2.0)) + Data.getNumber("Grid offset y")
        return v
    }

    getHex(position) {
        var adjusted_pos = position - Vec2.new(Data.getNumber("Grid offset x"), Data.getNumber("Grid offset y"))

        var q = adjusted_pos.x * 2.0 / 3.0 / cell_size.x 
	    var r = (-adjusted_pos.x / 3.0 + 3.sqrt / 3.0 * adjusted_pos.y) / cell_size.y

	    var cx = q
	    var cz = r
	    var cy = -cx-cz

	    var rx = cx.round
	    var ry = cy.round
	    var rz = cz.round

	    var x_diff = (rx - cx).abs
	    var y_diff = (ry - cy).abs
	    var z_diff = (rz - cz).abs

	    if ((x_diff > y_diff) && (x_diff > z_diff)) {
		    rx = -ry - rz
        } else if (y_diff > z_diff) {
		    ry = -rx - rz
        } else {
		    rz = -rx - ry
        }

	    return HexCoordinate.new(rx, ry)
    }

    print() {
        for (i in 0..(width-1)) {
            for (j in 0..(height-1)) {
                System.print(_grid[i + j * width])
            }
            System.print("/n")
        }
    }

    /// Returns the value stored at the given grid cell.    
    [x, y] {
        if (x >= width || y >= height || x < 0 || y < 0) {
            System.print("Provided coordinates are not valid, ERROR!!!")
            return null
        } else {
            return _grid[x + y * _width]
        }
    }

    /// Assigns a given value to a given grid cell.    
    [x, y]=(v) {
        if (x >= width || y >= height || x < 0 || y < 0) {
            System.print("Provided coordinates are not valid, ERROR!!!")
            return
        } else { 
            _grid[x + y * _width] = v
        }
    }

}