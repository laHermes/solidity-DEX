/* eslint-disable prettier/prettier */
/* eslint-disable no-undef */
/* eslint-disable no-unused-vars */
import { expect } from "chai";
import { Contract } from "ethers";
import { ethers } from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

describe("DEX", async () => {
  let owner: SignerWithAddress;
  let dex: Contract;
  let gold: Contract;

  const approvalAmount = "1000";
  const token = ethers.utils.parseEther("275");
  const eth = ethers.utils.parseEther("110");
  const exchangeTokens = ethers.utils.parseEther("5");

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
    await dex.initialize(gold.address, token, { value: eth });
    const totalLiq = await dex.totalLiquidity();
    expect(totalLiq === eth);
    expect(dex.balance === eth);
  });

  it("should calculate 5 eth for token", async () => {
    const tokenPrice = await dex.tokenPrice(exchangeTokens, eth, token);
    console.log(ethers.utils.formatEther(tokenPrice));
  });

  it("should swap 5 eth for the token", async () => {
    await dex.ethToToken(gold.address, { value: exchangeTokens });
    const ethPossessed = await dex.balance;
    const tokensPossessed = await gold.balanceOf(dex.address);
    // console.log(
    //   ethers.utils.formatEther(ethPossessed),
    //   ethers.utils.formatEther(tokensPossessed)
    // );
  });

  it("should swap 5 tokens for eth", async () => {
    await dex.tokenToEth(gold.address, exchangeTokens);
    const ethPossessed = await dex.address;
    const tokensPossessed = await gold.balanceOf(dex.address);

    console.log(ethPossessed);
  });
});
