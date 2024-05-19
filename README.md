# Hex_dice_wars

This project has been made for a local gam jam at my university. The idea was to make a game that uses hexagonal math.
My idea was to re-create a dice wars game from my childhood.

**Special thanks** to [Bojan Endrovski](https://www.linkedin.com/in/bojanendrovski/) for the game jam and lessons about hexagons.

## Game rules

#### Setup

The game starts with a map divided into various territories, each assigned a certain number of dice. Players are allocated territories randomly.

#### Gameplay

Each turn, a player can choose to attack an adjacent territory. The number of dice on the attacking territory is rolled against the number of dice on the defending territory.

#### Combat

The player with the higher total after rolling the dice wins the territory. If the attacker wins, the dice from the attacking territory move to the newly conquered territory, leaving one die behind in the original territory. If the defender wins, the attacker loses all but one die in the attacking territory.

#### Reinforcement

At the end of each turn, players receive additional dice based on the number of contiguous territories they control.

#### Victory

The game continues until one player controls all the territories on the map.

## Tweaking options

### Multiplayer and Zeroplayer 

You can force computer play against itself, as well as make play with someone else

In the `game.wren` file from the line 15 you will find these options. You can set three different parameters for each team:
- `IS_PLAYER` - player controls the team
- `IS_COMPUTER` - computer algorithm will play as this team
- `IS_NOT_PLAYING` - this team will not spawn

```wren
var TEAM1 = IS_PLAYER
var TEAM2 = IS_COMPUTER
var TEAM3 = IS_COMPUTER
var TEAM4 = IS_COMPUTER
var TEAM5 = IS_COMPUTER
var TEAM6 = IS_COMPUTER
var TEAM7 = IS_NOT_PLAYING
var TEAM8 = IS_NOT_PLAYING
```

You are free to set every team as player, either make computer fight each other.

### Additioanl options

There are a lot of additional options which you can change. Some of them require restart of the game, some will show changes at a runtime.
I will go only through most important ones:

![Variables](/variables.png)

## Usage

1. Download xs engine from [itch.io](https://xs-engine.itch.io/xs) website.
2. Download this repo
3. Copy `/dice` folder from this repo into `/games` folder in the engine.
4. Edit the contents of `.ini` file in `/games` engine's folder:\
*Yes, just one line*
```bat
dice
```
5. Launch the `xs.exe`
6. Enjoy!

## Controls

### Attack

1. Click on one of your fields that borders with other team's tarritories, and dice number exceeds 1
2. Click on any of the opponent's territories to roll dice.

### End turn

Click <kbd>Enter</kbd>

## Conclusion

This project was a nice temporary abstraction between main projects in university. The game jam have been handled by my teacher [Bojan Endrovski](https://www.linkedin.com/in/bojanendrovski/).

Thanks for reading this,
GG
