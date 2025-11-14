extends CharacterBody2D

const DISTANCE_PLAYER = 30
const FLY_SPEED = 20

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback = animation_tree.get("parameters/StateMachine/playback") as AnimationNodeStateMachinePlayback
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var area_2d: Area2D = $Area2D

@export var player: Player

func _ready() -> void:
	area_2d.area_entered.connect(func(other_area_2d: Area2D):
		if other_area_2d.name.begins_with("Attack"):
			queue_free()
	)
		


func _physics_process(delta: float) -> void:
	var state = playback.get_current_node()

	match state:
		"Idle": pass
		"Chase": 
			# Mets à jour la cible du NavigationAgent
			nav_agent.target_position = player.global_position

			# Si l’agent a un chemin valide
			if not nav_agent.is_navigation_finished():
				var next_pos = nav_agent.get_next_path_position()
				var dir = (next_pos - global_position).normalized()

				# Flip horizontal si le joueur est à gauche
				if dir.x < 0:
					sprite_2d.flip_h = true
				elif dir.x > 0:
					sprite_2d.flip_h = false

				# Choix de la vitesse : courir ou marcher
				velocity = dir * FLY_SPEED
				move_and_slide()

func is_player_in_range() -> bool:
	# return true si le player est dans la range de la bat
	var distance_to_player = global_position.distance_to(player.global_position)
	return distance_to_player < DISTANCE_PLAYER
	
