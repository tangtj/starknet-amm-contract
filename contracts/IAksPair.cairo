%lang starknet

from starkware.cairo.common.uint256 import Uint256

@contract_interface
namespace IAksPair:
    # function mint(address to) external returns (uint liquidity);
    #   function burn(address to) external returns (uint amount0, uint amount1);
    #   function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    #
    # Getters
    #

    func mint(to : felt) -> (res : Uint256):
    end

    func burn(to : felt) -> (amount0 : Uint256, amount1 : Uint256):
    end

    func swap(amount0Out : Uint256, amount1Out : Uint256, to : felt):
    end

    func getReserves() -> (reserve0 : Uint256, reserve1 : Uint256):
    end
end
