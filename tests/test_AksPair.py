import os
from unittest import result

import pytest
from starkware.starknet.testing.starknet import Starknet

# The path to the contract source code.
CONTRACT_FILE = os.path.join("contracts", "AksPair.cairo")


# The testing library uses python's asyncio. So the following
# decorator and the ``async`` keyword are needed.
@pytest.mark.asyncio
async def test_token():
    """Test increase_balance method."""
    # Create a new Starknet class that simulates the StarkNet
    # system.
    starknet = await Starknet.empty()

    # Deploy the contract.
    contract = await starknet.deploy(
        source=CONTRACT_FILE,
        constructor_calldata=[1,2,0xdead],
    )

    # Check the result of get_balance().
    token0 = await contract.token0().call()
    token1 = await contract.token1().call()
    assert token0.result == (1,)
    assert token1.result == (2,)

@pytest.mark.asyncio
async def test_metadata():
    
    starknet = await Starknet.empty()

    # Deploy the contract.
    contract = await starknet.deploy(
        source=CONTRACT_FILE,
        constructor_calldata=[1,2,0xdead],
    )

    # Check the result of get_balance().
    result = await contract.name().call()
    assert result.result == (280975592528,)

    result = await contract.symbol().call()
    assert result.result == (19536,)

    result = await contract.decimals().call()
    assert result.result == (18,)

    total = await contract.totalSupply().call()
    assert total.result == ((0,0),)
    