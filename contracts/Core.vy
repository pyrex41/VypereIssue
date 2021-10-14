# @version ^0.2.16

"""
@title Core mechanisms
@notice we gonna make it
"""

from vyper.interfaces import ERC20
from interfaces import Coin



name: public(String[42])
symbol: public(String[20])
coin: public(address)
governance: public(address)

@external
def __init__(_name: String[42], _symbol: String[20], _coin_address: address):
    self.name = _name
    self.symbol = _symbol
    self.coin =  _coin_address
    self.governance = msg.sender


@external
@payable
def __default__():
    pass



@external
def functest(a: uint256, b: uint256, c: uint256) -> uint256:
    return Coin(self.coin).func([a,b], c)
