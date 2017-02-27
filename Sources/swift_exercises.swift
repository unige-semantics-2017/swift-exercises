import Foundation	// floor, random, etc

// http://bulbapedia.bulbagarden.net/wiki/Type
enum Type {
    case bug
    case dark
    case dragon
    case electric
    case fairy
    case fighting
    case fire
    case flying
    case ghost
    case grass
    case ground
    case ice
    case normal
    case poison
    case psychic
    case rock
    case steel
    case water
}

// http://bulbapedia.bulbagarden.net/wiki/Damage_category
enum Category {
    case physical
    case special
    case status
}

// http://bulbapedia.bulbagarden.net/wiki/Nature
enum Nature {
    case hardy
    case lonely
    case brave
    case adamant
    case naughty
    case bold
    case docile
    case relaxed
    case impish
    case lax
    case timid
    case hasty
    case serious
    case jolly
    case naive
    case modest
    case mild
    case quiet
    case bashful
    case rash
    case calm
    case gentle
    case sassy
    case careful
    case quirky
}

// http://bulbapedia.bulbagarden.net/wiki/Weather
enum Weather {
    case clear_skies
    case harsh_sunlight (extremely: Bool)
    case rain (heavy : Bool)
    case sandstorm
    case hail (diamond_dust : Bool)
    case shadowy_aura
    case fog
    case mysterious_air_current
}

enum Terrain {
    case normal
    case electric
    case grassy
    case psychic
    case misty
}

// http://bulbapedia.bulbagarden.net/wiki/Move
struct Move : Hashable {
    let id          : Int
    let name        : String
    let description : String
    let category    : Category
    let type        : Type
    var power       : Int
    let accuracy    : Int
    let powerpoints : Int
    let priority    : Int

    var hashValue   : Int {
      return self.id
    }
}
func ==(lhs: Move, rhs: Move) -> Bool {
    return lhs.id == rhs.id
}

// http://bulbapedia.bulbagarden.net/wiki/Statistic
struct Stats {
    var hitpoints       : Double
    var attack          : Double
    var defense         : Double
    var special_attack  : Double
    var special_defense : Double
    var speed           : Double
}

struct Species : Hashable {
    let id          : Int
    let name        : String
    let evolutions  : Set<Species>
    let attacks     : Set<Move>
    let type        : (Type, Type?)
    let base_values : Stats
    var hashValue   : Int {
      return self.id
    }
}
func ==(lhs: Species, rhs: Species) -> Bool {
    return lhs.id == rhs.id
}


// create kangaskhan species
let species_kangaskhan: Species = Species(
	id: 155,
	name: "Kangaskhan",
	evolutions: [],
	attacks: [move_reversal, move_earthquake, move_iceBeam, move_suckerPunch],
	type: (.normal, nil),
	base_values: Stats(
		hitpoints: 105,
		attack: 95,
		defense: 80,
		special_attack: 40,
		special_defense: 80,
		speed: 90
	)
)

// fancy movesets are irrelevant, pick some other moves that aren't just plain damage

func computeReversalPower(currentHitpoints: Double, maxHitpoints: Double) -> Int
{
	// returns damage dealt by the 'reversal' move
	// see http://bulbapedia.bulbagarden.net/wiki/Reversal_(move)
	let HPRatio: Double = currentHitpoints / maxHitpoints

	if (0.0417 > HPRatio) {return 200}
	else if (0.1042 > HPRatio) {return 150}
	else if (0.2083 > HPRatio) {return 100}
	else if (0.3542 > HPRatio) {return 80}
	else if (0.6875 > HPRatio) {return 40}
	else {return 20}
}

let move_reversal: Move = Move(
	id: 179,
	name: "Reversal",
	description: "Stronger if the user's HP is low.",
	category: .physical,
	type: .fighting,
	power: computeReversalPower(currentHitpoints: Double(kangaskhan.hitpoints), maxHitpoints: Double(kangaskhan.effective_stats.hitpoints)),	// ?
	accuracy: 100,
	powerpoints: 15,
	priority: 0
)

let move_earthquake: Move = Move(
	id: 89,
	name: "Earthquake",
	description: "Tough but useless vs. flying foes.",
	category: .physical,
	type: .ground,
	power: 100,
	accuracy: 100,
	powerpoints: 10,
	priority: 0
)

