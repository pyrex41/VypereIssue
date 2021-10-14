# @version ^0.2.16

"""
@title Mintable token implementation
@notice ERC-20 compliant?
"""

name: public(String[64])
symbol: public(String[32])
governor: public(address)


@external
def __init__(_name: String[64], _symbol: String[32]):
    self.name = _name
    self.symbol = _symbol
    self.governor = msg.sender



@external
def func(ab: uint256[2], c: uint256) -> uint256:
    return ab[0] + ab[1] + c
