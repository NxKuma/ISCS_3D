extends GPUParticles3D

func _ready() -> void:
	print(global_position)

func _on_finished() -> void:
	queue_free()
