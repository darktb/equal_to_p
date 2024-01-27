extends Node


const Block := preload("res://objects/block/block.tscn")
const CardBase := preload("res://objects/card_base/card_base.tscn")
const TableCloth := preload("res://objects/table_cloth/table_cloth.tscn")
const HEIGHT := 1080 / 4
const WIDTH := 1920 / 4
const SEP := 35


var expr := ""
var req_pos = [] # Array[int]


const DATA := [
	[
		["=P", "P {} {}", "= P"],
		["P", "P [] {}", "= P P"],
		["=D", "D {} {}", "= D P"],
		["Reverse", "{} {} []", "d d = P P D D"]
	],
	[
		["False", "[] [] 0 {} {}", "= + P P"],
		["True", "[] {} {} [] 1", "= + P 1"],
		["Swap", "Q + [] = {} + []", "P P P P Q Q Q Q"],
		["Always True", "[] [] {} = {} [] []", "11++PPdd"],
		["Not Really Challenging", "1 [] [] [] {} [] [] [] {} [] {} [] []", "= = + + + + + + 1 1 P q b R"]
	],
	[
		["Laughing", "1 {} {} = []", "XDD"],
		["Reset", "0 [] [] {} []", "XD10"],
		["Not Necessary", "[] {} {} {} {} []", "QQQQQQDDXX="],
		["Golden Experience", "{} {} {} {} {} {} {} {} {} {} {}", "PP DD qq dd bb XXX ="],
	],
	[
		["He Goes First", "[] [] + [] = ( [] {} {} ) [] []", "PP QQ RR X +"],
		["Still, He Goes First", "[] + [] [] = [] [] ( [] {} {} )", "PP QQ RR X +"],
		["It's My Turn", "P ([] [] []) = {} [] [] [] []", "PP QQ RR ++"],
		["[EX] Really Challenging", "[] [] [] [] [] {} {} [] [] [] [] {} {} + [] []", "PPP QQ DD (()) ++ ="]
	],
	[
		["Why?", "[] [] {} = {} [] {} = []", "PP qq ++ 1"],
		["Where is the Equation?", "[] [] {} {} [] + [] [] {} {} []", "(())==01PP"],
	]
]



func count(choices: String) -> Dictionary:
	var res := {}
	for x in choices:
		if not res.has(x):
			res[x] = 0
		res[x] += 1
	return res


func init(chap_id: int, lvl_id: int) -> void:
	var lvl_name = DATA[chap_id][lvl_id][0]
	var question = DATA[chap_id][lvl_id][1].replace(" ", "").replace("X", "*")
	var choices = count(DATA[chap_id][lvl_id][2].replace(" ", "").replace("X", "*"))
	
	question = question.replace("[]", ".")
	question = question.replace("{}", "_")
		
	
	var table_cloth = TableCloth.instantiate()
	table_cloth.size.x = SEP * len(question) + 16
	table_cloth.size.y = 48
	table_cloth.position.x = WIDTH / 2 - SEP * len(question) / 2 - 12
	table_cloth.position.y = HEIGHT / 2 - 24
	$HUDs.add_child(table_cloth)
		
	var pos := WIDTH / 2 - SEP * len(question) / 2 + 12
	for i in range(len(question)):
		var ch = question[i]
		
		var new_block := Block.instantiate()

		new_block.quest_pos = i
		if ch != "." and ch != "_":
			new_block.occupied = true
			new_block.set_word(ch)
			new_block.set_block_type("CONST")
		else:
			new_block.set_word("_")
			if ch == "_":
				req_pos.append(i)
				new_block.set_block_type("GOLDEN")
			else:
				new_block.set_block_type("PIT")
		new_block.set_position(Vector2(pos, HEIGHT / 2))
		pos += SEP
		
		$Blocks.add_child(new_block)
	
	expr = question
	print(expr)
	
	
	pos = WIDTH / 2 - SEP * len(choices) / 2 + 12
	for ch in choices:
		var new_card_base := CardBase.instantiate()

		new_card_base.set_word(ch)
		
		new_card_base.set_card_count(choices[ch])
		new_card_base.set_position(Vector2(pos, HEIGHT * 6 / 7))
		pos += SEP
		
		$CardBases.add_child(new_card_base)
		new_card_base.card_put.connect(_on_card_put)


func _ready():
	pass

func _process(_delta):
	pass


func _on_card_put() -> void:
	for block : Block in $Blocks.get_children():
		if not block.occupied:
			print(block.quest_pos, " is not occupied")
			return
		expr[block.quest_pos] = block.occupied_word
		
	prints("# expr: ", expr)
	
	if expr.count("_") == 0:
		var info = $Calculator.check(expr, req_pos)
		prints("expr:", expr)
		prints("info:", info)
		if info[0] == "INVALID":
			for block: Block in $Blocks.get_children():
				if block.quest_pos in info[1]:
					block.call("shake")
		elif info[0] == "SMILE_UNSATISFIED":
			for block: Block in $Blocks.get_children():
				if block.quest_pos == info[1]:
					block.call("shake")
		elif info[0] == "NOT_ALWAYS_TRUE":
			for block: Block in $Blocks.get_children():
				block.call("shake")
		else:
			$SFXs/LevelClear.play()
			
