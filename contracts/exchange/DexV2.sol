//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./dexFactory.sol";

contract DexV2 is IERC20 {

 /* ========== STATE VARIABLES ========== */
    IERC20 public tokenA;
    IERC20 public tokenB;

	uint256 public tokenASupply;
	uint256 public tokenBSupply;

    DexFactory public factory;

    uint256 public totalLiquidity;

    uint256 public invariant;

    mapping(address => uint256) public tokenLiquidity;
    mapping(address => uint256) public tokensStaked;

    uint public constant MINIMUM_LIQUIDITY = 10**3;

	constructor() IERC20("LProvider", "LP"){
		factory = msg.sender;
	}


    /* ========== FALLBACKS & MODIFIERS ========== */

    fallback() external payable {
    }

    receive() external payable {}




