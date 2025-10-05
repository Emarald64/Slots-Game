extends PanelContainer

enum affect {spinSpeed, slotSlipping, sevenCount, maxMult}
enum icons {HEART,DIAMOND,CLUB,SPADE,DIE,GEM,SEVEN,ORANGE,BAR,STAR}

const shopItems={
	"Chewed Gum":["Stick it into the machine to make the slots 20% slower.",200,affect.spinSpeed,0.80,[]],
	"Multiplication Key":["Unlock coin multiplies which increase every time you get\n3 in a row and decreace when you don't",400,affect.maxMult,2,[]],
	"Socket Wrench":["Tighten the gears to make them slip less before stopping",600,affect.slotSlipping,1,['Chewed Gum']],
	"Seven Dollar Bill":["Printed in 1777 and has the face\nof the seventh president, Andrew Jackson.\nAdds a second seven to the last slot.",777,affect.sevenCount,2,['Socket Wrench']],
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
	if(get_parent().coins>=shopItems[title][1]):
		get_parent().addCoins(-shopItems[title][1])
		match shopItems[title][2]:
			affect.spinSpeed:
				for i in range(3):
					var currentSlot=get_node("../Slots/Slot"+str(i))
					currentSlot.maxSpeed*=shopItems[title][3]
					if currentSlot.velocity<currentSlot.maxSpeed:
						currentSlot.velocity=currentSlot.maxSpeed
			affect.sevenCount:
				get_node("../Slots/Slot"+str(shopItems[title][3])).currentIcons.append(icons.SEVEN)
				get_node("../Slots/Slot"+str(shopItems[title][3])).updateIcons()
			affect.slotSlipping:
				for i in range(3):
					var currentSlot=get_node("../Slots/Slot"+str(i))
					currentSlot.slotSlipping-=shopItems[title][3]
			affect.maxMult:
				get_parent().maxMult*=shopItems[title][3]
				get_node('../Mult').show()
				get_node('../Max Mult').show()
				get_parent().updateMult()
		currentItems.erase(title)
		boughtItems.append(title)
		for item in shopItems:
			if item not in boughtItems and item not in currentItems and shopItems[item][4].all(boughtItems.has):
				currentItems.append(item)
		#print(currentItems)
		updateShop()
