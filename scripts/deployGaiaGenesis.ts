import hardhat from "hardhat";

async function main() {
    console.log("deploy start")

    const GaiaGenesis = await hardhat.ethers.getContractFactory("GaiaGenesis")
    const genesis = await GaiaGenesis.deploy()
    console.log(`GaiaGenesis address: ${genesis.address}`)
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });