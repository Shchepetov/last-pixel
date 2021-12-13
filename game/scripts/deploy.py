import sys
from brownie import Game, accounts

def main():
    acc_name = input("Deploy account alias: ")
    acc = accounts.load(acc_name)
    Game.deploy({'from': acc})
