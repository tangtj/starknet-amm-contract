%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from starkware.cairo.common.uint256 import (
    Uint256, uint256_le, uint256_mul, uint256_unsigned_div_rem, uint256_add, uint256_sub)
from starkware.starknet.common.syscalls import get_caller_address, get_contract_address

from contracts.lib.utils.constants import TRUE
from starkware.cairo.common.math import assert_not_equal, assert_not_zero

from contracts.lib.token.IERC20 import IERC20
from contracts.AksLibrary import sortPair

struct PoolToken:
    member token0 : felt
    member token1 : felt
    member reserve0 : Uint256
    member reserve1 : Uint256
    member k_high : Uint256
    member k_low : Uint256
end

@storage_var
func _poolNum() -> (num : felt):
end

@storage_var
func _pools(id : felt) -> (pool : PoolToken):
end

@view
func getPool{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(id : felt) -> (
        pool : PoolToken):
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
    _pools.write(
        id=num + 1,
        value=PoolToken(token0=t0, token1=t1, reserve0=Uint256(low=0, high=0), reserve1=Uint256(low=0, high=0)))

    return (id=num + 1)
end

@external
func swap{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        id : felt, inToken : felt, amountIn : Uint256, minAmountOut : Uint256, to : felt) -> ():
    let (pool) = getPool(id)

    assert_not_zero(pool.token0)

    if pool.token0 == inToken:
        let (out) = getAmountOut(amountIn, pool.reserve0, pool.reserve1)

        let (fromAddr) = get_caller_address()
        IERC20.transferFrom(
            contract_address=pool.token0, sender=fromAddr, recipient=to, value=amountIn)
        let (fromContract) = get_caller_address()
        IERC20.transferFrom(
            contract_address=pool.token1, sender=fromContract, recipient=to, value=out)

        let (reserve0After) = uint256_add(pool.reserve0, amountIn)
        let (reserve1After) = uint256_sub(pool.reserve1, out)
        let (k_high, k_low) = uint256_mul(reserve0After, reserve1After)

        let (high_lt) = uint256_lt(pool.k_high, k_high)
        let (low_le) = uint256_le(pool.k_low, k_low)
        assert_lt(0,(high_le * 10) + (low_le * 1))

        pool.k_high = k_high
        pool.k_low = k_low

        _pools.write(id=id, value=pool)
    else:
        let (in) = getAmountIn(amountIn, pool.reserve0, pool.reserve1)

        let (fromAddr) = get_caller_address()
        IERC20.transferFrom(
            contract_address=pool.token1, sender=fromAddr, recipient=to, value=amountIn)
        let (fromContract) = get_caller_address()
        IERC20.transferFrom(
            contract_address=pool.token0, sender=fromContract, recipient=to, value=out)

        let (reserve0After) = uint256_add(pool.reserve0, amountIn)
        let (reserve1After) = uint256_sub(pool.reserve1, out)
        let (k_high, k_low) = uint256_mul(reserve0After, reserve1After)

        let (high_lt) = uint256_lt(pool.k_high, k_high)
        let (low_le) = uint256_le(pool.k_low, k_low)
        assert_lt(0,(high_le * 10) + (low_le * 1))

        pool.k_high = k_high
        pool.k_low = k_low

        _pools.write(id=id, value=pool)
    end
    return ()
end

func getAmountOut{syscall_ptr : felt*, range_check_ptr}(
        amountIn : Uint256, reserveIn : Uint256, reserveOut : Uint256) -> (amountOut : Uint256):
    # require(amountIn > 0, 'UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT');
    # require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
    # uint amountInWithFee = amountIn.mul(997);
    # uint numerator = amountInWithFee.mul(reserveOut);
    # uint denominator = reserveIn.mul(1000).add(amountInWithFee);
    # amountOut = numerator / denominator;

    # 无 tax demo  不会超出 uint256
    let (numerator, _) = uint256_mul(amountIn, reserveOut)
    let (denominator, _) = uint256_add(reserveIn, amountIn)
    let (result, _) = uint256_unsigned_div_rem(numerator, denominator)
    return (amountOut=result)
end

func getAmountIn{syscall_ptr : felt*, range_check_ptr}(
        amountOut : Uint256, reserveIn : Uint256, reserveOut : Uint256) -> (amountIn : Uint256):
    # require(amountOut > 0, 'UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT');
    # require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
    # uint numerator = reserveIn.mul(amountOut).mul(1000);
    # uint denominator = reserveOut.sub(amountOut).mul(997);
    # amountIn = (numerator / denominator).add(1);

    # 无 tax demo  不会超出 uint256
    let (numerator, _) = uint256_mul(amountOut, reserveIn)
    let (denominator) = uint256_sub(reserveOut, amountOut)
    let (result, _) = uint256_unsigned_div_rem(numerator, denominator)
    return (amountIn=result)
end