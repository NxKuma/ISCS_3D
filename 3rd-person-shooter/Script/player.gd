extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const PROJECTILE = preload("res://Scene/bullet.tscn")
var shoulder_swap = "parameters/shoulder_swap/blend_amount"
var aim_shoulder_right = "parameters/aim_shoulder_right/blend_amount"
var aim_shoulder_left = "parameters/aim_shoulder_left/blend_amount"
var shoulder = 1.0 #1 for s-right, 0 for s,left
var aiming = 1.0 #1 for regular, 0 for ADS


@onready var pivot = $CamOrigin
@onready var spring_arm_3d: SpringArm3D = $CamOrigin/SpringArm3D
@onready var mark: Marker3D = $CamOrigin/SpringArm3D/RayCast3D/Marker3D
@onready var gun: MeshInstance3D = $DirMesh
@onready var gun_dir: Marker3D = $DirMesh/Marker3D
@onready var shoot_time: Timer = $DirMesh/ShootTime
@export var sens: float = 0.3
@onready var pew_sfx: AudioStreamPlayer3D = $PewSFX

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var can_shoot = true

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sens))
		pivot.rotate_x(deg_to_rad(-event.relative.y * sens))
		pivot.rotation.x = clamp(pivot.rotation.x, deg_to_rad(-90), deg_to_rad(45))
		
func _physics_process(delta):
	
	safe_look_at(gun,mark.global_transform.origin)
	
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("aim"):
		aiming *= -1
		#spring_arm_3d.position = spring_arm_3d.position.lerp(Vector3(0.174,0.964,-0.628), 0.3)
	#else:
		#spring_arm_3d.position = spring_arm_3d.position.lerp(Vector3(0.174,0.964,0.628), 0.5)
		#pivot.position = pivot.position.lerp(Vector3(0.174,0.964,-0.628), 0.3)
	#else:
		#pivot.position = pivot.position.lerp(Vector3(0.174,0.964,0.628), 0.5)

	if Input.is_action_just_pressed("shoot") and can_shoot:
		shoot()

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
		
	if Input.is_action_just_pressed("switchcam"):
		shoulder *= -1
			
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		var limit: int = 4
		if Input.is_action_pressed("run"):
			limit = 8
		velocity.x = move_toward(velocity.x, direction.x * limit, SPEED * 0.3 )
		velocity.z = move_toward(velocity.z, direction.z * limit, SPEED * 0.3 )
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * 0.3)
		velocity.z = move_toward(velocity.z, 0, SPEED * 0.3)

	$CamTree.set(shoulder_swap, lerp($CamTree.get(shoulder_swap), shoulder, delta*7))
	
	if aiming:
		if $CamTree.get(shoulder_swap) > 0.5:
			$CamTree.set(aim_shoulder_right, lerp($CamTree.get(aim_shoulder_right), aiming, delta*7))
		elif $CamTree.get(shoulder_swap) < -0.5:
			$CamTree.set(aim_shoulder_left, lerp($CamTree.get(aim_shoulder_left), aiming, delta*7))
	

	move_and_slide()

func safe_look_at(node : Node3D, target : Vector3) -> void:
	var origin : Vector3 = node.global_transform.origin
	var v_z := (origin - target).normalized()

	# Just return if at same position
	if origin == target:
		return

	# Find an up vector that we can rotate around
	var up := Vector3.ZERO
	for entry in [Vector3.UP, Vector3.RIGHT, Vector3.BACK]:
		var v_x : Vector3 = entry.cross(v_z).normalized()
		if v_x.length() != 0:
			up = entry
			break

	# Look at the target
	if up != Vector3.ZERO:
		node.look_at(target, up)
		

func shoot() -> void:
	can_shoot = false
	shoot_time.start()
	pew_sfx.play()
	var b = PROJECTILE.instantiate()
	#b.rotation_degrees = gun.global_transform.basis.get_euler()
	safe_look_at(b,mark.global_transform.origin)
	gun_dir.add_child(b)

func _on_shoot_time_timeout() -> void:
	can_shoot = true
