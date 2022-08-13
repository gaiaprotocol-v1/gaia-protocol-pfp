import fs from "fs";
import hre from "hardhat";

async function main() {
    const provider = new hre.ethers.providers.JsonRpcProvider("https://klaytn04.fandom.finance");
    const NFT = await hre.ethers.getContractFactory("ERC721G");
    const genesis = NFT.attach("0xBb915237D8b46Dcdfe813c914Bf98708e0dAd84A").connect(provider);

    const promises: Promise<void>[] = [];
    let genesisEOA: any[] = [];
    let genesisCA: any[] = [];
    for (let id = 0; id < 2177; id++) {
        promises.push(new Promise(async (resolve) => {
            const run = async () => {
                try {
                    const owner = await genesis.ownerOf(id);
                    if (await provider.getCode(owner) == "0x") genesisEOA.push({ id, owner });
                    else genesisCA.push({ id, owner });
                } catch (error) {
                    console.log(error, "Retry...");
                    await run();
                }
            };
            await run();
            resolve();
        }));
    }
    await Promise.all(promises);

    fs.writeFileSync("genesis-eoa.json", JSON.stringify(genesisEOA));
    fs.writeFileSync("genesis-ca.json", JSON.stringify(genesisCA));
}

main();
