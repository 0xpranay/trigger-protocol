// run with
// npx hardhat run <this file> --network ganache
import { BigNumber } from "ethers";
import hre from "hardhat";

async function main() {
  const ethers = hre.ethers;
  const [deployer] = await hre.ethers.getSigners();

  console.log("Deploying erc20 test token");

  try {
    const triggerFactory = await ethers.getContractFactory("Trigger");
    const trigger = await triggerFactory.deploy(
      "0xf0511f123164602042ab2bCF02111fA5D3Fe97CD"
    );
    console.log("Deployed to: ", trigger.address);
  } catch (e: any) {
    console.log("ERROR: ", e);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
