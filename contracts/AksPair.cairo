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

@storage_var
func token0_() -> (token0 : felt):
end

@storage_var
func token1_() -> (token1 : felt):
end

@storage_var
func reserve0_() -> (reserve0 : Uint256):
end

@storage_var
func reserve1_() -> (reserve1 : Uint256):
end

@storage_var
func _k_high() -> (hight : Uint256):
end

@storage_var
func _k_low() -> (low : Uint256):
end

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        token0 : felt, token1 : felt):
    token0_.write(token0)
    token1_.write(token1)
    return ()
end

@view
func name{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (name : felt):
    let (name) = ERC20_name()
    return (name)
end

@view
func symbol{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (symbol : felt):
    let (symbol) = ERC20_symbol()
    return (symbol)
end

@view
func totalSupply{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        totalSupply : Uint256):
    let (totalSupply : Uint256) = ERC20_totalSupply()
    return (totalSupply)
end

@view
func decimals{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        decimals : felt):
    let (decimals) = ERC20_decimals()
    return (decimals)
end

@view
func balanceOf{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        account : felt) -> (balance : Uint256):
    let (balance : Uint256) = ERC20_balanceOf(account)
    return (balance)
end

@view
func allowance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        owner : felt, spender : felt) -> (remaining : Uint256):
    let (remaining : Uint256) = ERC20_allowance(owner, spender)
    return (remaining)
end

#
# Externals
#

@external
func transfer{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        recipient : felt, amount : Uint256) -> (success : felt):
    ERC20_transfer(recipient, amount)
    # Cairo equivalent to 'return (true)'
    return (TRUE)
end

@external
func transferFrom{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        sender : felt, recipient : felt, amount : Uint256) -> (success : felt):
    ERC20_transferFrom(sender, recipient, amount)
    # Cairo equivalent to 'return (true)'
    return (TRUE)
end

@external
func approve{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        spender : felt, amount : Uint256) -> (success : felt):
    ERC20_approve(spender, amount)
    # Cairo equivalent to 'return (true)'
    return (TRUE)
end

@external
func increaseAllowance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        spender : felt, added_value : Uint256) -> (success : felt):
    ERC20_increaseAllowance(spender, added_value)
    # Cairo equivalent to 'return (true)'
    return (TRUE)
end

@external
func decreaseAllowance{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        spender : felt, subtracted_value : Uint256) -> (success : felt):
    ERC20_decreaseAllowance(spender, subtracted_value)
    # Cairo equivalent to 'return (true)'
    return (TRUE)
end

@view
func token0{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (token0 : felt):
    let (token0) = token0_.read()
    return (token0)
end

@view
func token1{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (token0 : felt):
    let (token0) = token0_.read()
    return (token0)
end

@view
func getReserves{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
        reserve0 : Uint256, reserve1 : Uint256):
    let (reserve0) = reserve0_.read()
    let (reserve1) = reserve1_.read()
    return (reserve0, reserve1)
end

# burn 调用者代币
@external
func burn{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(to : felt) -> (
        amount0 : Uint256, amount1 : Uint256):
    alloc_locals

    let (this) = get_contract_address()

    let (local balance : Uint256) = ERC20_balanceOf(account=this)
    let (totalSupply : Uint256) = ERC20_totalSupply()

    let (reserve0) = reserve0_.read()
    let (reserve1) = reserve1_.read()

    let (token0) = token0_.read()
    let (token1) = token1_.read()

    # 判断 调用者到底有没有钱
    let (is_le) = uint256_le(balance, Uint256(low=0, high=0))
    assert is_le = 1

    # owner / total * token0
    # 预计 int112 在 int256 之内所有只需要取 low
    # 获取 amount0 的
    let (low, _) = uint256_mul(balance, reserve0)
    let (amount0, _) = uint256_unsigned_div_rem(low, totalSupply)

    # 获取 amount1 的
    let (low, _) = uint256_mul(balance, reserve1)
    let (amount1, _) = uint256_unsigned_div_rem(low, totalSupply)
    # 销毁 lp
    ERC20_burn(this, balance)

    # TODO : 这里写错了
    ERC20_transfer(to, amount0)
    ERC20_transfer(to, amount1)

    return (amount0=amount0, amount1=amount1)
end

@external
func mint{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(to : felt):
    alloc_locals

    # 获取这个合约的地址
    let (this) = get_contract_address()

    let (totalSupply : Uint256) = ERC20_totalSupply()

    let (token0) = token0_.read()
    let (token1) = token1_.read()

    let (reserve0) = reserve0_.read()
    let (reserve1) = reserve1_.read()

    let (amount0) = IERC20.balanceOf(contract_address=token0, account=this)
    let (amount1) = IERC20.balanceOf(contract_address=token1, account=this)

    # 获取 lq 比重 amount * reserve /
    let (a0 : Uint256, _) = uint256_mul(amount0, totalSupply)
    let (q0 : Uint256, _) = uint256_unsigned_div_rem(a0, reserve0)

    let (a1 : Uint256, _) = uint256_mul(amount1, totalSupply)
    let (q1 : Uint256, _) = uint256_unsigned_div_rem(a1, reserve1)

    let (lq) = min(q0, q1)

    ERC20_mint(to, lq)

    # 铸造

    return ()
end

# function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data)
func swap{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        amount0Out : Uint256, amount1Out : Uint256, to : felt, bytes : felt*):
    alloc_locals

    let (this) = get_contract_address()

    let (totalSupply : Uint256) = ERC20_totalSupply()

    let (token0) = token0_.read()
    let (token1) = token1_.read()

    let (reserve0) = reserve0_.read()
    let (reserve1) = reserve1_.read()

    let (amount0) = IERC20.balanceOf(contract_address=token0, account=this)
    let (amount1) = IERC20.balanceOf(contract_address=token1, account=this)

    # uniswap 是先转账, 后确认余额够不够
    # 如果是后转账那就 hi 需要
    let (is_le) = uint256_le(amount0Out, amount1Out)
    if is_le == 0:
        # token1 需要入账
        let (is_in) = uint256_le(a=reserve1, b=amount1)
        assert is_in = 0
    else:
        # token0 需要入账
        let (is_in) = uint256_le(a=reserve0, b=amount0)
        assert is_in = 0
    end

    let (after0) = uint256_sub(amount0, amount0Out)
    let (after1) = uint256_sub(amount1, amount1Out)
    let (k_low) = _k_low.read()
    let (k_high) = _k_high.read()

    let (t_high, t_low) = uint256_mul(after0, after1)

    # // 0 0  1 0 0 1
    # // 1 0
    let (high_le) = uint256_le(k_high, t_high)
    let (low_le) = uint256_le(k_low, t_low)
    assert high_le * 1 = 0
    assert low_le * 1 = 0

    _k_low.write(t_low)
    _k_high.write(t_high)

    _safeTransfer(token=token0, to=to, value=amount0Out)
    _safeTransfer(token=token1, to=to, value=amount1Out)

    return ()
end

func min{range_check_ptr}(a : Uint256, b : Uint256) -> (min : Uint256):
    let (is_le) = uint256_le(a, b)
    if is_le == 0:
        return (a)
    else:
        return (b)
    end
end

func man{range_check_ptr}(a : Uint256, b : Uint256) -> (min : Uint256):
    let (is_le) = uint256_le(a, b)
    if is_le == 0:
        return (b)
    else:
        return (a)
    end
end

func _safeTransfer{syscall_ptr : felt*,range_check_ptr}(token : felt, to : felt, value : Uint256) -> ():
    IERC20.transfer(contract_address=token,recipient= to,amount= value)
    return ()
end
