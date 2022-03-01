import { ethers } from "hardhat";
import { Greeter__factory } from "../typechain";

async function main() {
  const signers = await ethers.getSigners();

  const greeter = await new Greeter__factory(signers[0]).deploy("Pepega Chain");
  await greeter.deployed();
  console.log("Greeter deployed to:", greeter.address);
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
