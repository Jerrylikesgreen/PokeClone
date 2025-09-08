class_name PlayerBody
extends CharacterBody2D

signal battle_started_triggered

@export var SPEED := 200.0
@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D



const DEADZONE := 0.01 

enum FaceDir { UP, DOWN, LEFT, RIGHT }
var _last_face_dir: FaceDir = FaceDir.DOWN  # default facing


@export var STEP_LENGTH := 8.0                 # pixels per “step” (match your tile size)
@export var spawn_encounter_rate:float = 0.01

var _step_count:int = 0
var _last_pos: Vector2
var _step_accum := 0.0
var _in_battle := false
var _can_move:= true
var pxl_moved = Vector2.ZERO
var is_in_spawn_area: bool = false
var _was_in_spawn_area:bool = false

func _ready() -> void:
	_last_pos = global_position
	Events.battle_started_signal.connect(_on_battle_start)
	Events.battle_ended_signal.connect(_on_battle_end)

func _physics_process(_delta: float) -> void:
	if !_can_move:
		return

	var dir := Input.get_vector("Left", "Right", "Up", "Down")
	_update_animation(dir)  # ← use this instead of the old play/flip_h lines

	velocity = dir * SPEED

	
	if dir > Vector2.ZERO:
		pxl_moved = dir + pxl_moved
	if dir < Vector2.ZERO:
		pxl_moved = pxl_moved - dir
	
	var total_pixl_cal = int(pxl_moved.x + pxl_moved.y) 
	var step:int = total_pixl_cal / STEP_LENGTH * 0.5
	_step_count = step
	
	move_and_slide()
	if is_in_spawn_area:
		randomize()
		if randf() < spawn_encounter_rate:
			print("Battle")
			emit_signal("battle_started_triggered")

func _on_battle_end()->void:
	_can_move = true
	if !is_in_spawn_area and _was_in_spawn_area:
		var new_timer := Timer.new()
		new_timer.one_shot
		new_timer.wait_time = 2.0
		add_child(new_timer)
		new_timer.start()
		
		await new_timer.timeout
		is_in_spawn_area = true
		new_timer.queue_free()
	else:
		is_in_spawn_area = false
		

func _update_animation(dir: Vector2) -> void:
	var moving := dir.length() > DEADZONE
	var face := _last_face_dir

	if moving:
		# pick dominant axis
		if absf(dir.x) >= absf(dir.y):
			face = (FaceDir.LEFT if dir.x < 0.0 else FaceDir.RIGHT)
		else:
			face = (FaceDir.UP if dir.y < 0.0 else FaceDir.DOWN)
		_last_face_dir = face

		match face:
			FaceDir.UP:    animated_sprite_2d.play("MovingUp")
			FaceDir.DOWN:  animated_sprite_2d.play("MovingDown")
			FaceDir.LEFT:  animated_sprite_2d.play("MovingLeft")
			FaceDir.RIGHT: animated_sprite_2d.play("MovingRight")
	else:
		match _last_face_dir:
			FaceDir.UP:    animated_sprite_2d.play("IdleUp")
			FaceDir.DOWN:  animated_sprite_2d.play("IdleDown")
			FaceDir.LEFT:  animated_sprite_2d.play("IdleLeft")
			FaceDir.RIGHT: animated_sprite_2d.play("IdleRight")


func _on_battle_start(_mons:MonsResource)->void:
	if is_in_spawn_area == true:
		is_in_spawn_area = false
		_was_in_spawn_area = true
	_can_move = false
