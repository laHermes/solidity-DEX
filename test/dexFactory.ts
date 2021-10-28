/* eslint-disable prettier/prettier */
/* eslint-disable no-undef */
/* eslint-disable no-unused-vars */
import { expect } from "chai";
import { Contract, providers } from "ethers";
import { ethers } from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

describe("DexFactory", async () => {
  let owner: SignerWithAddress;
  let dfactory: Contract;

  before("Deploy DEX factory", async () => {
    [owner] = await ethers.getSigners();

    const DEXFactory = await ethers.getContractFactory("DexFactory");
    dfactory = await DEXFactory.deploy();
    await dfactory.deployed();

  });

 
 });
