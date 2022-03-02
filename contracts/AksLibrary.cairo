%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from starkware.cairo.common.uint256 import (
    Uint256, uint256_le, uint256_mul, uint256_unsigned_div_rem, uint256_add, uint256_sub)
from starkware.starknet.common.syscalls import get_caller_address, get_contract_address
from contracts.IAksPair import IAksPair

from contracts.IAksFactory import IAksFactory

from contracts.lib.utils.constants import TRUE

from contracts.lib.token.IERC20 import IERC20

const factoryAddress = 1

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

# 通过币种对 获取 出入价格
func getAmountOutForToken{syscall_ptr : felt*, range_check_ptr}(
        in : Uint256, inToken : felt, outToken : felt) -> (amountOut : Uint256):
    let (token0, token1) = sortPair(inToken, outToken)
    let factoryAddress : felt = 1

    # 获取 币对次Id
    let (pairId) = IAksFactory.getPair(
        contract_address=factoryAddress, token0=token0, token1=token1)

    # 通过币对池id获取 数量
    let (reserve0, reserve1) = IAksPair.getReserves(contract_address=pairId)

    if token0 == inToken:
        # 刚好是正向顺序
        return getAmountOut(in, reserve0, reserve1)
    end

    return getAmountOut(in, reserve1, reserve0)
end

func getAmountInForToken{syscall_ptr : felt*, range_check_ptr}(
        out : Uint256, outToken : felt, inToken : felt) -> (amountIn : Uint256):
    let (token0, token1) = sortPair(inToken, outToken)
    let factoryAddress : felt = 1

    # 获取 币对次Id
    let (pairId) = IAksFactory.getPair(
        contract_address=factoryAddress, token0=token0, token1=token1)

    # 通过币对池id获取 数量
    let (reserve0, reserve1) = IAksPair.getReserves(contract_address=pairId)

    if token0 == outToken:
        # 刚好是正向顺序
        return getAmountIn(out, reserve0, reserve1)
    end

    return getAmountIn(out, reserve1, reserve0)
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

func sortPair{syscall_ptr : felt*, range_check_ptr}(a : felt, b : felt) -> (
        token0 : felt, token1 : felt):
    tempvar d = a - b
    tempvar r = (d) * (-1)

    # 如果 a < b 则  (a-b)<0 为负数  r = a * -1 为正数 则 d != r
    if r == d:
        # a > b
        return (token0=a, token1=b)
    end
    return (token0=b, token1=a)
end

func swapForToken{syscall_ptr : felt*, range_check_ptr}(
        amountIn : Uint256, inToken : felt, outToken : felt, to : felt) -> (amountOut : Uint256):
    alloc_locals
    let i = 0
    let (is_gt_zero) = uint256_le(Uint256(low=0, high=0), amountIn)
    assert is_gt_zero = 1

    let (token0, token1) = sortPair(inToken, outToken)
    # 获取 币对次Id
    let (pairId) = IAksFactory.getPair(
        contract_address=factoryAddress, token0=token0, token1=token1)

    let (amountOut) = getAmountOutForToken(amountIn, inToken, outToken)

    let (f) = get_caller_address()

    let (result) = IERC20.transferFrom(
        contract_address=inToken, sender=f, recipient=pairId, amount=amountIn)
    assert TRUE = result

    IAksPair.swap(contract_address=pairId, amount0Out=amountIn, amount1Out=amountOut, to=to)
    return (amountOut=amountOut)
end
