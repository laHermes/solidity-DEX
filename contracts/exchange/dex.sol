//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DEX {


    uint256 public totalLiquidity;
    mapping (address=>uint256) tokenLiquidity;

    modifier firstTimeOnly{
        require(totalLiquidity == 0, "DEX already init!");
        _;
    }

    function initialize(address _tokenAddress) firstTimeOnly payable external {
        

    }
    function ethToToken() external payable{

    }

    function tokenToEth() external{

    }

    function deposite() external{

    }

    function withdraw() external{

    }



}