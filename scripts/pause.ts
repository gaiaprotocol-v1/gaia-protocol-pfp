import hardhat from "hardhat";

async function main() {
    console.log("pause start")

    const GaiaGenesis = await hardhat.ethers.getContractFactory("GaiaGenesis")
    const genesis = GaiaGenesis.attach("0x9f69C2a06c97fCAAc1E586b30Ea681c43975F052")
    await genesis.setPause(true);
    console.log("Done")
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });