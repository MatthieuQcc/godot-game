extends CharacterBody2D

const SPEED = 50
const STOP_DISTANCE = 30   # distance mini entre le chat et le joueur

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var player: NodePath

func _physics_process(delta: float) -> void:
	var target = get_node(player) as CharacterBody2D
	if target == null:
		return
	
	# Direction vers le joueur
	var direction = target.global_position - global_position
	var distance = direction.length()

	if distance > STOP_DISTANCE:
		# Avancer vers le joueur
		velocity = direction.normalized() * SPEED
		play_walk(direction)
	else:
		velocity = Vector2.ZERO
		play_idle()

	move_and_slide()

# ------------------
# Animations
# ------------------

func play_walk(dir: Vector2):
	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			sprite.play("walk_right")
		else:
			sprite.play("walk_left")
	else:
		if dir.y > 0:
			sprite.play("walk_down")
		else:
			sprite.play("walk_up")

func play_idle():
	sprite.play("idle_down") # ou idle selon la dernière direction
