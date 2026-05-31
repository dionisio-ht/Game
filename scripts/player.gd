extends CharacterBody2D

##Referencias
@onready var ray_left: RayCast2D = $ray_left
@onready var ray_right: RayCast2D = $ray_right
@onready var animacao: AnimatedSprite2D = $AnimatedSprite2D

###Fazendo variaveis de vida e dano
@export var vidaMaxima := 3
@export var forcaDano := -350.0 # para lançar o personagem pra cima
@export var invencivel := false
var vida := vidaMaxima
var listaCoracoes : Array[TextureRect]

##Velocidade Padrão
const SPEED = 200.0
const JUMP_VELOCITY = -400.0

##Velocidade na Parede
@export var wall_slide_speed: float = 50 #velocidade da queda na parede
@export var wall_jump_force: Vector2 = Vector2(250, JUMP_VELOCITY) #força do pulo

##Variaveis para Verificar se esta na parede e a direção
var is_wall: bool = false
var wall_direction: int = 0

## Vriavel para travar o Movimento no Vetor 'X' ou 'Y'
var mov_lock := 0.0

func _ready() -> void:
	var Coracoes = $Vida/HBoxContainer
	for child in Coracoes.get_children():
		listaCoracoes.append(child)
	print(listaCoracoes)

##Funcao de receber dano
func tomarDano(damage):
	if invencivel: # se tomou dano recentemente, nao tomará
		return
	
	vida -= damage #reduzindo a variavel da vida pelo dano
	print("Vida: ", vida)
	atualizarVida()
	
	# se a vida chegar a zero
	if vida <= 0:
		morrer() #ativa a funcao de morte
	
	#depois que tomar dano, entra em frames de invencibilidade
	invencivel = true
	
	#ativar animação visual de invencibilidade
	piscar()
	
	#tempo que dura a invencibilidade pós-dano
	await get_tree().create_timer(1.0).timeout
	
	#retorna ao estado normal
	invencivel = false
	
func morrer():
	print("Você morreu")
	
	await get_tree().create_timer(0.5).timeout
	
	get_tree().reload_current_scene()

func piscar():
	for i in range(10):
		animacao.visible = !animacao.visible #ficar piscando o sprite
		await get_tree().create_timer(0.1).timeout #intervalo de tempo para piscar
	
func atualizarVida():
	for i in range(listaCoracoes.size()): #entrar no vetor de vidas
		listaCoracoes[i].visible = i < vida #atualizar com base na vida atual
	# impulso para cima ao tomar dano
	
	velocity.y = forcaDano
	mov_lock = 0.2

# -----------------------------------------------------

##Funções para a Mecanica na Parede
func start_wall_slide(left, right):
	is_wall = true
	velocity.y = min(velocity.y, wall_slide_speed)
	wall_direction = 1 if left else -1

func stop_wall_slide():
	
	is_wall = false
	wall_direction = 0

##Função Main
func _physics_process(delta: float) -> void:
	##Timer de bloqueio
	if mov_lock > 0:
		mov_lock -= delta
	
	##Gravidade.
	if not is_on_floor():
		velocity += get_gravity() * delta

	##Pulo e Pulo na Parede.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if is_wall and Input.is_action_just_pressed("ui_accept"):
		velocity = Vector2(wall_jump_force.x * wall_direction, wall_jump_force.y)
		mov_lock = 0.1
		stop_wall_slide()
	
	##Mecanica na Parede
	#variaveis que verifica se esta tocando na parede
	var is_left_wall = ray_left.is_colliding() #esta tocando parede esquerda
	var is_right_wall = ray_right.is_colliding() #esta tocando parede direita
	
	if(is_left_wall and Input.is_action_pressed("ui_left")  or is_right_wall and Input.is_action_pressed("ui_right")) and not is_on_floor() and velocity.y > 0:
		start_wall_slide(is_left_wall, is_right_wall)
	elif is_wall and not (is_right_wall or is_left_wall):
		stop_wall_slide()
	
	##Direção da Movimentação
	var direction_Horizontal := Input.get_axis("ui_left", "ui_right")
	if mov_lock <= 0:
		if direction_Horizontal:
			velocity.x = direction_Horizontal * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		
	## Flip
	if direction_Horizontal > 0:
		animacao.flip_h = false
	elif direction_Horizontal < 0:
		animacao.flip_h = true

	## Animações
	if is_on_floor():
		if direction_Horizontal != 0:
			animacao.play("run")
		else:
			animacao.play("idle")
	else:
		if velocity.y < 0:
			animacao.play("jump")
		else:
			if animacao.animation != ("queda"):
				animacao.play("queda")

			
	
	move_and_slide()
