#!/usr/bin/python3

from brownie import *

def load_contract(addr):
    if addr == ZERO_ADDRESS:
        return None
    try:
        cont = Contract(addr)
    except ValueError:
        cont = Contract.from_explorer(addr)
    return cont

# Load Globals
whale = a[0]

def deploycoin():
    return Coin.deploy("Coin Contract", "HODL", 18, 0, accounts[0], accounts[0], {'from': accounts[0]})


def deploycore(coin):
    return Core.deploy("Core", coin.address, {'from': whale})

def main():
    coin = deploycoin()
    core = deploycore(coin)

    coin.change_minter(core.address, {'from': whale})

    return (coin, core)
