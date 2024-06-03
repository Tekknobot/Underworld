extends Node2D

var enemy = preload("res://assets/scenes/enemy.scn")
@onready var spawn_left = $"../SpawnLeft"
@onready var spawn_right = $"../SpawnRight"

@onready var GameNode = $"."

var rng = RandomNumberGenerator.new()
var spawn_point

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func spawn():
	var enemy_inst = enemy.instantiate()
	GameNode.add_child(enemy_inst)
	enemy_inst.add_to_group("enemies")	
	enemy_inst.add_to_group("alive")
	enemy_inst.modulate = Color8(255, 155, 0)		
	if rng.randi_range(0, 1) == 0:
		spawn_point = spawn_left.position
		enemy_inst._direction = 1
	else:
		spawn_point = spawn_right.position
		enemy_inst._direction = -1
		
	enemy_inst.position = spawn_point
	var tween: Tween = create_tween()


func _on_timer_timeout():
	var total_enemies = get_tree().get_nodes_in_group("enemies")
	if total_enemies.size() > 2:
		return
	else:
		spawn()
