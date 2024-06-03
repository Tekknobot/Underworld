extends CharacterBody2D


const SPEED = 100.0
const JUMP_VELOCITY = -200.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite = $AnimatedSprite2D
@onready var shape = $CollisionShape2D
@onready var weapon = $Weapon
@onready var hitbox = $Weapon/hitbox
@onready var camera = $"../Camera2D"

var player 
var _player

var is_attacking = false
var is_running = false
var is_jumping = false

var _direction = 0

var health_max = 1
var health_current = 1
var dead = false
var hit = false

var rng = RandomNumberGenerator.new()
var animate_once = false


func ready():
	pass

func _physics_process(delta):
	_player = get_tree().get_nodes_in_group("Player")
	player = _player[0]
		
	if player.dead == true:
		animated_sprite.play("idle")
		return	
		
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	if player.position.x > position.x and dead == false and is_attacking == false:
		_direction = 1
	elif player.position.x < position.x and dead == false and is_attacking == false:
		_direction = -1
			
	# Get input direction: -1 , 0 , 1
	# Get input direction: -1 , 0 , 1
	var direction = _direction
	#Flip sprite
	if direction > 0:
		animated_sprite.flip_h = false
		weapon.scale.x = 1
	elif direction < 0:
		animated_sprite.flip_h = true
		weapon.scale.x = -1
		
	#Play animation
	if is_on_floor() and is_attacking == false and dead == false and hit == false and is_attacking == false:		
		if direction == 0:
			animated_sprite.play("idle")
		else :
			animated_sprite.play("run")	
				
	if not is_on_floor() and dead == false:
		if velocity.y <= 0.0: # moving up
			animated_sprite.play("jump")
		elif velocity.y > 0.0 : # moving down
			animated_sprite.play("fall")
	
	if player.position.distance_to(position) < 35:
		if rng.randi_range(0, 1) == 0 and !animate_once:
			animated_sprite.play("attack_1")
			animate_once = true
		elif rng.randi_range(0, 1) == 1 and !animate_once:
			animated_sprite.play("attack_2")
			animate_once = true	
		if animated_sprite.get_frame() == 3:
			hitbox.disabled = false
		is_attacking = true	
		_direction = 0
		await animated_sprite.animation_finished
		is_attacking = false
		hitbox.disabled = true	
		animate_once = false
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func take_damage():
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:v", 1, 0.5).from(5)	
	health_current -= 1
	hit = true
	animated_sprite.play("hit")
	_direction = 0
	await animated_sprite.animation_finished
	hit = false
	if health_current <= 0:	
		_direction = 0
		dead = true
		animated_sprite.play("death")
		shape.disabled = true
		gravity = 0
		await animated_sprite.animation_finished
		self.queue_free()


func _on_weapon_body_entered(body):
	#amera.shake(0.1, 30, 3)
	if body.is_in_group("Player"):
		body.take_damage()
