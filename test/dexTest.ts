/* eslint-disable prettier/prettier */
/* eslint-disable no-undef */
/* eslint-disable no-unused-vars */
import { expect, assert } from "chai";
import { Contract } from "ethers";
import { ethers } from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

describe("DEX", async () => {
  let owner: SignerWithAddress;
  let dex: Contract;
  let gold: Contract;

  const approvalAmount = "100";
  const tokenAndEth = ethers.utils.parseEther("10");
  const exchangeTokens = ethers.utils.parseEther("0.5");

  before("Should be deployed", async () => {
    [owner] = await ethers.getSigners();

    const DEX = await ethers.getContractFactory("DEX");
    dex = await DEX.deploy();
    await dex.deployed();

    const GOLD = await ethers.getContractFactory("Gold");
    gold = await GOLD.deploy();
    await gold.deployed();
  });

  it("approve dex to spend erc20 tokens", async () => {
    const approval = ethers.utils.parseEther(approvalAmount);
    gold.approve(dex.address, approval);
    const allowance = await gold.allowance(owner.address, dex.address);
    expect(approvalAmount === allowance);
  });

  it("initialize DEX", async () => {
    await dex.initialize(gold.address, tokenAndEth, { value: tokenAndEth });
    const totalLiq = await dex.totalLiquidity();
    expect(totalLiq === tokenAndEth);
    expect(dex.balance === tokenAndEth);
  });

  it("Exchange eth for the token", async () => {
    await dex.ethToToken(gold.address, { value: exchangeTokens });
    const tokenBalance = await gold.balanceOf(owner.address);
    console.log(ethers.utils.formatEther(tokenBalance));
  });
});
