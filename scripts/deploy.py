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
    return Coin.deploy("Coin Contract", "COIN", {'from': accounts[0]})


def deploycore(coin):
    return Core.deploy("Core", "CORE", coin.address, {'from': whale})

def main():
    coin = deploycoin()
    core = deploycore(coin)

    def fcore(*args):
        return core.functest(*args).return_value

    def fcoin(*args):
        return coin.func(*args).return_value

    return (coin, core, fcore, fcoin)
