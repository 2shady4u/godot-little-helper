extends TextureButton

var is_mouse_inside : bool = false

func _ready():
	var _error : int = connect("mouse_entered", self, "_on_mouse_entered")
	_error = connect("mouse_exited", self, "_on_mouse_exited")

func _on_mouse_entered():
	is_mouse_inside = true

func _on_mouse_exited():
	is_mouse_inside = false
