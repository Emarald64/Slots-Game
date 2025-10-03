extends Node2D

enum {HEART,DIAMOND,CLUB,SPADE,DIE,GEM,SEVEN,ORANGE,BAR,STAR}
enum actions {NONE,STOP,START}

var acceleration:=0.0
var maxSpeed:=-175
var velocity:float=maxSpeed
var stopping:=false
var starting:=false
var currentAction:= actions.NONE
var currentIcons:=[HEART,DIAMOND,CLUB,SPADE,GEM,ORANGE,STAR,HEART,DIAMOND,CLUB,SPADE,DIE,HEART,DIAMOND,CLUB,SPADE,GEM,ORANGE,STAR,HEART,DIAMOND,CLUB,SPADE,DIE,SEVEN]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	updateIcons()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	#if(stopping and velocity>-2):
		#$Clip/Icons.position.y=roundf($Clip/Icons.position.y/18)*18
	velocity+=acceleration*delta/2
	if velocity>=0 and stopping:
		acceleration=0
		velocity=0
	elif velocity<=maxSpeed and starting:
		acceleration=0
		starting=false
		
	$Clip/Icons.position.y+=velocity*delta
	$Clip/Icons.position.y=fposmod($Clip/Icons.position.y+(len(currentIcons)+2.5)*18,float(len(currentIcons)*18))-(len(currentIcons)+2.5)*18
	velocity+=acceleration*delta/2
	
func updateIcons() -> void:
	#clear out old icons
	for sprite in $Clip/Icons.get_children():
		sprite.free()
	# add new icons
	for iconIdx in range(len(currentIcons)+5):
		var sprite:=Sprite2D.new()
		sprite.texture=preload("res://assets/icons.png")
		sprite.hframes=10
		sprite.frame=currentIcons[iconIdx%len(currentIcons)]
		sprite.position=Vector2(0,iconIdx*18)
		$Clip/Icons.add_child(sprite)

func stop() -> void:
	acceleration=(velocity**2)/(2*(54+fposmod($Clip/Icons.position.y,18.0)))
	stopping=true

func startWithDelay(delay:=0.0):
	currentAction=actions.START
	$"Action delay".wait_time=delay if delay>0 else randf()
	$"Action delay".start()

func start() -> void:
	acceleration=maxSpeed
	stopping=false
	starting=true
	
func doAction() -> void:
	match currentAction:
		actions.START:
			start()
		actions.STOP:
			stop()
