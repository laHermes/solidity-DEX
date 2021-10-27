/* eslint-disable prettier/prettier */
/* eslint-disable no-undef */
/* eslint-disable no-unused-vars */
import { expect } from "chai";
import { Contract, providers } from "ethers";
import { ethers } from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

describe("DexFactory", async () => {
  let owner: SignerWithAddress;
  let dex: Contract;


  before("Should be deployed", async () => {
    [owner] = await ethers.getSigners();

    const DEX = await ethers.getContractFactory("DexFactory");
    dex = await DEX.deploy();
    await dex.deployed();

  });

  it("runs", async()=>{
    await dex.transfer()
  })
 
});
