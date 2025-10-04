extends PanelContainer

enum affect {spinSpeed, slotSlipping, sevenCount}

const shopItems={
	"Chewed Gum":["Stick it into the gears to make the slots 20% slower",25,affect.spinSpeed,0.80],
	"Sevan Dollar Bill":["Printed in 1777 has the face of the seventh president, Andrew Jackson\nAdds a second seven to the last slot",700,affect.sevenCount,4]
}
var currentItems:Array[String]=["Chewed Gum"]

func _ready():
	updateShop()

func updateShop():
	var items=[]
	for item in currentItems:
		var itemNode=preload("res://Scenes/shop_item.tscn").instantiate()
		itemNode.get_node("HBoxContiner/VBoxContainer/Title").text=item
		itemNode.get_node("HBoxContiner/VBoxContainer/Descrption").text=shopItems[item][0]
		itemNode.get_node("HBoxContiner/Label").text=str(shopItems[item][1])
		itemNode.pressed.connect(shopItemPressed.bind(item))
		items.append(itemNode)
		$VBoxContainer.add_child(itemNode)
	for i in range(len(items)):
		if i>0:
			items[i].focus_neighbor_top=items[i-1].get_path()
			items[i].focus_prevous=items[i-1].get_path()
		items[i].focus_neighbor_bottom= ^'../../../Button' if i==len(items)-1 else items[i+1]
		items[i].focus_next= ^'../../../Button' if i==len(items)-1 else items[i+1]
	get_node("../Button").focus_neighbor_top=items[-1].get_path()
	get_node("../Button").focus_previous=items[-1].get_path()
		

func shopItemPressed(title:String):
	if(get_parent().coins>=shopItems[title][1]):
		get_parent().addCoins(-shopItems[title][1])
		match shopItems[title][2]:
			affect.spinSpeed:
				for i in range(3):
					get_node("../Slots/Slot"+str(i)).maxSpeed*=shopItems[title][3]
		currentItems.erase(title)
