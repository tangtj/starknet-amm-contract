%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from starkware.cairo.common.uint256 import (
    Uint256, uint256_le, uint256_mul, uint256_unsigned_div_rem, uint256_add, uint256_sub)
from starkware.starknet.common.syscalls import get_caller_address, get_contract_address

from contracts.lib.utils.constants import TRUE
from starkware.cairo.common.math import assert_not_equal,assert_not_zero

from contracts.lib.token.IERC20 import IERC20
from contracts.AksLibrary import sortPair

struct PoolToken:
    member token0 : felt
    member token1 : felt
    member reserve0 : Uint256
    member reserve1 : Uint256
end

@storage_var
func _poolNum() -> (num : felt):
end

@storage_var
func _pools(id:felt) -> (pool : PoolToken):
end

@view
func getPool{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(id : felt) -> (pool : PoolToken):
    let (pool) = _pools.read(id)
    return (pool)
end

@view
func getPoolNum{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        num : felt):
    let (num) = _poolNum.read()
    return (num)
end

@storage_var
func _pairs(token0 : felt, token1 : felt) -> (res : felt):
end

@view
func getPoolId{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        token0 : felt, token1 : felt) -> (id : felt):
    assert_not_equal(token0, token1)
    let (t0, t1) = sortPair(a=token0, b=token1)
    let (id) = _pairs.read(t0, t1)
    return (id=id)
end

@external
func addPool{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        token0 : felt, token1 : felt) -> (id : felt):
    assert_not_equal(token0, token1)
    let (t0, t1) = sortPair(token0, token1)

    let (id) = _pairs.read(t0, t1)
    assert id = 0

    let (num) = _poolNum.read()

    _poolNum.write(num + 1)
    _pairs.write(token0=t0, token1=t1, value=num + 1)
    _pools.write(id = num+1,value = PoolToken(token0=t0, token1=t1, reserve0=Uint256(low=0,high=0), reserve1=Uint256(low=0,high=0)))

    return (id=num + 1)
end

func swap{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(id : felt, amountIn : Uint256, minAmountOut : Uint256, to : felt) -> ():
    let (pool) = getPool(id)
    
    assert_not_zero(pool.token0)

    # todo 没搞完
    amount0.high = 
    
    # (r0 * r1)/(r0 + r1) = amountout
    return ()
end