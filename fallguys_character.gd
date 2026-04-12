extends Node3D
class_name FallGuySkin

@export_group("Nodes")
@export var animation_player_path: NodePath = NodePath("AnimationPlayer")

@export_group("Animation Names")
@export var anim_idle      := "FG_Idle_A"
@export var anim_walk      := "FG_Walk_A"
@export var anim_run       := "FG_Run_A"
@export var anim_jump_start  := "FG_Jump_Start_A"
@export var anim_jump_midair := "FG_Jump_MidAir_A"
@export var anim_land      := "FG_Landing_A"
@export var anim_flag := "CH_Fallguy_FG_Emote_Mexwave"
@export var anim_show := "FG_Emote_Armthrow_A"

# After this many seconds standing still, play a random variant
@export var idle_variant_every := 3.0
# List of random idle animations to pick from
@export var idle_variants: PackedStringArray = [
	"FG_Idle_Qualification01_A",
	"FG_Idle_Qualification02_A",
	"FG_Idle_Qualification03_A"
]

@export_group("Tuning")
@export var blend_time     := 0.12
# If speed is below this, play idle animation
@export var walk_threshold := 0.2
# If speed is above this, play run animation
@export var run_threshold  := 4.0
# How fast the character rotates to face movement direction
@export var turn_speed     := 10.0

# Timer for when to play a random idle variant
var variant_timer := 0.0
var action_timer := 0.0
var is_playing_variant := false
var animation_player: AnimationPlayer
var current_animation := ""
var was_on_floor := true
var landing_timer := 0.0
var air_state := 0
var jump_timer := 0.0

func _ready() -> void:
	animation_player = get_node_or_null(animation_player_path)

	if animation_player == null:
		animation_player = find_child("AnimationPlayer", true, false) as AnimationPlayer

	if animation_player:
		play_animation(anim_idle)

func play_action_animation(anim_name: String, duration: float) -> void:
	action_timer = duration
	play_animation(anim_name)
	
# ─────────────────────────────────────────
# This function is called every frame from
# the main character script. It decides
# which animation to play based on what
# the character is doing.
#
# delta       = time since last frame
# move_dir    = direction the player is pushing
# velocity    = actual speed and direction moving
# on_floor    = is the character touching the ground?
# just_jumped = did the character just press jump?
# ─────────────────────────────────────────
func update_skin(delta: float, move_dir: Vector3, velocity: Vector3, on_floor: bool, just_jumped: bool) -> void:
	
	if action_timer > 0.0:
		action_timer -= delta
		return
		
	if animation_player == null:
		return

	# Rotate character to face the direction it is moving
	var flat_direction := Vector3(move_dir.x, 0.0, move_dir.z)
	if flat_direction.length() > 0.001:
		var target_angle := atan2(flat_direction.x, flat_direction.z)
		rotation.y = lerp_angle(rotation.y, target_angle, turn_speed * delta)

	var horizontal_speed := Vector2(velocity.x, velocity.z).length()

	# ── Just pressed jump ──
	if just_jumped:
		air_state = 1
		jump_timer = 0.0
		variant_timer = 0.0
		is_playing_variant = false
		was_on_floor = false
		play_animation(anim_jump_start)
		return

	# ── In the air ──
	if not on_floor:
		jump_timer += delta
		# After 0.1 seconds switch to midair falling loop
		if air_state == 1 and jump_timer > 0.1:
			air_state = 2
			play_animation(anim_jump_midair)
		was_on_floor = false
		return

	# ── Just landed ──
	if not was_on_floor:
		was_on_floor = true
		air_state = 0
		jump_timer = 0.0
		is_playing_variant = false
		play_animation(anim_land)
		landing_timer = 0.2
		return

	# ── Wait for landing animation to finish ──
	if landing_timer > 0.0:
		landing_timer -= delta
		return

	# ── On the ground ──
	if horizontal_speed <= walk_threshold:

		if is_playing_variant:
			if animation_player.is_playing():
				pass
			else:
				# Variant just finished - go back to idle and reset the full timer
				is_playing_variant = false
				variant_timer = 0.0
				play_animation(anim_idle)
		else:
			variant_timer += delta
			if variant_timer >= idle_variant_every:
				# Time to play a random idle variant
				variant_timer = 0.0
				is_playing_variant = true
				var random_pick := idle_variants[randi() % idle_variants.size()]
				play_animation(random_pick)
			else:
				play_animation(anim_idle)
	else:
		# Reset timers when moving
		variant_timer = 0.0
		is_playing_variant = false
		if horizontal_speed >= run_threshold:
			play_animation(anim_run)
		else:
			play_animation(anim_walk)

# ─────────────────────────────────────────
# Checks if an animation exists.
# Returns true if it does, false if not.
# ─────────────────────────────────────────
func has_animation(anim_name: String) -> bool:
	return animation_player != null and anim_name != "" and animation_player.has_animation(anim_name)


# ─────────────────────────────────────────
# Tries to find the real animation name.
# ─────────────────────────────────────────
func find_animation(requested_name: String) -> String:
	if animation_player == null or requested_name == "":
		return ""

	# Exact match found
	if animation_player.has_animation(requested_name):
		return requested_name

	# Search for an animation that ends with the requested name
	for anim_name in animation_player.get_animation_list():
		if anim_name.ends_with(requested_name):
			return anim_name

	# Nothing found
	return ""


# ─────────────────────────────────────────
# Plays an animation by name.
# If the same animation is already playing -> it does nothing (no interruption).
# ─────────────────────────────────────────
func play_animation(requested_name: String) -> void:
	var real_name := find_animation(requested_name)

	if real_name == "":
		push_warning('Animation not found: "%s"' % requested_name)
		return

	# Don't restart if already playing this animation
	if real_name == current_animation and animation_player.is_playing():
		return

	current_animation = real_name
	animation_player.play(real_name, blend_time)
