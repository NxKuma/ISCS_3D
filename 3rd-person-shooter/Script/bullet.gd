extends Area3D


func _ready() -> void:
	set_as_top_level(true)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position -= transform.basis.x * 30 * delta

func _on_timer_timeout() -> void:
	queue_free()


func _on_body_entered(body: Node3D) -> void:
	if !body.is_in_group("Player"):
		queue_free()
