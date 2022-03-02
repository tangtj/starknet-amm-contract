%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from starkware.cairo.common.uint256 import (
    Uint256, uint256_le, uint256_mul, uint256_unsigned_div_rem, uint256_add, uint256_sub)
from starkware.starknet.common.syscalls import get_caller_address, get_contract_address
from starkware.cairo.common.math import assert_lt_felt
from contracts.lib.token.ERC20_base import (
    ERC20_name, ERC20_symbol, ERC20_totalSupply, ERC20_decimals, ERC20_balanceOf, ERC20_allowance,
    ERC20_initializer, ERC20_approve, ERC20_increaseAllowance, ERC20_decreaseAllowance,
    ERC20_transfer, ERC20_transferFrom, ERC20_burn, ERC20_mint)

from contracts.lib.utils.constants import TRUE

from contracts.lib.token.IERC20 import IERC20

from contracts.IAksPair import IAksPair

from contracts.IAksFactory import IAksFactory

from starkware.cairo.common.alloc import alloc

from contracts.AksLibrary import sortPair, getAmountInForToken, getAmountOutForToken, swapForToken

# 指定具体的获得token，限定最大输入token
# path 改成 pair id , pair id 由链下能力支持，是在不知道怎么弄了这样也是没办法
func swapTokensForExactTokens(
        amountOut : Uint256, amountInMax : Uint256, path : felt*, size : felt, to : felt) -> ():
    alloc_locals

    return ()
    # token 0 -> token 1
end

# 指定具体的获得token，限定最大输入token
func swapExactTokensForTokens{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        amountIn : Uint256, amountOutMin : Uint256, path : felt*, size : felt, to : felt) -> ():
    _swap(path,size,amountIn,amountOutMin,to)
    return ()
end

# 获取最后返回 amount 数量
func _swap{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        paths : felt*, size, amountIn : Uint256, minOut : Uint256,to:felt) -> (r : Uint256):
    alloc_locals
    let i = 0
    let n = i + 1
    let in = paths[i]
    let out = paths[n]

    let (amount) = getAmountOutForToken(amountIn, in, out)
    if size - 1 == 1:
        let (is_le) = uint256_le(a=minOut, b=amount)
        return (r=amount)
    end

    # todo
    # 转账 swap 操作
    let (to) = get_caller_address()
    swapForToken(amountIn, in, out, to)

    let (r) = _swap(paths=paths + 1, size=size - 1, amountIn=amount, minOut=minOut,to=to)
    return (r)
end
