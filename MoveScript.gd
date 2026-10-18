extends Node2D

#Problems to solve: How to make so that the character can move with the left click
# Optimize the code

#Variables
var speed = 300
var direction = Vector2(1,0)

var screen_size = Vector2()
var window_size = Vector2(200,200)

var idle_timer = 0.0
var is_idling = false

var is_dragging = false
var drag_offset = Vector2()


@onready var animated_sprite = $AnimatedSprite2D
@onready var area = $Area2D


func _on_area_input(_viewport, event, _shape_idx):
	
	if event is InputEventMouseMotion:
		$AnimatedSprite2D.flip_h = DisplayServer.mouse_get_position().x < DisplayServer.window_get_position().x + 100
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			var mouse_pos = Vector2(DisplayServer.mouse_get_position())
			var win_pos = Vector2(DisplayServer.window_get_position())
			drag_offset = mouse_pos - win_pos
			
			$AudioStreamPlayer2D.play()
			
			#OS.shell_open("https://hackclub.com")
			
			var time = Time.get_datetime_dict_from_system()
			$Label.text = "%02d:%02d" % [time.hour, time.minute]
			
		else:
			$Label.text = ""
			is_dragging = false
	
# Sets conditiosn at the beginning of the program
func _ready():
	screen_size = Vector2(DisplayServer.screen_get_size())
	animated_sprite.play("Walk")
	area.input_event.connect(_on_area_input)
#Random Chance of Idle
func maybe_idle():
	if randf() <0.3:
		is_idling = true
		idle_timer = randf_range(1,2)
		var r = randi() % 2
		if r == 0:
			animated_sprite.play("Idle")
			speed = 0

#Mangages movement and Animation 
func _physics_process(delta: float) -> void:
	if is_dragging:
		is_idling = false
		animated_sprite.stop()
		var mouse_pos = Vector2(DisplayServer.mouse_get_position())
		var new_win_pos = mouse_pos - drag_offset
		DisplayServer.window_set_position(Vector2i(new_win_pos))
		return
	else:
		animated_sprite.play("Walk")
		
	if is_idling:
		idle_timer -= delta
		if idle_timer <= 0:
			is_idling = false
			speed= 300
			animated_sprite.play("Walk")
		return
	var window_position = Vector2(DisplayServer.window_get_position())
	window_position += direction * speed * delta
	
	#print(window_position)
	#Encloses the sprite within your screen
	window_position.x = clamp(window_position.x, 0, screen_size.x -window_size.x)
	window_position.y = clamp(window_position.y, 0, screen_size.y -window_size.y)
	DisplayServer.window_set_position(Vector2i(window_position))
	
	if window_position.x <= 0 or window_position.x >= screen_size.x - window_size.x:
		direction.x *= -1
		animated_sprite.flip_h = !animated_sprite.flip_h
		maybe_idle()
	if window_position.y <= 0 or window_position.y >= screen_size.y - window_size.y:
		direction.y *= -1
		maybe_idle()
