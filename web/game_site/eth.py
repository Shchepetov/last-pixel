from brownie import network, Contract

netwok_name = "ropsten_free_trial"
game_address = "0x1A0F477F516762Aaa11a92296776c5F044a62515"
paint_method_hash = "19ef4ef0"
check_time_method_hash = "39277da8"

if not network.is_connected():
	network.connect(netwok_name)

game = Contract(game_address)