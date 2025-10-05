extends PanelContainer

enum affect {spinSpeed, slotSlipping, sevenCount, maxMult, luckySlipChance, lastSlotSpeed}
enum icons {HEART,DIAMOND,CLUB,SPADE,DIE,GEM,SEVEN,ORANGE,BAR,STAR}

const shopItems={
	"Chewed Gum":[
		"Stick it into the machine to make the slots 30% slower.",
		200,
		{affect.spinSpeed:0.70},
		[]],
	"Multiplication Key":[
		"Unlock coin multiplies which increases every time you get\n3 in a row and decreaces when you don't",
		400,
		{affect.maxMult:2},
		[]],
	#"Socket Wrench":[
		#"Tighten the gears to make them slip less before stopping",
		#600,
		#{affect.slotSlipping:1},
		#['Chewed Gum']],
	"Lucky Oil":[
		"If on the last slot you would be one away from scoring\nadds a 50% chance for the reals to slip\none more or less to hit it but\ncauses the last reel to spin 25% faster",
		500,
		{affect.luckySlipChance:0.5,affect.lastSlotSpeed:1.25},
		["Chewed Gum"]],
	"Seven Dollar Bill":[
		"Printed in 1777 and has the face\nof the seventh president, Andrew Jackson.\nAdds a second seven to the last slot.",
		777,
		{affect.sevenCount:2},
		['Lucky Oil']],
}
var currentItems:PackedStringArray=["Chewed Gum","Multiplication Key"]
var boughtItems:PackedStringArray=[]

func _ready():
	updateShop()

func updateShop():
	for oldItem in $VBoxContainer/ScrollContainer/VBoxContainer.get_children():
		oldItem.queue_free()
	var items=[]
	for item in currentItems:
		var itemNode=preload("res://Scenes/shop_item.tscn").instantiate()
		itemNode.get_node("HBoxContiner/VBoxContainer/Title").text=item
		itemNode.get_node("HBoxContiner/VBoxContainer/Descrption").text=shopItems[item][0]
		itemNode.get_node("HBoxContiner/Label").text=str(shopItems[item][1])
		itemNode.pressed.connect(shopItemPressed.bind(item))
		items.append(itemNode)
		$VBoxContainer/ScrollContainer/VBoxContainer.add_child(itemNode)
		itemNode.custom_minimum_size=itemNode.get_node("HBoxContiner").size
	for i in range(len(items)):
		if i>0:
			items[i].focus_neighbor_top=items[i-1].get_path()
			items[i].focus_previous=items[i-1].get_path()
		items[i].focus_neighbor_bottom= ^'/root/main/Button' if i==len(items)-1 else items[i+1].get_path()
		items[i].focus_next= ^'/root/main/Button' if i==len(items)-1 else items[i+1].get_path()
	if len(items)>0:
		get_node("../Button").focus_neighbor_top=items[-1].get_path()
		get_node("../Button").focus_previous=items[-1].get_path()
		

func shopItemPressed(title:String):
	var item=shopItems[title]
	if(get_parent().coins>=item[1]):
		get_parent().addCoins(-item[1])
		for itemAffect in item[2]:
			match itemAffect:
				affect.spinSpeed:
					for i in range(3):
						var currentSlot=get_node("../Slots/Slot"+str(i))
						var spinning=currentSlot.velocity<currentSlot.maxSpeed+1
						currentSlot.maxSpeed*=item[2][itemAffect]
						if spinning:
							currentSlot.velocity=currentSlot.maxSpeed
				affect.sevenCount:
					get_node("../Slots/Slot"+str(item[2][itemAffect])).currentIcons.append(icons.SEVEN)
					get_node("../Slots/Slot"+str(item[2][itemAffect])).updateIcons()
				affect.slotSlipping:
					for i in range(3):
						var currentSlot=get_node("../Slots/Slot"+str(i))
						currentSlot.slotSlipping-=item[2][itemAffect]
				affect.maxMult:
					get_parent().maxMult*=item[2][itemAffect]
					get_node('../Mult').show()
					get_node('../Max Mult').show()
					get_parent().updateMult()
				affect.luckySlipChance:
					get_parent().luckySlipChance+=item[2][itemAffect]
				affect.lastSlotSpeed:
					var currentSlot=get_node("../Slots/Slot2")
					var spinning=currentSlot.velocity<currentSlot.maxSpeed+1
					currentSlot.maxSpeed*=item[2][itemAffect]
					if spinning:
						currentSlot.velocity=currentSlot.maxSpeed
		currentItems.erase(title)
		boughtItems.append(title)
		for itemToUnlock in shopItems:
			if itemToUnlock not in boughtItems and itemToUnlock not in currentItems and shopItems[itemToUnlock][3].all(boughtItems.has):
				currentItems.append(itemToUnlock)
		#print(currentItems)
		updateShop()
