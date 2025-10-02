extends Node2D

enum {HEART,DIAMOND,CLUB,SPADE,DIE,GEM,SEVEN,ORANGE,BAR,STAR}

var acceleration:=0
var velocity:=-128
var currentIcons:=[HEART,DIAMOND,CLUB,SPADE,GEM,ORANGE,STAR,HEART,DIAMOND,CLUB,SPADE,DIE,HEART,DIAMOND,CLUB,SPADE,GEM,ORANGE,STAR,HEART,DIAMOND,CLUB,SPADE,DIE,SEVEN]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	updateIcons()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Clip/Icons.position.y+=velocity*delta
	$Clip/Icons.position.y=fposmod($Clip/Icons.position.y+(len(currentIcons)+1.5)*18,float(len(currentIcons)*18))-(len(currentIcons)+1.5)*18

func updateIcons() -> void:
	#clear out old icons
	for sprite in $Clip/Icons.get_children():
		sprite.free()
	# add new icons
	for iconIdx in range(len(currentIcons)+3):
		var sprite:=Sprite2D.new()
		sprite.texture=preload("res://assets/icons.png")
		sprite.hframes=10
		sprite.frame=currentIcons[iconIdx%len(currentIcons)]
		sprite.position=Vector2(0,iconIdx*18)
		$Clip/Icons.add_child(sprite)
	
