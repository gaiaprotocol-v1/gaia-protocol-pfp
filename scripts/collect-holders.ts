import fs from "fs";
import hardhat from "hardhat";

const CHAIN = "klaytn";
const COLLECTION = "genesis";
const ADDR = "0x20a33C651373cde978daE404760e853fAE877588";

async function main() {
    const GaiaGenesis = await hardhat.ethers.getContractFactory("GaiaGenesis")
    const nft = GaiaGenesis.attach(ADDR)

    const promises: Promise<void>[] = [];
    let eoa: any[] = [];
    let ca: any[] = [];
    for (let id = 0; id < 1000; id++) {
        promises.push(new Promise(async (resolve) => {
            const run = async () => {
                try {
                    const owner = await nft.ownerOf(id);
                    if (await hardhat.ethers.provider.getCode(owner) == "0x") eoa.push({ id, owner });
                    else ca.push({ id, owner });
                } catch (error) {
                    if ((error as any).reason !== "ERC721G: invalid token ID") {
                        console.log(error, "Retry...");
                        setTimeout(async () => await run(), 2000);
                    }
                }
            };
            await run();
            resolve();
        }));
    }
    await Promise.all(promises);

    fs.writeFileSync("holders/" + CHAIN + "-" + COLLECTION + "-eoa.json", JSON.stringify(eoa));
    fs.writeFileSync("holders/" + CHAIN + "-" + COLLECTION + "-ca.json", JSON.stringify(ca));
}

main();
