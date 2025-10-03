extends Node2D

var coins:=10
var currentSlot:=0
var coinsToAdd:=0
var coinAddProgress:=0.0
var coinCountSpeed:=10.0

func _process(delta: float) -> void:
	#Animate coin counter
	if coinsToAdd>0:
		coinAddProgress+=delta
		coins+=min(coinsToAdd,floori(coinAddProgress*coinCountSpeed))
		coinsToAdd-=min(coinsToAdd,floori(coinAddProgress*coinCountSpeed))
		coinAddProgress=fmod(coinAddProgress,1.0/coinCountSpeed)
		$"Coin Display/Label".text=str(coins)
	else:coinAddProgress=0

func _on_stop_pressed() -> void:
	if $"Button Lockout".is_stopped():
		if currentSlot==3:
			print('start')
			for i in range(3):
				get_node("Slots/Slot"+str(i)).startWithDelay((i/5.0)+randf_range(0,0.15))
			$Button.text='Stop'
			$"Button Lockout".wait_time=1.8
			currentSlot=0
			coins-=1
			$"Coin Display/Label".text=str(coins)
		else:
			get_node("Slots/Slot"+str(currentSlot)).stop()
			if currentSlot==2:
				$Button.text='Start'
			$"Button Lockout".wait_time=1.5 if currentSlot==2 else 0.1
			currentSlot+=1
		$"Button Lockout".start()

func addCoins(ammount:int):
	$AnimationPlayer.play("Add Coins")
	$"New Coins".text="+"+str(ammount)
	coinsToAdd+=ammount
	coinCountSpeed=max(10.0,ammount/2.0)

func scoreRow(icon:int) -> int:
	const iconScores=[10,10,10,10,-1,30,777,15,5,20]
	if icon==4:return randi_range(5,20)
	else:return iconScores[icon]

func score():
	var slots:=[]
	var newCoins:=0
	#addCoins(10)
	for i in range(3):
		slots.append(get_node("Slots/Slot"+str(i)).getVisibleIcons())
	print(slots)
#	horazontals
	for i in range(3):
		if slots[0][i]==slots[1][i] and slots[0][i]==slots[2][i]:
			newCoins+=scoreRow(slots[0][i])
	
	#diagonals
	if slots[0][0]==slots[1][1] and slots[0][0]==slots[2][2]:
		newCoins+=scoreRow(slots[0][0])
	if slots[2][0]==slots[1][1] and slots[2][0]==slots[0][2]:
		newCoins+=scoreRow(slots[2][0])
	addCoins(newCoins)
