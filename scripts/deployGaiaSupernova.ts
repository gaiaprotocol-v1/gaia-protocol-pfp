import hardhat from "hardhat";

async function main() {
    console.log("deploy start")

    const GaiaSupernova = await hardhat.ethers.getContractFactory("GaiaSupernova")
    const supernova = await GaiaSupernova.deploy()
    console.log(`GaiaSupernova address: ${supernova.address}`)
}

main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });