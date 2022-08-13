import hardhat from "hardhat";

async function main() {
    console.log("deploy start")

    const GaiaStableDAO = await hardhat.ethers.getContractFactory("GaiaStableDAO")
    const stableDAO = await GaiaStableDAO.deploy()
    console.log(`GaiaStableDAO address: ${stableDAO.address}`)
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });