import { expect } from 'chai';
import { ethers } from 'hardhat';

describe('VoidToken', function () {
  it('Should return the name of the coin', async function () {
    const voidToken = await (await ethers.getContractFactory('VoidToken')).deploy();

    expect(await voidToken.name()).to.be.equal('Void Token');
  });
  it('Should match the totalSupply with the Owner Balance', async function () {
    const [owner] = await ethers.getSigners();
    const voidToken = await (await ethers.getContractFactory('VoidToken')).deploy();
    const ownerBalance = await voidToken.balanceOf(owner.address);

    expect(await voidToken.totalSupply()).to.be.equal(ownerBalance);
  });
  it('Should Transfer 50 coins to a account', async function () {
    const fifty = ethers.BigNumber.from(50);
    const [owner, account1] = await ethers.getSigners();
    const voidToken = await (await ethers.getContractFactory('VoidToken')).deploy();
    const ownerBalance = await voidToken.balanceOf(owner.address);
    await voidToken.transfer(account1.address, fifty);

    expect(await voidToken.balanceOf(account1.address)).to.be.eqls(fifty);
    expect(await voidToken.balanceOf(owner.address)).to.be.equals(Number(ownerBalance) - Number(fifty));
  });
});
