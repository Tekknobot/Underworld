extends CharacterBody2D


var SPEED = 200.0
const JUMP_VELOCITY = -300.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite = $AnimatedSprite2D
@onready var weapon = $Weapon
@onready var hitbox = $Weapon/hitbox
@onready var shape = $CollisionShape2D

@onready var camera = $"../Camera2D"

var is_attacking = false
var attack_2 = false
var is_running = false
var is_jumping = false
var is_rolling = false

var _direction = 0

var comboTimeWindow: float = 0.5
var lastAttack

var rng = RandomNumberGenerator.new()
var animate_once = false

var roll_amount = 35
var health_max = 10
var health_current = 10
var dead = false
var hit = false

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle attack.
	if Input.is_action_just_pressed("attack") and is_on_floor() and dead == false:	
		is_attacking = true		

	# Handle roll.
	if Input.is_action_just_pressed("roll") and is_on_floor() and dead == false:	
		is_rolling = true				
			
	if is_on_floor() and is_attacking == false and is_rolling == false and dead == false:
		_direction = Input.get_axis("move_left", "move_right")	
	elif is_on_floor() and is_attacking == true:
		_direction = 0
		
		
	if is_on_floor() and is_rolling == false and dead == false:
		pass
	elif is_on_floor() and is_rolling == true and dead == false:
		_direction = 0
		if animated_sprite.flip_h == false:
			position = position.lerp(Vector2(position.x+roll_amount, position.y), 0.1)
		else:
			position = position.lerp(Vector2(position.x-roll_amount, position.y), 0.1)	
			
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
	if is_on_floor() and is_attacking == false and is_rolling == false and dead == false:		
		if direction == 0:
			animated_sprite.play("idle")
		else :
			animated_sprite.play("run")	
			
	if is_on_floor() and is_attacking == true and is_rolling == false and dead == false:
		if rng.randi_range(0, 1) == 0 and !animate_once:
			animated_sprite.play("attack_1")
			animate_once = true
		elif rng.randi_range(0, 1) == 1 and !animate_once:
			animated_sprite.play("attack_2")
			animate_once = true	
		if animated_sprite.get_frame() == 3:
			hitbox.disabled = false
		await animated_sprite.animation_finished
		is_attacking = false
		hitbox.disabled = true	
		animate_once = false
	
	if is_on_floor() and is_rolling == true and dead == false:
		animated_sprite.play("roll")
		shape.disabled = true
		await animated_sprite.animation_finished
		shape.disabled = false
		is_rolling = false
				
	if not is_on_floor() and dead == false:
		if velocity.y <= 0.0: # moving up
			animated_sprite.play("jump")
		elif velocity.y > 0.0 : # moving down
			animated_sprite.play("fall")
	
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
		#self.queue_free()
		
func _on_weapon_body_entered(body):
	camera.shake(0.1, 30, 3)
	body.take_damage()
