extends Marker2D

var enemy_scene: PackedScene = preload("uid://ba4r3drtgbxjk")
var flying_enemy_scene: PackedScene = preload("uid://cxmpdjjklg3t0")
var spawn_timer: Timer
@export var spawn_time: float = 10.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	call_deferred("_spawn_enemy")
	spawn_timer = Timer.new()

	spawn_timer.autostart = true
	spawn_timer.wait_time = spawn_time
	spawn_timer.timeout.connect(_spawn_enemy)
	
	add_child(spawn_timer)


func _spawn_enemy() -> void:
	if randi_range(0, 1) == 1:
		var enemy: CharacterBody2D = enemy_scene.instantiate() if randi_range(0, 1) == 1 else flying_enemy_scene.instantiate()
		enemy.global_position = global_position
		if not enemy is FlyingEnemy:
			enemy.enemy_color = [Globals.MaskColors.BLUEMASK, Globals.MaskColors.REDMASK, Globals.MaskColors.GREENMASK].pick_random()
		enemy.add_to_group("enemy")
		get_tree().get_first_node_in_group("level").add_child(enemy)
