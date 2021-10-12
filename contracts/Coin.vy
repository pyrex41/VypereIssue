# @version ^0.2.16

"""
@title Mintable token implementation
@notice ERC-20 compliant?
"""

MAX_BPS: constant(uint256) = 10_000

event Approval:
    owner: indexed(address)
    spender: indexed(address)
    value: uint256

event Transfer:
    sender: indexed(address)
    receiver: indexed(address)
    value: uint256

event Mint:
    owner: indexed(address)
    value: uint256

event Burn:
    owner: indexed(address)
    value: uint256

event ChangeFee:
    value: uint256
    target: indexed(address)

name: public(String[64])
symbol: public(String[32])
decimals: public(uint256)
totalSupply: public(uint256)
minter: public(address)
governor: public(address)
transaction_fee: public(uint256)
transaction_fee_target: public(address)

balances: HashMap[address, uint256]
allowances: HashMap[address, HashMap[address, uint256]]


@external
def __init__(_name: String[64], _symbol: String[32], _decimals: uint256, _total_supply: uint256, _minter: address, _governor: address):
    self.name = _name
    self.symbol = _symbol
    self.decimals = _decimals
    self.balances[msg.sender] = _total_supply
    self.totalSupply = _total_supply
    self.minter = _minter
    self.governor = _governor
    self.transaction_fee = 0
    self.transaction_fee_target = self.governor
    log Transfer(ZERO_ADDRESS, msg.sender, _total_supply)

# add getter to view value via chainlink oracle
# maybe: add function to call core address to view collatoralization / leverage


@external
def func(ab: uint256[2], c: uint256) -> uint256:
    return ab[0] + ab[1] + c


@external
def change_minter(_target : address) -> bool:
    """
    @notice Change minter address
    @dev Must be called by current minter or governor
    @param _target The address that will become the new minter
    @return Success boolean
    """
    assert msg.sender in [self.minter, self.governor]
    self.minter = _target
    return True


@external
def change_governor(_target : address) -> bool:
    """
    @notice Change governor address
    @dev Must be called by current governor
    @param _target The address that will become the new governor
    @return Success boolean
    """
    assert msg.sender == self.governor
    self.governor = _target
    return True

@external
def mint(_target : address, _value : uint256) -> bool:
    """
    @notice Mint token at _target address
    @dev Must be called by minter.
    @param _target The address that will receive the newly minted token
    @param _value The quantity of token to be minted
    @return Success boolean
    """
    assert msg.sender == self.minter, "Must be called by minter"
    self.totalSupply += _value
    self.balances[_target] += _value
    log Mint(_target, _value)
    return True


@external
def burn(_target : address, _value : uint256) -> bool:
    """
    @notice Burn PEG at _target address
    @dev Must be called by minter.
    @param _target The address that will be debit the burned token
    @param _value The quantity of token to be burned
    @return Success boolean
    """
    assert msg.sender == self.minter, "Must be called by minter"
    assert _value <= self.balances[_target], "Insufficient balance at target to burn"
    self.totalSupply -= _value
    self.balances[_target] -= _value
    log Burn(_target, _value)
    return True


@view
@external
def balanceOf(_owner: address) -> uint256:
    """
    @notice Getter to check the current balance of an address
    @param _owner Address to query the balance of
    @return Token balance
    """
    return self.balances[_owner]


@view
@external
def allowance(_owner : address, _spender : address) -> uint256:
    """
    @notice Getter to check the amount of tokens that an owner allowed to a spender
    @param _owner The address which owns the funds
    @param _spender The address which will spend the funds
    @return The amount of tokens still available for the spender
    """
    return self.allowances[_owner][_spender]


@external
def approve(_spender : address, _value : uint256) -> bool:
    """
    @notice Approve an address to spend the specified amount of tokens on behalf of msg.sender
    @dev Beware that changing an allowance with this method brings the risk that someone may use both the old
         and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
         race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
         https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    @param _spender The address which will spend the funds.
    @param _value The amount of tokens to be spent.
    @return Success boolean
    """
    self.allowances[msg.sender][_spender] = _value
    log Approval(msg.sender, _spender, _value)
    return True


@internal
def _transfer(_from: address, _to: address, _value: uint256):
    """
    @dev Internal shared logic for transfer and transferFrom
    """
    assert self.balances[_from] >= _value, "Insufficient balance"
    self.balances[_from] -= _value
    self.balances[_to] += _value
    log Transfer(_from, _to, _value)

@external
def transfer(_to : address, _value : uint256) -> bool:
    """
    @notice Transfer tokens to a specified address
    @dev Vyper does not allow underflows, so attempting to transfer more
         tokens than an account has will revert
    @param _to The address to transfer to
    @param _value The amount to be transferred
    @return Success boolean
    """
    fee_amt: uint256 = self.transaction_fee * _value / MAX_BPS
    payload_amt: uint256 = _value - fee_amt
    self._transfer(msg.sender, _to, _value)
    return True


@external
def transferFrom(_from : address, _to : address, _value : uint256) -> bool:
    """
    @notice Transfer tokens from one address to another
    @dev Vyper does not allow underflows, so attempting to transfer more
         tokens than an account has will revert
    @param _from The address which you want to send tokens from
    @param _to The address which you want to transfer to
    @param _value The amount of tokens to be transferred
    @return Success boolean
    """
    assert self.allowances[_from][msg.sender] >= _value, "Insufficient allowance"
    fee_amt: uint256 = self.transaction_fee * _value / MAX_BPS
    payload_amt: uint256 = _value - fee_amt
    self.allowances[_from][msg.sender] -= _value
    self._transfer(_from, _to, payload_amt)
    return True

@external
def withdraw_transaction_fees() -> bool:
    assert msg.sender in [self.governor, self.transaction_fee_target]
    self._transfer(self, self.transaction_fee_target, self.balance)
    return True

@external
def setTransactionFee(amt: uint256, addr: address) -> bool:
    assert msg.sender == self.governor
    assert amt < 501, "Must be 500 bps (5%) or less"
    self.transaction_fee = amt
    self.transaction_fee_target = addr
    return True
