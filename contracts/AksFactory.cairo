%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from starkware.cairo.common.uint256 import (
    Uint256, uint256_le, uint256_mul, uint256_unsigned_div_rem, uint256_add, uint256_sub)
from starkware.starknet.common.syscalls import get_caller_address, get_contract_address

from contracts.lib.token.ERC20_base import (
    ERC20_name, ERC20_symbol, ERC20_totalSupply, ERC20_decimals, ERC20_balanceOf, ERC20_allowance,
    ERC20_initializer, ERC20_approve, ERC20_increaseAllowance, ERC20_decreaseAllowance,
    ERC20_transfer, ERC20_transferFrom, ERC20_burn, ERC20_mint)

from contracts.lib.utils.constants import TRUE

from contracts.lib.token.IERC20 import IERC20


struct _tokenPair:
    member token0 : felt
    member token1 : felt
end

@storage_var
func _pairs(pair:_tokenPair)->(res : felt):
end

@view
func getPair{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(token0:felt,token1:felt) -> (address:felt):
    let pair = _tokenPair(token0=token0, token1=token1)

    let (address) =  _pairs.read(pair)
    return (address = address)
end