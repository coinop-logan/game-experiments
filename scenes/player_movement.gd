extends CharacterBody2D

@export var SPEED = 100.0
@export var JUMP_VELOCITY_BASE_ADD = 100
@export var JUMPCHARGE_FULL_TIME_SEC = 1
@export var JUMPCHARGE_FULL_CHARGE_MULTIPLIER = 3

@onready var sprite = $AnimatedSprite2D

var jump_charging : bool
var charge_start_ms : int

# returns 0-1 indicating how "fully charged" the jump is.
# note other constraints may be ignored (is_on_floor for example). Read code before using willy nilly.
func get_jumpcharge_factor() -> float:
	if not jump_charging:
		return 0
	
	var charge_time_seconds = (Time.get_ticks_msec() - charge_start_ms) / 1000.0
	var charge_float = charge_time_seconds / JUMPCHARGE_FULL_TIME_SEC
	var charge_float_capped = min(1, charge_float) # enforces that we never go above a factor of 1.0
	
	print(charge_float_capped)
	return charge_float_capped

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump"):
		jump_charging = true
		charge_start_ms = Time.get_ticks_msec()
	
	# Handle jump.
	if Input.is_action_just_released("jump"):
		if is_on_floor():
			# determine multiplier. First, get factor (0-1) based on charge state:
			var factor = get_jumpcharge_factor()
			# turn this into a scale from 1 to JUMPCHARGE_FULL_CHARGE_MULTIPLIER to get actual multiplier
			var multiplier = 1 + (factor * (JUMPCHARGE_FULL_CHARGE_MULTIPLIER-1))
			var jump_velocity_add = JUMP_VELOCITY_BASE_ADD * multiplier
			velocity.y -= jump_velocity_add

		jump_charging = false
   
	# Get horizontal input (-1, 0, 1)
	var direction = Input.get_axis("move_left", "move_right")
	
	# Apply movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED) # Optional friction
	
	# --- 2. Animation Logic ---
	if direction != 0:
		$AnimatedSprite2D.flip_h = (direction > 0)
	
	if not is_on_floor():
		sprite.play("Falling")
	elif jump_charging:
		sprite.play("Squashed")
	elif velocity.length() > 10: # Small threshold to ignore sliding friction
		sprite.play("Moving") # Replace "walk" with your actual Aseprite animation tag/name
	else:
		sprite.play("Stationary") # Replace "idle" with your idle animation name
	
	move_and_slide()
