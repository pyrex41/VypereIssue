# @version ^0.2.16

"""
@title Core mechanisms
@notice we gonna make it
"""

from vyper.interfaces import ERC20
from interfaces import Coin

FEE_DENOMINATOR: constant(uint256) = 10 ** 10
PRECISION: constant(uint256) = 10 ** 18
MAX_BPS: constant(uint256) = 10_000  # 100%, or 10k basis points
SECS_PER_YEAR: constant(uint256) = 31_556_952  # 365.2425 days
N_COINS: constant(uint256) = 3
PRICE_DECIMAL: constant(uint256) = 1_000_000


name: public(String[42])
symbol: public(String[20])
coin: public(address)
governance: public(address)

@external
def __init__(_name: String[42],_coin_address: address):
    self.name = _name
    self.symbol = "HODL"
    self.coin =  _coin_address
    self.governance = msg.sender


@external
@payable
def __default__():
    pass



@external
def functest(a: uint256, b: uint256, c: uint256) -> uint256:
    return Coin(self.coin).func([a,b], c)


@external
@payable
def mint_coin(recipient: address, amt: uint256) -> bool:
    assert msg.sender == self.governance
    Coin(self.coin).mint(recipient, amt)
    return True

@external
@payable
def burn_coin(amt: uint256, holder: address = msg.sender) -> bool:
    assert msg.sender == self.governance
    Coin(self.coin).burn(holder, amt)
    return True

@external
def set_symbol(symbol: String[20]):
    assert msg.sender == self.governance
    self.symbol = symbol

@internal
def erc20_safe_transfer(token: address, receiver: address, amount: uint256):
    # Used only to send tokens that are not the type managed by this Vault.
    # HACK: Used to handle non-compliant tokens like USDT
    response: Bytes[32] = raw_call(
    token,
        concat(
            method_id("transfer(address,uint256)"),
            convert(receiver, bytes32),
            convert(amount, bytes32),
        ),
        max_outsize=32,
    )
    if len(response) > 0:
       assert convert(response, bool), "Transfer failed!"

@internal
def transfer_all_erc(coin: address, target: address):
    amt: uint256 = ERC20(coin).balanceOf(self)
    if amt > 0:
        ERC20(coin).transfer(target, amt)

@internal
def erc20_safe_transfer_all(token: address, receiver: address):
    amt: uint256 = ERC20(token).balanceOf(self)
    if amt > 0:
       self.erc20_safe_transfer(token, receiver, amt)
