const starknet = require("hardhat").starknet;

async function main() {
    // AKS Wrapper ETH
    let contract2 = await starknet.getContractFactory("")
    let c2 = await contract2.deploy({
        "name": starknet.stringToBigInt('AETH'),
        "symbol": starknet.stringToBigInt('AETH'),
        // 总量一亿
        "initial_supply": { "low": BigInt('0x52b7d2dcc80cd2e4000000'), "high":0},
        "recipient": BigInt('0x05b86b86d0b30b378d89b492f90a87bd30e637a01e2149f19234d21f7b8c29c8'),
    })
    console.log("Token B address",c2.address)
}

console.log("script start\r\n")
main()
console.log("script end\r\n")