extends CharacterBody2D

const WALK_SPEED = 40
const RUN_SPEED = 70  # vitesse plus rapide quand on court

var input_vector := Vector2.ZERO
var last_input_vector := Vector2.DOWN
var is_attacking := false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(_delta: float) -> void:
	# Si on est en attaque → on bloque les inputs
	if is_attacking:
		return

	input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var is_running = Input.is_action_pressed("run")
	var speed = WALK_SPEED
	if is_running:
		speed = RUN_SPEED

	# --- Attaque ---
	if Input.is_action_just_pressed("attack"):
		play_attack()
		return


	# --- Déplacement ---
	if input_vector != Vector2.ZERO:
		last_input_vector = input_vector
		velocity = input_vector * speed
		play_move(input_vector, is_running)
	else:
		velocity = Vector2.ZERO
		play_stand()

	move_and_slide()


# -------------------------
# Animations
# -------------------------

func play_move(dir: Vector2, is_running: bool):
	var prefix = "walk_"
	if is_running:
		prefix = "run_"
	if dir.x < 0:
		sprite.play(prefix + "left")
	elif dir.x > 0:
		sprite.play(prefix + "right")
	elif dir.y < 0:
		sprite.play(prefix + "up")
	else:
		sprite.play(prefix + "down")


func play_stand():
	if last_input_vector.x < 0:
		sprite.play("stand_left")
	elif last_input_vector.x > 0:
		sprite.play("stand_right")
	elif last_input_vector.y < 0:
		sprite.play("stand_up")
	else:
		sprite.play("stand_down")


func play_attack():
	is_attacking = true
	if last_input_vector.x < 0:
		sprite.play("attack_left")
	elif last_input_vector.x > 0:
		sprite.play("attack_right")
	elif last_input_vector.y < 0:
		sprite.play("attack_up")
	else:
		sprite.play("attack_down")


# -------------------------
# Callback fin d'anim
# -------------------------

func _on_animated_sprite_2d_animation_finished():
	if sprite.animation.begins_with("attack"):
		is_attacking = false
		play_stand()
