extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var player: CharacterBody2D

const WALK_SPEED = 30
const RUN_SPEED = 60
const STOP_DISTANCE = 40       # distance mini → le chat s'arrête
const FOLLOW_DISTANCE = 80     # distance maxi → si le joueur est plus loin, le chat se met à courir
const DIAGONAL_TOLERANCE = 0.4

var last_dir: Vector2 = Vector2.DOWN

func _physics_process(delta: float) -> void:
	if player == null:
		return
	
	var to_player = player.global_position - global_position
	var dist = to_player.length()

	if dist > STOP_DISTANCE:
		var dir = to_player.normalized()
		
		# vitesse variable : walk si proche, run si loin
		var speed = RUN_SPEED if dist > FOLLOW_DISTANCE else WALK_SPEED
		velocity = dir * speed
		
		play_walk(dir)
		last_dir = dir
	else:
		velocity = Vector2.ZERO
		play_stand(last_dir)

	move_and_slide()

# -------------------------
# Animations
# -------------------------

func play_walk(dir: Vector2):
	var axis_x = abs(dir.x)
	var axis_y = abs(dir.y)

	if abs(axis_x - axis_y) < DIAGONAL_TOLERANCE:
		dir = last_dir

	if abs(dir.x) > abs(dir.y):
		if dir.x < 0:
			sprite.play("walk_left")
		else:
			sprite.play("walk_right")
	else:
		if dir.y < 0:
			sprite.play("walk_up")
		else:
			sprite.play("walk_down")

func play_stand(dir: Vector2):
	if abs(dir.x) > abs(dir.y):
		if dir.x < 0:
			sprite.play("idle_down")
		else:
			sprite.play("idle_down")
	else:
		if dir.y < 0:
			sprite.play("idle_down")
		else:
			sprite.play("idle_down")
