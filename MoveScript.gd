extends Node2D

#Variables
var speed = 300
var direction = Vector2(1,0)

var screen_size = Vector2()
var window_size = Vector2(200,200)

var idle_timer = 0.0
var is_idling = false

var is_dragging = false
var drag_offset = Vector2()

@onready var animated_sprite = $Sans
@onready var area = $Area2D
@onready var label = $Label
@onready var popup_menu = $PopupMenu
@onready var timer = $Timer


# Sets conditions at the beginning of the program
func _ready():
	popup_menu.add_item("Quit",0)
	popup_menu.add_item("Talk",1)
	popup_menu.add_item("Travel", 2)
	screen_size = Vector2(DisplayServer.screen_get_size())
	animated_sprite.play("Walk")
	area.input_event.connect(_on_area_input)
	popup_menu.id_pressed.connect(_on_menu_pressed)
	timer.timeout.connect(say_something)
	
func _unhandled_input(event):
	if event is InputEventMouseButton and event.is_pressed() and event.double_click:
		print("Double click!")
		label.text = "Oh you clicked"
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed:
			popup_menu.popup_on_parent(Rect2i(Vector2i(event.position), Vector2i.ZERO))
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			label.text = "You Quit"
			get_tree().quit()
		elif event.pressed and event.keycode == KEY_H:
			label.text = "Click me for time!"
		elif event.pressed and event.keycode == KEY_P:
			timer.stop()
		elif event.pressed and event.keycode == KEY_R:
			timer.start()
		else:
			label.text = ""
			
func _on_menu_pressed(id):
	if id == 0:
		print("Quit Program")
		get_tree().quit()
	if id == 1:
		label.text = "I'm Sans"
	if id == 2:
		OS.shell_open("https://hackclub.com")

func say_something():
	await get_tree().create_timer(2.0).timeout
	label.text = "I'm Sans"

func _on_area_input(_viewport, event, _shape_idx):
	if event is InputEventMouseMotion:
		animated_sprite.flip_h = DisplayServer.mouse_get_position().x < DisplayServer.window_get_position().x + 100
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			var mouse_pos = Vector2(DisplayServer.mouse_get_position())
			var win_pos = Vector2(DisplayServer.window_get_position())
			drag_offset = mouse_pos - win_pos
			
			$AudioStreamPlayer2D.play()
			
			var time = Time.get_datetime_dict_from_system()
			label.text = "%02d:%02d" % [time.hour, time.minute]
			
		else:
			label.text = ""
			is_dragging = false
	
	
#Random Chance of Idle
func maybe_idle():
	if randf() <0.3:
		is_idling = true
		idle_timer = randf_range(1,3)
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
