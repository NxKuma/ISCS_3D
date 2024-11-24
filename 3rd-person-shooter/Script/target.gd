extends MeshInstance3D

@onready var progress_bar: ProgressBar = $SubViewport/ProgressBar

const GPU = preload("res://Scene/explode.tscn")

var hp = 5


func _ready():
	progress_bar.visible = false


func _process(delta):
	if hp < 5:
		progress_bar.visible = true


func _on_hurtbox_area_entered(area: Area3D) -> void:
	hp -= 1
	progress_bar.value -= 1
	if hp <= 0:
		var particle = GPU.instantiate()
		particle.process_material.scale_min = 5
		particle.process_material.scale_max = 7
		add_sibling(particle)
		particle.global_position = global_position
		particle.emitting = true
		queue_free()
