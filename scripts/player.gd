extends CharacterBody2D

enum State {FREE, ATTACHED}

const SPEED = 100.0
const JUMP_VELOCITY = -250.0
const MAX_GRAPPLE_RANGE = 180
const ALIGNMENT_THRESHOLD = 0.7
const DISTANCE_WEIGHT = 0.3
const GRAPPLE_NUDGE_SPEED = 150
const GRAVITY = 700.0
const AIR_STEER_MULT = 1
const REEL_SPEED = 70
const MIN_ROPE_LENGTH = 40

var state := State.FREE
var attached_point: Node2D
var rope_length: float
var after_grapple := false

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
	var point = get_grapple_point()
	
	if position.y > 250:
		position = Vector2(155, 135)
		attached_point = null
		state = State.FREE
	
	if Input.is_action_just_pressed("grapple"):
		attached_point = point
		if attached_point:
			(attached_point.get_node("Icon") as Sprite2D).modulate = Color("red")
			rope_length = position.distance_to(attached_point.position)
	elif Input.is_action_just_released("grapple"):
		after_grapple = true
		if attached_point:
			(attached_point.get_node("Icon") as Sprite2D).modulate = Color(1,1,1,1)
		attached_point = null
		rope_length = 0
	
	if Input.is_action_pressed("grapple"):
		if attached_point != null:
			state = State.ATTACHED
		if (len($Line2D.points) > 1):
			$Line2D.remove_point(1)
		if attached_point:
			$Line2D.add_point(attached_point.position - position)
		
	else:
		if len($Line2D.points) > 1:
			$Line2D.remove_point(1)
		state = State.FREE
		attached_point = null
		
	if is_on_floor() and after_grapple:
		after_grapple = false
	
	
	if state == State.FREE:
		# In the air:
		if not is_on_floor() and after_grapple:
			velocity += Vector2.DOWN * GRAVITY * delta
			
			var direction := Input.get_axis("left", "right")
			
			if direction:
				if velocity.x * direction <= SPEED:
					velocity.x = move_toward(velocity.x, SPEED * direction, SPEED * AIR_STEER_MULT * delta)
			
			move_and_slide()
		elif not is_on_floor():
			velocity += Vector2.DOWN * GRAVITY * delta
			
			var direction := Input.get_axis("left", "right")
			
			if direction:
				velocity.x = direction * SPEED
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
			
			move_and_slide()
		# On the ground.
		else:
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
			velocity += Vector2.DOWN * GRAVITY * delta
			
		if Input.is_action_pressed("jump"): # reel in if so
			rope_length = max(MIN_ROPE_LENGTH, rope_length - REEL_SPEED * delta)

		var input_direction := Input.get_axis("left", "right")
		var forwards_on_circle = (attached_point.position - position).rotated(deg_to_rad(90)).normalized()

		velocity += input_direction * forwards_on_circle * GRAPPLE_NUDGE_SPEED * delta


		var predicted = position + velocity * delta
		
		# constrain prediction onto a circle with radius rope_length
		
		var target = attached_point.position + (predicted - attached_point.position).normalized() * rope_length
		
		velocity = (target - position) / delta
		
		move_and_slide()
		
