/* eslint-disable prettier/prettier */
/* eslint-disable no-undef */
/* eslint-disable no-unused-vars */
import { expect } from 'chai';
import { Contract, providers } from 'ethers';
import { ethers } from 'hardhat';
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';

describe('DEX', async () => {
	let owner: SignerWithAddress;
	let factory: Contract;
	let exchange: Contract;
	let erc20: Contract;

	const approvalAmount = '1000';
	const token = ethers.utils.parseEther('275');
	const eth = ethers.utils.parseEther('110');
	const exchangeTokens = ethers.utils.parseEther('5');

	before('Deploy Factory & ERC20 token', async () => {
		[owner] = await ethers.getSigners();

		const ExchangeFactory = await ethers.getContractFactory('ExchangeFactory');
		factory = await ExchangeFactory.deploy();
		await factory.deployed();

		const ERC20Token = await ethers.getContractFactory('WrappedMatic');
		erc20 = await ERC20Token.deploy();
		await erc20.deployed();
	});

	it('should approve factory to spend erc20 tokens', async () => {
		const approval = ethers.utils.parseEther(approvalAmount);
		erc20.approve(factory.address, approval);
		const allowance = await erc20.allowance(owner.address, factory.address);
		expect(approvalAmount === allowance);
	});

	it('should create an exchange', async () => {
		await factory.createExchange(erc20.address, token, { value: eth });
		exchange = factory.getExchange(erc20.address);
		const totalLiq = await exchange.totalLiquidity();
		expect(totalLiq).to.be.equal(eth);
		expect(exchange.balance).to.be.equal(eth);
	});

	// it('should calculate 5 eth for token', async () => {
	// 	const tokenPrice = await dex.tokenPrice(exchangeTokens, eth, token);
	// });

	// it('should swap 5 eth for the token', async () => {
	// 	await dex.ethToTokenSwap({ value: exchangeTokens });
	// });

	// it('should swap 5 tokens for eth', async () => {
	// 	await dex.tokenToEth(exchangeTokens);
	// });
});

// const getBalances = async () => {
// 	const etherBalance = await ethers.provider.getBalance(dex.address);
// 	const tokenBalance = await gold.balanceOf(dex.address);
// 	console.log(
// 		ethers.utils.formatEther(etherBalance),
// 		ethers.utils.formatEther(tokenBalance)
// 	);
// };
