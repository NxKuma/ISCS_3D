extends Area3D

const GPU = preload("res://Scene/explode.tscn")

func _ready() -> void:
	set_as_top_level(true)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position -= transform.basis.x * 100 * delta

func _on_timer_timeout() -> void:
	queue_free()

func _on_body_entered(body: Node3D) -> void:
	if !body.is_in_group("Player"):
		set_process(false)
		print(global_position)
		var particle = GPU.instantiate()
		add_sibling(particle)
		particle.global_position = global_position
		particle.emitting = true
		queue_free()
