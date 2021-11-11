/* eslint-disable prettier/prettier */
/* eslint-disable no-undef */
/* eslint-disable no-unused-vars */
import { expect } from 'chai';
import { Contract, providers } from 'ethers';
import { ethers } from 'hardhat';
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';

describe('DEX', async () => {
	let owner: SignerWithAddress;
	let dex: Contract;
	let gold: Contract;

	const approvalAmount = '1000';
	const token = ethers.utils.parseEther('275');
	const eth = ethers.utils.parseEther('110');
	const exchangeTokens = ethers.utils.parseEther('5');

	const getBalances = async () => {
		const etherBalance = await ethers.provider.getBalance(dex.address);
		const tokenBalance = await gold.balanceOf(dex.address);
		console.log(
			ethers.utils.formatEther(etherBalance),
			ethers.utils.formatEther(tokenBalance)
		);
	};

	before('Should be deployed', async () => {
		[owner] = await ethers.getSigners();

		const DEX = await ethers.getContractFactory('Dex');
		dex = await DEX.deploy();
		await dex.deployed();

		const GOLD = await ethers.getContractFactory('Gold');
		gold = await GOLD.deploy();
		await gold.deployed();
	});

	it('approve dex to spend erc20 tokens', async () => {
		const approval = ethers.utils.parseEther(approvalAmount);
		gold.approve(dex.address, approval);
		const allowance = await gold.allowance(owner.address, dex.address);
		expect(approvalAmount === allowance);
	});

	it('initialize DEX', async () => {
		await dex.initialize(gold.address, token, { value: eth });
		const totalLiq = await dex.totalLiquidity();
		expect(totalLiq).to.be.equal(eth);
		expect(dex.balance).to.be.equal(eth);
	});

	it('should calculate 5 eth for token', async () => {
		const tokenPrice = await dex.tokenPrice(exchangeTokens, eth, token);
	});

	it('should swap 5 eth for the token', async () => {
		await dex.ethToTokenSwap({ value: exchangeTokens });
	});

	it('should swap 5 tokens for eth', async () => {
		await dex.tokenToEth(exchangeTokens);
	});
});
