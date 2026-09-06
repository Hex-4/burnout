extends CharacterBody2D

enum State {FREE, ATTACHED}

const SPEED = 100.0
const JUMP_VELOCITY = -300.0
const MAX_GRAPPLE_RANGE = 180
const ALIGNMENT_THRESHOLD = 0.7
const DISTANCE_WEIGHT = 0.3

var state := State.FREE
var attached_point: Node2D

func get_grapple_point() -> Node2D:
	var points: Array[Node] = get_tree().get_nodes_in_group("attachable")
	var aim_direction := (get_global_mouse_position() - position).normalized()
	var best_point: Node2D
	var best_score := 0.0
	for p: Node2D in points:
		var dir := (p.position - position).normalized()
		var alignment := aim_direction.dot(dir)
		var distance = position.distance_to(p.position)
		if distance > MAX_GRAPPLE_RANGE:
			continue
		var squashed_distance = distance / MAX_GRAPPLE_RANGE # squashes our distance value into a float 0-1 (same scale as the alignment score)
		var score = alignment - (DISTANCE_WEIGHT * squashed_distance) # fancy math! punishes anchors that are far away, proportionally to DISTANCE_WEIGHT
		if score > best_score:
			best_point = p
			best_score = score

		
	if best_point:
		return best_point
	else:
		return null  
	
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("grapple"):
		attached_point = get_grapple_point()
		if attached_point:
			(attached_point.get_node("Icon") as Sprite2D).modulate = Color("red")
	elif Input.is_action_just_released("grapple"):
		if attached_point:
			(attached_point.get_node("Icon") as Sprite2D).modulate = Color(1,1,1,1)
		attached_point = null
	
	if Input.is_action_pressed("grapple"):
		state = State.ATTACHED
	else:
		state = State.FREE
		attached_point = null
		
	
	
	if state == State.FREE:
		# Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * delta

		# Handle jump.
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction := Input.get_axis("left", "right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

		move_and_slide()
		
	if state == State.ATTACHED:
		if not is_on_floor():
			velocity += get_gravity() * delta
		
		
