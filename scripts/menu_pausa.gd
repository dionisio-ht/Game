extends Control

func _ready() -> void:
	hide()

func resume():
	get_tree().paused = false
	hide()

func pause():
	get_tree().paused = true
	show()

func testEsc():
	if Input.is_action_just_pressed("pausa") and !get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("pausa") and get_tree().paused:
		resume()

#func _on_resume_pressed():
	#resume()

#func _on_restart_pressed():
	#get_tree().reload_current_scene()

#func _on_quit_pressed():
	#get_tree().quit()


func _on_button_pressed() -> void:
	resume()


func _on_button_2_pressed() -> void:
	resume()
	get_tree().reload_current_scene()
	

func _on_button_3_pressed() -> void:
	get_tree().quit()

func _process(delta):
	testEsc()
