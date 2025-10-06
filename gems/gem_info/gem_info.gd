extends Resource

class_name GemInfo

@export_enum("Silver Coin", "Gold Coin", "Ruby", "Emerald", "Diamond", "Multiplier Star", "Skull", "Multi Hook", "Scope") var gem_name: String = "Silver Coin"
@export var sprite_frame: SpriteFrames = preload("res://gems/silver_coin.tres")
@export var point: int = 10
@export var extra_function_index: int = -1
@export var sprite_off_set: Vector2 = Vector2.ZERO
@export_enum("pickup_gem", "pickup_coin", "pickup_item", "explosion") var sfx_name: String

var extra_function_list: Array[Callable] = [
	increase_base_multiplier,
	remove_all_buffs,
	increase_max_hook_count,
	enable_scope
]

func execute_extra_function(index: int):
	if index < 0: # negative index means no extra function
		return
	extra_function_list[index].call()
	
func increase_base_multiplier(amount: int = 1):
	Global.base_multiplier += amount

func remove_all_buffs():
	EventBus.emit_signal("remove_all_buffs")

func increase_max_hook_count(amount: int = 2, time_sec: int = 10):
	Global.increase_max_hook_count(amount, time_sec)

func enable_scope(time_sec: int = 10):
	Global.enable_scope(time_sec)
