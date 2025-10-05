extends Resource

class_name GemInfo

@export_enum("Silver Coin", "Gold Coin", "Ruby", "Emerald", "Diamond", "Multiplier Star", "Skull") var gem_name: String = "Silver Coin"
@export var sprite_frame: SpriteFrames = preload("res://gems/silver_coin.tres")
@export var point: int = 10
@export var extra_function_index: int = -1

var extra_function_list: Array[Callable] = [
	increase_base_multiplier,
	decrease_base_multiplier
]

func execute_extra_function(index: int):
	if index < 0: # negative index means no extra function
		return
	extra_function_list[index].call()
	
func increase_base_multiplier(amount: int = 1):
	Global.base_multiplier += amount

func decrease_base_multiplier(amount: int = 1):
	Global.base_multiplier -= amount
