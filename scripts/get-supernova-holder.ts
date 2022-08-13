import fs from "fs";
import hre from "hardhat";

async function main() {
    const provider = new hre.ethers.providers.JsonRpcProvider("https://klaytn04.fandom.finance");
    const NFT = await hre.ethers.getContractFactory("ERC721G");
    const supernova = NFT.attach("0x89a18aBAB20aaB069feB7cab20517630Ee7C1626").connect(provider);

    const promises: Promise<void>[] = [];
    let supernovaEOA: any[] = [];
    let supernovaCA: any[] = [];
    for (let id = 0; id < 1000; id++) {
        promises.push(new Promise(async (resolve) => {
            const run = async () => {
                try {
                    const owner = await supernova.ownerOf(id);
                    if (await provider.getCode(owner) == "0x") supernovaEOA.push({ id, owner });
                    else supernovaCA.push({ id, owner });
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

    fs.writeFileSync("supernova-eoa.json", JSON.stringify(supernovaEOA));
    fs.writeFileSync("supernova-ca.json", JSON.stringify(supernovaCA));
}

main();
