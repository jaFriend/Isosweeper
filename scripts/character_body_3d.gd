extends CharacterBody3D

@export_group("Camera")
@export_range(0.0, 1.0) var mouse_sensitivity := 0.2
@export var tilt_upper_limit := PI / 4.0
@export var tilt_lower_limit := PI / 4.0

@export_group("Zoom")
@export var zoom_speed := 0.4
@export var min_arm_length := 3.0
@export var max_arm_length := 5.0

@export_group("Movement")
@export var walk_speed := 1.0
@export var sprint_speed := 4.0
@export var acceleration := 20.0

@export_group("Jump")
@export var jump_force := 5.0

@export_group("SFX")
@export var sfx_reveal: AudioStream
@export var sfx_flag: AudioStream

@onready var camera_pivot: Node3D             = $CameraPivot
@onready var spring_arm: SpringArm3D          = $CameraPivot/SpringArm3D
@onready var camera: Camera3D                 = $CameraPivot/SpringArm3D/Camera3D
@onready var skin: FallGuySkin                = $FallguysCharacter
@onready var footstep_player: AudioStreamPlayer3D = $FootstepPlayer
@onready var sfx_player: AudioStreamPlayer3D      = $SFXPlayer

var footstep_sounds: Array[AudioStream] = []
var footstep_timer := 0.0
var mouse_movement := Vector2.ZERO
var just_jumped := false


func _ready() -> void:
	call_deferred("_capture_mouse")
	GameEvents.game_over.connect(_on_game_over)
	spring_arm.spring_length = self.max_arm_length
	footstep_sounds = [
		load("res://assets/audio/Footstep Snow 01.mp3"),
		load("res://assets/audio/Footstep Snow 02.mp3"),
		load("res://assets/audio/Footstep Snow 03.mp3"),
		load("res://assets/audio/Footstep Snow 04.mp3"),
		load("res://assets/audio/Footstep Snow 05.mp3"),
		load("res://assets/audio/Footstep Snow 06.mp3"),
		load("res://assets/audio/Footstep Snow 07.mp3"),
	]

func _on_game_over() -> void:
	skin.play_action_animation("FG_Emote_WaveOverHead_A", 2.0)
	
func _capture_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			spring_arm.spring_length = clamp(spring_arm.spring_length - zoom_speed, min_arm_length, max_arm_length)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			spring_arm.spring_length = clamp(spring_arm.spring_length + zoom_speed, min_arm_length, max_arm_length)

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		mouse_movement += event.relative * mouse_sensitivity


func _physics_process(delta: float) -> void:
	if skin.action_timer > 0.0:
		var cancel_input := Input.get_vector("movement_left", "movement_right", "movement_forwards", "movement_backwards")
		if cancel_input != Vector2.ZERO or Input.is_action_just_pressed("movement_jump"):
			skin.action_timer = 0.0

	camera_pivot.rotation.x = clamp(
		camera_pivot.rotation.x - deg_to_rad(mouse_movement.y),
		tilt_lower_limit,
		tilt_upper_limit
	)
	camera_pivot.rotation.y -= deg_to_rad(mouse_movement.x)
	mouse_movement = Vector2.ZERO

	var raw_input := Input.get_vector("movement_left", "movement_right", "movement_forwards", "movement_backwards")
	if skin.action_timer > 0.0:
		raw_input = Vector2.ZERO

	var forward := camera.global_transform.basis.z
	var right := camera.global_transform.basis.x
	var move_direction := (forward * raw_input.y + right * raw_input.x)
	move_direction.y = 0.0
	move_direction = move_direction.normalized()

	var current_speed := sprint_speed if Input.is_action_pressed("movement_sprint") else walk_speed
	var target_velocity := move_direction * current_speed
	velocity.x = move_toward(velocity.x, target_velocity.x, acceleration * delta)
	velocity.z = move_toward(velocity.z, target_velocity.z, acceleration * delta)

	if not is_on_floor():
		velocity.y -= 9.8 * delta
	else:
		velocity.y = 0.0

	if Input.is_action_just_pressed("movement_jump") and is_on_floor():
		velocity.y = jump_force
		just_jumped = true

	move_and_slide()

	skin.update_skin(delta, move_direction, velocity, is_on_floor(), just_jumped)
	just_jumped = false

	var horizontal_speed := Vector2(velocity.x, velocity.z).length()
	if is_on_floor() and horizontal_speed > 0.2:
		footstep_timer -= delta
		if footstep_timer <= 0.0:
			footstep_timer = 0.5 if horizontal_speed < 4.0 else 0.3
			footstep_player.stream = footstep_sounds[randi() % footstep_sounds.size()]
			footstep_player.play()
	else:
		footstep_timer = 0.0

#TODO(Joseph): Increase animation speed. Too slow.

	var grid_pos := _get_tile_in_front()
	if Input.is_action_just_pressed("input_selection") and grid_pos != Vector2i(-1, -1) and GameEvents.mouse_captured:
		skin.play_action_animation(skin.anim_show, 2.0)
		if sfx_reveal:
			sfx_player.stream = sfx_reveal
			sfx_player.play()
		GameEvents.player_send_mine_signal.emit(grid_pos)

	if Input.is_action_just_pressed("input_second_selection") and grid_pos != Vector2i(-1, -1) and GameEvents.mouse_captured:
		skin.play_action_animation(skin.anim_flag, 2.0)
		if sfx_flag:
			sfx_player.stream = sfx_flag
			sfx_player.play()
		GameEvents.player_send_flag_signal.emit(grid_pos)


func _get_tile_in_front() -> Vector2i:
	var space_state := get_world_3d().direct_space_state
	
	var look_distance := 3.0
	var forward := skin.global_transform.basis.z.normalized()
	var ray_start := global_position + Vector3(0, 1.0, 0)
	var ray_end := ray_start + (forward * look_distance) + Vector3(0, -4.0, 0)
	var query := PhysicsRayQueryParameters3D.create(
		ray_start,
		ray_end
	)


	query.collision_mask = 2
	query.exclude = [self]
	var result := space_state.intersect_ray(query)
	if not result:
		return Vector2i(-1, -1)


	var tiles_grid_map := get_node("../TilesGridMap")
	var map_pos: Vector3i = tiles_grid_map.local_to_map(tiles_grid_map.to_local(result.position))
	var target := Vector3i(map_pos.x, 0, map_pos.z)

	tiles_grid_map.update_selection(target)
	return Vector2i(target.x, target.z)
