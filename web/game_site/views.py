import datetime
import random

from django.http import HttpResponse
from django.shortcuts import render
from django.template import loader

from game_site.eth import game, game_address, paint_method_hash, check_time_method_hash

FIELD_SIDE = game.FIELD_SIDE()
WEI_IN_ETH = 10**18

colour_table = {
	1: "red",
	2: "orange", 
	3: "yellow",
	4: "lightblue",
	5: "blue",
	6: "purple",
	7: "brown",
	8: "pink",
	9: "silver",
	10: "gray"
}

def index(request):
	template = loader.get_template('game_site/index.html')

	move_price = game.currentMovePrice()
	last_changed = game.lastChangeTime()
	context = {
		"game_field": get_game_field(FIELD_SIDE),
		"time_bank_eth": game.timeBank() / WEI_IN_ETH,
		"colour_bank_eth": game.colourBank() / WEI_IN_ETH,
		"move_price_eth": move_price / WEI_IN_ETH,
		"move_price": hex(move_price),
		"colour_table": colour_table.items(),
		"banned_colour": game.bannedColour(),
		"last_changer": game.lastChanger(),
		"last_changed": datetime.datetime.fromtimestamp(last_changed).strftime('%d %b %Y %H:%M:%S'),
		"game_address": game_address,
		"paint_method_hash": paint_method_hash,
		"check_time_method_hash": check_time_method_hash
	}
	return HttpResponse(template.render(context, request))

def get_game_field(field_side):

	raw_field =  [game.gameField(i) for i in range(field_side*field_side)]
	game_field = prepare_field(raw_field, field_side)

	return game_field

def prepare_field(raw_field, field_side):

	game_field = []

	for i in range(field_side):
		line = []
		for j in range(field_side):
			cell = raw_field[i*field_side + j].dict()
			cell['n'] = i*field_side + j + 1
			cell['colour'] = colour_table[cell['colour']]
			line.append(cell)
		game_field.append(line)

	return game_field
	