let move_iceBeam: Move = Move(
	id: 58,
	name: "Ice Beam",
	description: "An attack that may freeze the foe.",
	category: .special,
	type: .ice,
	power: 90,
	accuracy: 100,
	powerpoints: 10,
	priority: 0
)

let move_suckerPunch: Move = Move(
	id: 389,
	name: "Sucker Punch",
	description: "This move enables the user to attack first. It fails if the foe is not readying an attack, however.",
	category: .physical,
	type: .fighting,
	power: 70,
	accuracy: 100,
	powerpoints: 5,
	priority: 1
)


struct Pokemon {
	let nickname          : String?
	var hitpoints         : Int // remaining hitpoints
	// eventually remove this, and get HP from current_stats
	let size              : Float
	let weight            : Float
	var experience        : Int
	var level             : Double
	let type			  : (Type, Type?)
	let nature            : Nature
	let species           : Species
	var moves             : [Move: Int] // Move -> remaining powerpoints
	let base_values		  : Stats
	let individual_values : Stats
	var effort_values     : Stats
	let effort_values_yield: Stats
	var effective_stats	  : Stats {
		get {
			let stats = computeStats(base_values: base_values, individual_values: individual_values, effort_values: effort_values, level: level)
			return stats
		}
	}
}



func computeStats(base_values: Stats, individual_values: Stats, effort_values: Stats, level: Double) -> Stats {
	//expressions broken up because they're too long for the compiler

	let hitpointsTemp: Double = 2 * base_values.hitpoints + individual_values.hitpoints
	let hitpointsTemp2: Double = hitpointsTemp + floor(effort_values.hitpoints / 4)
	let hitpointsTemp3: Double = floor((hitpointsTemp2 * level)/100)
	let hitpoints: Double = hitpointsTemp3 + level + 10

	let attackTemp: Double = floor(Double(effort_values.attack) / 4)
	let attackTemp2: Double = (2 * base_values.attack + individual_values.attack + attackTemp) * level
	let attackTemp3: Double = floor(attackTemp2 / 100)
	let attack: Double = (attackTemp3 + 5) * 1	// natureMultiplier(attack) instead of '1',

	let defenseTemp: Double = floor(Double(effort_values.defense) / 4)
	let defenseTemp2: Double = (2 * base_values.defense + individual_values.defense + defenseTemp) * level
	let defenseTemp3: Double = floor(defenseTemp2 / 100)
	let defense: Double = (defenseTemp3 + 5) * 1	// natureMultiplier(defense) instead of '1',

	let special_attackTemp: Double = floor(Double(effort_values.special_attack) / 4)
	let special_attackTemp2: Double = (2 * base_values.special_attack + individual_values.special_attack + special_attackTemp) * level
	let special_attackTemp3: Double = floor(special_attackTemp2 / 100)
	let special_attack: Double = (special_attackTemp3 + 5) * 1	// natureMultiplier(special_attack) instead of '1',

	let special_defenseTemp: Double = floor(Double(effort_values.special_defense) / 4)
	let special_defenseTemp2: Double = (2 * base_values.special_defense + individual_values.special_defense + special_defenseTemp) * level
	let special_defenseTemp3: Double = floor(special_defenseTemp2 / 100)
	let special_defense: Double = (special_defenseTemp3 + 5) * 1	// natureMultiplier(special_defense) instead of '1',

	let speedTemp: Double = floor(Double(effort_values.speed) / 4)
	let speedTemp2: Double = (2 * base_values.speed + individual_values.speed + speedTemp) * level
	let speedTemp3: Double = floor(speedTemp2 / 100)
	let speed: Double = (speedTemp3 + 5) * 1	// natureMultiplier(speed) instead of '1',

	return Stats(
		hitpoints: hitpoints,
		attack: attack,
		defense: defense,
		special_attack: special_attack,
		special_defense: special_defense,
		speed: speed)
}


