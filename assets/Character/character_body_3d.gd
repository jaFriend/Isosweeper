extends CharacterBody3D

# ─────────────────────────────────────────
# This is the main character script.
# It handles:
#   - Camera movement with the mouse
#   - Character movement (WASD + Shift to sprint)
#   - Jumping (Space)
#   - Telling the skin script what animation to play
# ─────────────────────────────────────────

@export_group("Camera")
@export_range(0.0, 1.0) var mouse_sensitivity := 0.2
@export var tilt_upper_limit := PI / 3.5
@export var tilt_lower_limit := 0.0

@export_group("Zoom")
@export var zoom_speed := 0.6
@export var min_arm_length := 2.0
@export var max_arm_length := 12.0

@export_group("Movement")
@export var walk_speed := 3.0
@export var sprint_speed := 7.0
@export var acceleration := 20.0
@export var rotation_speed := 12.0

@export_group("Jump")
@export var jump_force := 10.0

# ── Node references ──
@onready var camera_pivot: Node3D    = $CameraPivot
@onready var spring_arm: SpringArm3D = $CameraPivot/SpringArm3D
@onready var camera: Camera3D        = $CameraPivot/SpringArm3D/Camera3D
@onready var skin: FallGuySkin       = $FallguysCharacter

# Stores how much the mouse has moved since the last frame
var mouse_movement := Vector2.ZERO

var just_jumped := false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event: InputEvent) -> void:
	# Press ESC to release the mouse (so you can click outside the game)
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		return

	# Click the left mouse button to lock the mouse again
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

		if event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			spring_arm.spring_length = clamp(spring_arm.spring_length - zoom_speed, min_arm_length, max_arm_length)

		if event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			spring_arm.spring_length = clamp(spring_arm.spring_length + zoom_speed, min_arm_length, max_arm_length)

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		mouse_movement += event.relative * mouse_sensitivity


func _physics_process(delta: float) -> void:
	# ── Camera rotation ──
	# Tilt camera up/down (clamped so it doesn't flip)
	camera_pivot.rotation.x = clamp(
		camera_pivot.rotation.x - deg_to_rad(mouse_movement.y),
		tilt_lower_limit,
		tilt_upper_limit
	)
	# Rotate camera left/right
	camera_pivot.rotation.y -= deg_to_rad(mouse_movement.x)

	# Reset mouse movement after applying it
	mouse_movement = Vector2.ZERO

	# ── Movement ──
	var raw_input := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")

	# Convert input into 3D world directions based on where the camera is facing
	var forward := camera.global_transform.basis.z
	var right   := camera.global_transform.basis.x
	var move_direction := forward * raw_input.y + right * raw_input.x
	move_direction.y = 0.0
	move_direction = move_direction.normalized()

	# Use sprint speed if holding Shift, otherwise walk speed
	var current_speed := sprint_speed if Input.is_action_pressed("sprint") else walk_speed

	# Only move X and Z so gravity/jump on Y axis is not affected
	var target_velocity := move_direction * current_speed
	velocity.x = move_toward(velocity.x, target_velocity.x, acceleration * delta)
	velocity.z = move_toward(velocity.z, target_velocity.z, acceleration * delta)

	# ── Gravity ──
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	else:
		velocity.y = 0.0

	# ── Jump ──
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force
		just_jumped = true

	# Apply all movement and handle collisions
	move_and_slide()

	# Tell the skin script what is happening so it plays the right animation
	skin.update_skin(delta, move_direction, velocity, is_on_floor(), just_jumped)

	# Reset just_jumped so it is only true for one frame
	just_jumped = false
