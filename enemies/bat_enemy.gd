extends CharacterBody2D

const DISTANCE_PLAYER = 30
const FLY_SPEED = 35
const INVULNERABLE_TIME = 0.3  # Durée d’invulnérabilité après un coup
const KNOCKBACK_FORCE = 200   # Force du recul, à ajuster
const FLASH_DURATION = 0.2     # Durée du flash rouge

@export var max_health: int = 2
var health: int = max_health
var invulnerable: bool = false
var is_knockback = false

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback = animation_tree.get("parameters/StateMachine/playback") as AnimationNodeStateMachinePlayback
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var area_2d: Area2D = $Area2D
@onready var flash_timer: Timer = Timer.new()
@onready var invuln_timer: Timer = Timer.new()
@onready var knockback_timer: Timer = Timer.new()

@export var player: Player

func _ready() -> void:
	add_child(flash_timer)
	add_child(invuln_timer)
	add_child(knockback_timer)

	flash_timer.wait_time = FLASH_DURATION
	flash_timer.one_shot = true
	flash_timer.timeout.connect(_on_flash_end)

	invuln_timer.wait_time = INVULNERABLE_TIME
	invuln_timer.one_shot = true
	invuln_timer.timeout.connect(_on_invuln_end)

	knockback_timer.wait_time = 0.2  # Durée du knockback visible
	knockback_timer.one_shot = true
	knockback_timer.timeout.connect(_end_knockback)

	area_2d.area_entered.connect(func(other_area_2d: Area2D):
		if other_area_2d.name.begins_with("Attack"):
			_take_damage(other_area_2d)
	)

func _take_damage(source: Area2D) -> void:
	if invulnerable:
		return

	health -= 1
	invulnerable = true
	_flash_red()
	invuln_timer.start()

	is_knockback = true
	knockback_timer.start()

	var dir = (global_position - source.global_position).normalized()
	velocity = dir * KNOCKBACK_FORCE
	move_and_slide()

	if health <= 0:
		queue_free()

func _flash_red() -> void:
	sprite_2d.modulate = Color(1, 0, 0)
	flash_timer.start()

func _on_flash_end() -> void:
	sprite_2d.modulate = Color(1, 1, 1)

func _on_invuln_end() -> void:
	invulnerable = false

func _end_knockback() -> void:
	is_knockback = false
	velocity = Vector2.ZERO

func _physics_process(delta: float) -> void:
	if is_knockback:
		# Pendant le knockback, on applique uniquement la vélocité de recul
		move_and_slide()
		return

	var state = playback.get_current_node()

	match state:
		"Idle": pass
		"Chase":
			nav_agent.target_position = player.global_position
			if not nav_agent.is_navigation_finished():
				var next_pos = nav_agent.get_next_path_position()
				var dir = (next_pos - global_position).normalized()
				sprite_2d.flip_h = dir.x < 0
				velocity = dir * FLY_SPEED
				move_and_slide()

func is_player_in_range() -> bool:
	var distance_to_player = global_position.distance_to(player.global_position)
	return distance_to_player < DISTANCE_PLAYER