var kangaskhan = Pokemon(
	nickname: "KANGS",
	hitpoints: 0,	// eventually remove this, and get HP from current_stats
	size: 2.2,
	weight: 80,
	experience: 1000000, // kangaskhan is a medium-fast leveler, MFXP = lvl^3
	level: 100, // DA VERY BESS
	type : species_kangaskhan.type,
	nature: .rash,
	species: species_kangaskhan,
	moves: [move_reversal: 15,
			move_earthquake: 10,
			move_iceBeam: 10,
			move_suckerPunch: 5],
	base_values: species_kangaskhan.base_values,
	//IVs and EVs tryharded to hell and back because why not
	individual_values: Stats(
		hitpoints: 31,
		attack: 31,
		defense: 31,
		special_attack: 31,
		special_defense: 31,
		speed: 31),
	effort_values: Stats(
		hitpoints: 200,
		attack: 200,
		defense: 30,
		special_attack: 20,
		special_defense: 30,
		speed: 30),
	effort_values_yield: Stats(	// are we even supposed to account for EV yield?
		hitpoints: 2,
		attack: 0,
		defense: 0,
		special_attack: 0,
		special_defense: 0,
		speed: 0)
)


// http://bulbapedia.bulbagarden.net/wiki/Nature
// let natureMultiplier: [Nature: Stats](
//
//)


struct Trainer {
    let party : [Pokemon]
}

struct Environment {
    var weather : Weather
    let terrain : Terrain
}

func typeToInt(type: Type) -> Int {
	//uses standard ordering
	switch type {
		case .normal: return 0
		case .fighting: return 1
		case .flying: return 2
		case .poison: return 3
		case .ground: return 4
		case .rock: return 5
		case .bug: return 6
		case .ghost: return 7
		case .steel: return 8
		case .fire: return 9
		case .water: return 10
		case .grass: return 11
		case .electric: return 12
		case .psychic: return 13
		case .ice: return 14
		case .dragon: return 15
		case .dark: return 16
		case .fairy: return 17
		// case nil: return -1	// ?????
		// default: return -2 //
	}

	/*
	/src/swift-exercises/Sources/swift_exercises.swift:326:3: warning: case will never be executed
				case nil: return -1     // ?????
				^
	*/

}

// http://bulbapedia.bulbagarden.net/wiki/Type/Type_chart
func typeModifier(attacking: Type, defending : (Type, Type?))-> Double {
    // TODO: encode type/type chart

	let attackingID: Int = typeToInt(type: attacking)
	let defendingID0: Int = typeToInt(type: defending.0)
	let defendingID1: Int
	if (defending.1 != nil){
		 defendingID1 = typeToInt(type: defending.1!) }
	else { defendingID1 = -1}

	let multiplierMatrix: [[Double]] = [
		[  1,  1,  1,  1,  1,0.5,  1,  0,0.5,  1,  1,  1,  1,  1,  1,  1,  1,  1], // normal
		[  2,  1,0.5,0.5,  1,  2,0.5,  0,  2,  1,  1,  1,  1,0.5,  2,  1,  2,0.5], // fighting
		[  1,  2,  1,  1,  1,0.5,  2,  1,0.5,  1,  1,  2,0.5,  1,  1,  1,  1,  1], // flying
		[  1,  1,  1,0.5,0.5,0.5,  1,0.5,  0,  1,  1,  2,  1,  1,  1,  1,  1,  2], // poison
		[  1,  1,  0,  2,  1,  2,0.5,  1,  2,  2,  1,0.5,  2,  1,  1,  1,  1,  1], // ground
		[  1,0.5,  2,  1,0.5,  1,  2,  1,0.5,  2,  1,  1,  1,  1,  2,  1,  1,  1], // rock
		[  1,0.5,0.5,0.5,  1,  1,  1,0.5,0.5,0.5,  1,  2,  1,  2,  1,  1,  2,0.5], // bug
		[  0,  1,  1,  1,  1,  1,  1,  2,  1,  1,  1,  1,  1,  2,  1,  1,0.5,  1], // ghost
		[  1,  1,  1,  1,  1,  2,  1,  1,0.5,0.5,0.5,  1,0.5,  1,  2,  1,  1,  2], // steel
		[  1,  1,  1,  1,  1,0.5,  2,  1,  2,0.5,0.5,  2,  1,  1,  2,0.5,  1,  1], // fire
		[  1,  1,  1,  1,  2,  2,  1,  1,  1,  2,0.5,0.5,  1,  1,  1,0.5,  1,  1], // water
		[  1,  1,0.5,0.5,  2,  2,0.5,  1,0.5,0.5,  2,0.5,  1,  1,  1,0.5,  1,  1], // grass
		[  1,  1,  2,  1,  0,  1,  1,  1,  1,  1,  2,0.5,0.5,  1,  1,0.5,  1,  1], // electric
		[  1,  2,  1,  2,  1,  1,  1,  1,0.5,  1,  1,  1,  1,0.5,  1,  1,  0,  1], // psychic
		[  1,  1,  2,  1,  2,  1,  1,  1,0.5,0.5,0.5,  2,  1,  1,0.5,  2,  1,  1], // ice
		[  1,  1,  1,  1,  1,  1,  1,  1,0.5,  1,  1,  1,  1,  1,  1,  2,  1,  0], // dragon
		[  1,0.5,  1,  1,  1,  1,  1,  2,  1,  1,  1,  1,  1,  2,  1,  1,0.5,0.5], // dark
		[  1,  2,  1,0.5,  1,  1,  1,  1,0.5,0.5,  1,  1,  1,  1,  1,  2,  2,  1] // fairy
	]

	if (defendingID1 != -1)
		{return ( Double(multiplierMatrix[attackingID][defendingID0])
		* Double(multiplierMatrix[attackingID][defendingID1]) )}
	else
		{return (multiplierMatrix[attackingID][defendingID0])}


}

