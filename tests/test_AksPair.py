import os
from unittest import result

import pytest
from starkware.starknet.testing.starknet import Starknet
from starkware.starknet.testing.contract import StarknetContract
from sympy import false

# The path to the contract source code.
CONTRACT_FILE = os.path.join("contracts", "AkSwap.cairo")


# The testing library uses python's asyncio. So the following
# decorator and the ``async`` keyword are needed.
@pytest.mark.asyncio
async def test_pool_num():
    # Create a new Starknet class that simulates the StarkNet
    # system.
    starknet = await Starknet.empty()

    # Deploy the contract.
    contract = await starknet.deploy(
        source=CONTRACT_FILE,
    )

    # Check the result of get_balance().
    r = await contract.getPoolNum().call()
    assert r.result == (0,)

@pytest.mark.asyncio
async def test_add_pair():
    # Create a new Starknet class that simulates the StarkNet
    # system.
    starknet = await Starknet.empty()

    # Deploy the contract.
    contract = await starknet.deploy(
        source=CONTRACT_FILE,
    )

    # Check the result of get_balance().
    r = await contract.addPool(1,2).invoke()
    assert r.result == (1,)

    num = await contract.getPoolNum().call()
    assert num.result == (1,)

@pytest.mark.asyncio
async def test_get_pair():
    # Create a new Starknet class that simulates the StarkNet
    # system.
    starknet = await Starknet.empty()

    # Deploy the contract.
    contract = await starknet.deploy(
        source=CONTRACT_FILE,
    )

    await contract.addPool(1,2).invoke()
    await contract.addPool(2,3).invoke()

    # Check the result of get_balance().
    r = await contract.getPoolId(1,2).call()
    r2 = await contract.getPoolId(3,2).call()
    assert r.result == (1,)
    assert r2.result == (2,)

# @pytest.mark.asyncio
# async def test_get_pool():
    
#     starknet = await Starknet.empty()
#     # Deploy the contract.
#     contract = await starknet.deploy(
#         source=CONTRACT_FILE,
#     )

#     await contract.addPool(1,2).invoke()
#     await contract.addPool(2,3).invoke()

#     # Check the result of get_balance().
#     r = await contract.getPool(1).call()
#     assert r.result.token0 == 1