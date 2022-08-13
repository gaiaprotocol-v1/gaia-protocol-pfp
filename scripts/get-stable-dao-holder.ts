import fs from "fs";
import hre from "hardhat";

async function main() {
    const provider = new hre.ethers.providers.JsonRpcProvider("https://klaytn04.fandom.finance");
    const NFT = await hre.ethers.getContractFactory("ERC721G");
    const stableDAO = NFT.attach("0xEccE87e11d057713665F020C5e206E18fCCBc8B7").connect(provider);

    const promises: Promise<void>[] = [];
    let stableDAOEOA: any[] = [];
    let stableDAOCA: any[] = [];
    for (let id = 0; id < 1000; id++) {
        promises.push(new Promise(async (resolve) => {
            const run = async () => {
                try {
                    if (await stableDAO.exists(id) === true) {
                        const owner = await stableDAO.ownerOf(id);
                        if (await provider.getCode(owner) == "0x") stableDAOEOA.push({ id, owner });
                        else stableDAOCA.push({ id, owner });
                    }
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

    fs.writeFileSync("stableDAO-eoa.json", JSON.stringify(stableDAOEOA));
    fs.writeFileSync("stableDAO-ca.json", JSON.stringify(stableDAOCA));
}

main();
