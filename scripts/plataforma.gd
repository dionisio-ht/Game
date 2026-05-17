extends Node2D

const waitduration := 1.0 #variavel para definir o tempo de espera antes de subir ou descer

@onready var platform := $AnimatableBody2D as AnimatableBody2D
@export var movespeed := 9.0 #velocidade da plataforma
@export var distance := 500 #distancia que devera percorrer
@export var movevertical := true #booleano se esta subindo ou nao

var follow := Vector2.ZERO
var platformcenter := 16 #centro da plataforma (como eh 32x32, o centro eh 16)
var startposition = Vector2.ZERO #guardando a posicao da plataforma na cena

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	startposition = platform.position #definindo onde inicia
	follow = startposition # ele devera ir para a posicao que definimos na cena
	moveplatform() #funcao para mover

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	platform.position = platform.position.lerp(follow, 1)
	#mover levemente (lerp)

func moveplatform():
	#definindo a direcao, cima ou baixo
	var movedirection = Vector2.UP * distance if movevertical else Vector2.DOWN * distance
	var duration = movedirection.length() / float(movespeed * platformcenter)
	
	#calculando onde vai parar
	var targetposition = startposition + movedirection 
	
	var platformtween = create_tween().set_loops() #para subir e descer infinitamente
	#subindo
	platformtween.tween_property(self, "follow", targetposition, duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT).set_delay(waitduration)
	#descendo
	platformtween.tween_property(self, "follow", startposition, duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT).set_delay(waitduration)