// http://bulbapedia.bulbagarden.net/wiki/Damage
func damage(environment : Environment, pokemon: Pokemon, move: Move, target: Pokemon) -> Int {

	var STAB : Double = 1 // initialise with non-STAB multiplier value
	if ( (kangaskhan.type.0 == move.type) || (pokemon.type.1 == move.type) ) {STAB = 1.5}

	let typeBonus: Double = 1 // actually calculate this

	var critical: Double = 1 // initialise with non-crit mult value
	let randNum: Int = Int(drand48() * 257) // random int between 0 and 256 (included)
	let threshold: Int = Int(round(pokemon.base_values.speed / 2))
	if ( randNum < threshold)
		{critical = ( (2 * pokemon.level + 5) / (pokemon.level + 5) ) }

	let environmentBonus: Double = 1 // actually calculate this

	// drand48() returns a random double between 0 and 1
	// but randFactor should be uniformly distributed between 0.85 and 1
	let randFactor: Double = ((drand48() * 0.15) + 0.85)

	// assuming no items or abilities
	let modifier : Double = STAB * typeBonus * critical * environmentBonus * randFactor

	// TODO calculate actual damage
	let damage : Int = Int(modifier)	// and other stuff ......
    return damage
}

struct State {
    // TODO: describe a battle state
}


func battle(trainers: inout [Trainer], behavior: (State, Trainer) -> Move) -> () {

	// assume you can either fight or switch pokemon, but nothing more
	// struggle?????
	// no fancy effects and such, at least for now

    // TODO:
	// introductory blah blah
	// trainers send out the first respective pokemon
	// while both trainers have at least 1 non-KO pokemon:
		// display environment if relevant
		// trainers pick a move, or switch pokemon
			// pokemon: check it's valid and non-KO, priority 6
			// move: check that it's a valid move, and that it has PP left
		// check priority and speed to see who goes first
		// first to move
			// check status conditions, see if move can be executed (can always switch pokemon)
				// move changes weather?
					// y: set new weather
				// move changes pokemon stats?
					// y, first: set new first stats (self)
					// y, second: set new second stats
				// move deals damage?
					// calculate hit probability
						// calculate damage
						// deal damage to second
						// second (foe) KO?
							// y: opponent tries sending out another pokemon
							// n: move has status effects on second?	// check the order of these
								//y: apply status effects
						// deal recoil damage to first (self) if appropriate
							// self KO?
								// y: first tries sending out another pokemon
		// second KO? n:
			// check status conditions, see if move can be executed (can always switch pokemon)
				// move changes weather?
					// y: set new weather
				// move changes pokemon stats?
					// y, second: set new first stats (self)
					// y, first: set new second stats
				// move deals damage?
					// calculate hit probability
						// calculate damage
						// deal damage to first
						// first (foe) KO?
							// y: opponent tries sending out another pokemon
							// n: move has status effects on first?
								//y: apply status effects
						// deal recoil damage to second (self) if appropriate
							// self KO?
								// y: second tries sending out another pokemon
		// nonzero status conditions on either pokemon: apply effects
			// KO? try sending out another pokemon

}


func initialise() -> Int {
	// call other stuff here
	return 0
}
