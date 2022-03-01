%lang starknet

from starkware.cairo.common.uint256 import Uint256

@contract_interface
namespace IAksFactory:
    func getPair(token0 : felt, token1 : felt) -> (address : felt):
    end
end
