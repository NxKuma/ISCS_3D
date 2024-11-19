extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var pivot: Node3D = $CamOrigin
@onready var gun: MeshInstance3D = $DirMesh
@export var sens: float = 0.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sens))
		pivot.rotate_x(deg_to_rad(-event.relative.y * sens))
		pivot.rotation.x = clamp(pivot.rotation.x, deg_to_rad(-90), deg_to_rad(45))
		
func _physics_process(delta):
	
	#gun.rotate(pivot.get_child(0).get_child(0).target_position - gun.get_child(0).target_position,(pivot.get_child(0).get_child(0).target_position - gun.get_child(0).target_position).angle_to() )
	
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_pressed("aim"):
		pivot.position = pivot.position.lerp(Vector3(0.174,0.964,-0.95), 0.3)
	else:
		pivot.position = pivot.position.lerp(Vector3(0.174,0.964,0), 0.5)

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		var limit: int = 4
		if Input.is_action_pressed("run"):
			limit = 8
		#velocity.x = direction.x * SPEED
		velocity.x = move_toward(velocity.x, direction.x * limit, SPEED * 0.3 )
		velocity.z = move_toward(velocity.z, direction.z * limit, SPEED * 0.3 )
		#velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * 0.3)
		velocity.z = move_toward(velocity.z, 0, SPEED * 0.3)
	move_and_slide()
