extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@export var player: CharacterBody2D

const WALK_SPEED = 30
const RUN_SPEED = 60
const STOP_DISTANCE = 40
const FOLLOW_DISTANCE = 80
const DIAGONAL_TOLERANCE = 0.8

var last_dir: Vector2 = Vector2.DOWN

func _ready():
	# Optionnel : ajuster la navigation
	nav_agent.path_desired_distance = 8.0
	nav_agent.target_desired_distance = 4.0

func _physics_process(delta: float) -> void:
	if player == null:
		return

	var dist = global_position.distance_to(player.global_position)

	# Si le joueur est trop loin, on calcule une nouvelle destination
	if dist > STOP_DISTANCE:
		# Mets à jour la cible du NavigationAgent
		nav_agent.target_position = player.global_position

		# Si l’agent a un chemin valide
		if not nav_agent.is_navigation_finished():
			var next_pos = nav_agent.get_next_path_position()
			var dir = (next_pos - global_position).normalized()

			# Choix de la vitesse : courir ou marcher
			var speed = RUN_SPEED if dist > FOLLOW_DISTANCE else WALK_SPEED
			velocity = dir * speed
			move_and_slide()

			play_walk(dir)
			last_dir = dir
			queue_redraw()
	else:
		velocity = Vector2.ZERO
		play_stand(last_dir)

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
	# (Tu pourras plus tard ajuster pour idle_left, idle_right etc.)
	sprite.play("idle_down")
	
	
# -------------------------
# Debug : affichage du chemin
# -------------------------
var show_path_debug := false  # false pour désactiver

func _draw():
	if not show_path_debug:
		return
	
	var path = nav_agent.get_current_navigation_path()
	
	if path.size() > 1:
		for i in range(path.size() - 1):
			draw_line(to_local(path[i]), to_local(path[i + 1]), Color.YELLOW, 2)
