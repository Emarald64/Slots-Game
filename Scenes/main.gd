extends Node2D

var coins:=100
var currentSlot:=3
var coinsToAdd:=0
var coinAddProgress:=0.0
var coinCountSpeed:=10.0
var maxMult:=1.0
var mult:=1.0
var luckySlipChance:=0.0
var justDidLuckySlip:=false

func _ready() -> void:
	$Button.grab_focus.call_deferred()
	$"Coin Display/Label".text=str(coins)
	if FileAccess.file_exists('save.bin'):loadSave()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("debug1"):
		addCoins(100)
	#Animate coin counter
	if coinsToAdd!=0:
		coinAddProgress+=delta
		if coinsToAdd>0:
			coins+=min(coinsToAdd,floori(coinAddProgress*coinCountSpeed))
			coinsToAdd-=min(coinsToAdd,floori(coinAddProgress*coinCountSpeed))
		else:
			coins+=max(coinsToAdd,-floori(coinAddProgress*coinCountSpeed))
			coinsToAdd-=max(coinsToAdd,-floori(coinAddProgress*coinCountSpeed))
		coinAddProgress=fmod(coinAddProgress,1.0/coinCountSpeed)
		$"Coin Display/Label".text=str(coins)
	else:coinAddProgress=0

func _on_stop_pressed() -> void:
	if $"Button Lockout".is_stopped():
		if currentSlot==3:
			#Restart slots
			if (coins+coinsToAdd)<10:
				$"Game Over".show()
			else:
				for i in range(3):
					get_node("Slots/Slot"+str(i)).startWithDelay(((2-i)/4.0)+randf_range(0,0.2))
				$Button.text='Stop'
				$"Button Lockout".wait_time=1.8
				currentSlot=0
				addCoins(-10)
		else:
			#Stop slot
			if currentSlot==2:
				$Button.text='Start'
				if randf()<luckySlipChance:justDidLuckySlip=$Slots/Slot2.luckyStop(partialScore())
				else:
					justDidLuckySlip=false
					$Slots/Slot2.stop()
			else:get_node("Slots/Slot"+str(currentSlot)).stop()
			$"Button Lockout".wait_time=1.5 if currentSlot==2 else 0.1
			currentSlot+=1
		$"Button Lockout".start()

func addCoins(ammount:int):
	$AnimationPlayer.play("Add Coins")
	if ammount<0:
		$"New Coins".add_theme_color_override("font_color",Color(1,0,0))
		$"New Coins".text=str(ammount)
	else:
		$"New Coins".add_theme_color_override("font_color",Color(0,1,0))
		$"New Coins".text="+"+str(ammount)
	coinsToAdd+=ammount
	coinCountSpeed=max(10.0,absf(coinsToAdd/2.0))

func scoreRow(icon:int) -> int:
	const iconScores=[100,100,100,100,-1,300,777,150,5,200]
	if icon==4:return randi_range(10,30)*10
	else:return iconScores[icon]

func score():
	var slots:=[]
	var newCoins:=0
	#Read the slots
	for i in range(3):
		slots.append(get_node("Slots/Slot"+str(i)).getVisibleIcons())
		
#	horazontals
	for i in range(3):
		if slots[0][i]==slots[1][i] and slots[0][i]==slots[2][i]:
			newCoins+=scoreRow(slots[0][i])
	
	#diagonals
	if slots[0][0]==slots[1][1] and slots[0][0]==slots[2][2]:
		newCoins+=scoreRow(slots[0][0])
	if slots[2][0]==slots[1][1] and slots[2][0]==slots[0][2]:
		newCoins+=scoreRow(slots[2][0])
	if newCoins>0:
		@warning_ignore("narrowing_conversion")
		addCoins(newCoins*mult)
		mult=min(maxMult,mult*2)
		if justDidLuckySlip:$AnimationPlayer.play("Lucky")
	else:
		mult=((mult-1)/2)+1
	if maxMult>1:updateMult()
	#save()
	
func partialScore() -> Vector2i:
	var slots:=[]
	var maxRowIcon:=8
	var maxRowLocation:=-1
	#Read the slots
	for i in range(2):
		slots.append(get_node("Slots/Slot"+str(i)).getVisibleIcons())
	#Horazonontals
	for i in range(3):
		if slots[0][i]==slots[1][i] and scoreRow(slots[0][i])>scoreRow(maxRowIcon):
			maxRowLocation=i
			maxRowIcon=slots[0][i]
			
	#Diagonals
	if slots[0][0]==slots[1][1] and scoreRow(slots[0][0])>scoreRow(maxRowIcon):
		maxRowLocation=2
		maxRowIcon=slots[0][0]
	if slots[0][2]==slots[1][1] and scoreRow(slots[0][2])>scoreRow(maxRowIcon):
		maxRowLocation=0
		maxRowIcon=slots[0][2]
	
	return Vector2i(maxRowLocation,maxRowIcon)
	
func updateMult():
	$"Max Mult".text='Max: x'+str(maxMult)
	$Mult.text="x"+str(floor(mult*100)/100.0)
	$Mult.add_theme_font_size_override("font_size",min(mult**0.5,6)*16)

func save():
	var save_file = FileAccess.open("user://save.bin", FileAccess.WRITE)
	if save_file==null:print("cant open save")
	save_file.store_32(coins+coinsToAdd)
	save_file.store_float(mult)
	save_file.store_csv_line($Shop.boughtItems)
	save_file.close()
	print('saved')
	
func loadSave():
	var save_file = FileAccess.open("user://save.bin", FileAccess.READ)
	if save_file==null:print("cant open save")
	coins=save_file.get_32()
	mult=save_file.get_float()
	$Shop.addItemsFromArray(save_file.get_csv_line())
	save_file.close()
	print('loaded')


func restart() -> void:
	get_tree().reload_current_scene()
