extends Control
onready var button = $TextureRect/TextureButton


func _ready():
	button.connect("pressed", self, "_on_button_pressed")


func _on_TextureButton_pressed():
	queue_free()
