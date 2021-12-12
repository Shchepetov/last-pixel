from brownie import Game, accounts

def main():
    acct = accounts.load('my_account')
    Game.deploy({'from': acct})
