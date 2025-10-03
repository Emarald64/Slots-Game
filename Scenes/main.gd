extends Node2D

var coins:=0
var currentSlot:=0


func _on_stop_pressed() -> void:
	if $"Button Lockout".is_stopped():
		if currentSlot==3:
			print('start')
			for i in range(3):
				get_node("Slots/Slot"+str(i)).startWithDelay((i/5.0)+randf_range(0,0.15))
			$Button.text='Stop'
			$"Button Lockout".wait_time=1.8
			currentSlot=0
		else:
			get_node("Slots/Slot"+str(currentSlot)).stop()
			if currentSlot==2:
				$Button.text='Start'
			$"Button Lockout".wait_time=1.5 if currentSlot==2 else 0.1
			currentSlot+=1
		$"Button Lockout".start()

func score():
	for i in range(3):
		print("slot "+str(i)+" "+str(get_node("Slots/Slot"+str(i)).getVisibleIcons()))
