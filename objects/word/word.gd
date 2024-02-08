extends AnimatedSprite2D


@export var text_id := 1
@export var color := Color.BLACK


const STEP := 30
const LETTER_NAME = ["_", "=", "P", "b", "D", 
"I1", "I2", "I3", "I4", "I5", 
"R", "Q", "d", "q", "(",
"*", "+", "<", ">", ")",
"0", "1", "2", "3", "4",
"5", "6", "7", "8", "9"]


## 内建，不要用。
func get_letter_id(letter: String) -> int:
	for i in range(len(LETTER_NAME)):
		if LETTER_NAME[i] == letter:
			return i
	assert(false, "Letter " + letter + " not found")
	return -1
	

## 内建，不要用。
func set_text_id(value: int) -> void:
	assert(value >= 0, "text id < 0")
	text_id = value
	update_animation()

func update_animation() -> void:
	var animation_id = str(text_id) + color.to_html()
	if not sprite_frames.has_animation(animation_id):
		sprite_frames.add_animation(animation_id)
		for i in range(3):
			sprite_frames.add_frame(animation_id, load_image(i * STEP + text_id + 1, color))
	animation = animation_id
	
	

## 更改字母为 text。
func set_word(text: String) -> void:
	if text == "_" or text == ".":
		set_text_id(0)
	else:
		set_text_id(get_letter_id(text))

## 获得当前字母。
func get_word() -> String:
	return LETTER_NAME[text_id]


func _ready():
	update_animation()
	


func _process(delta):
	update_animation()
		
func set_color_from_name(name: String) -> void:
	if name == "red":
		set_color(Color("#DD4132"))
	elif name == "golden":
		set_color(Color("#F5DF4D"))
	elif name == "default":
		set_color(Color.BLACK)
	else:
		assert(false, "color %s not in list" % name)

func set_color(value: Color) -> void:
	color = value
	update_animation()

## 设置是否为关卡通过状态。
## 已弃用，请使用 set_color 或 set_color_from_name 代替。
## @deprecated
func set_victory(v: bool) -> void:
	push_warning("void set_victory(v: bool) is deprecated.")
	if v:
		set_color_from_name("golden")
	else:
		set_color_from_name("default")
		
func load_image(h: int, new_color: Color):
	var image := load("res://objects/word/sprites/sprite" + str(h) + ".png")
	if new_color != Color.BLACK:
		var new_texture = image.get_image()
		for x in range(new_texture.get_width()):
			for y in range(new_texture.get_height()):
				var color = new_texture.get_pixel(x, y)
				if color == Color.BLACK:  # 如果像素是黑色
					new_texture.set_pixel(x, y, new_color)  # 将其改为金黄色
		return ImageTexture.create_from_image(new_texture)
		
	return image
