import "dotenv/config";
import "@nomiclabs/hardhat-ethers";
import "@nomiclabs/hardhat-etherscan";
import "@nomicfoundation/hardhat-chai-matchers";
import "@typechain/hardhat";
import { HardhatUserConfig } from "hardhat/types";
import "@nomiclabs/hardhat-solhint";
import "solidity-coverage";
// import "hardhat-gas-reporter";
import "hardhat-tracer";

const config: HardhatUserConfig = {
    solidity: {
        compilers: [
            {
                version: "0.8.15",
                settings: {
                    optimizer: {
                        enabled: true,
                        runs: 200,
                    },
                },
            },
        ],
    },
    networks: {
        mainnet: {
            url: `https://mainnet.infura.io/v3/${process.env.INFURA_API_KEY}`,
            accounts: [process.env.ADMIN || ''],
            chainId: 1,
        },
        polygon: {
            url: "https://polygon-rpc.com/",
            accounts: [process.env.ADMIN || ''],
            chainId: 137,
        },
        klaytn: {
            url: "https://klaytn04.fandom.finance/",
            accounts: [process.env.ADMIN || ''],
            chainId: 8217,
        },
    },
    etherscan: {
        apiKey: process.env.ETHERSCAN_API_KEY,
    },
};

export default config;
