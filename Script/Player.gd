extends CharacterBody3D

@onready var player: Node3D = $Player
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/StateMachine/playback")


# 速度、跑步速度、跳跃力的变量
const Speed := 500.0
const RunSpeed := Speed * 2.0
const JUMP_VELOCITY := 5.6

# 获取系统重力
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta: float) -> void:

	# 判断下坠
	if not is_on_floor():
		velocity.y -= gravity * delta

	# 按键触发跳跃
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# 判断输入事件、移动方向、移动速度
	var input_shift := Input.is_action_pressed("shift")
	var input_dir := Input.get_vector("a", "d", "w", "s")
	var direction := (transform.basis * Vector3(-input_dir.x, 0, -input_dir.y)).normalized()
	if direction:
		if input_shift:
			velocity.x = direction.x * delta * RunSpeed
			velocity.z = direction.z * delta * RunSpeed
			state_machine.travel("Fast Run")
		else:
			velocity.x = direction.x * delta * Speed
			velocity.z = direction.z * delta * Speed
			state_machine.travel("Run")
	else:
		velocity.x = move_toward(velocity.x, 0, Speed)
		velocity.z = move_toward(velocity.z, 0, Speed)
		state_machine.travel("Idle")
		
	# 判断角色移动方向
	if velocity.length() > 0.1:
		var v = Vector2(velocity.z, velocity.x)
		player.rotation.y = v.angle()

	move_and_slide()
