extends MeshInstance3D

@onready var progress_bar: ProgressBar = $SubViewport/ProgressBar
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
		queue_free()
