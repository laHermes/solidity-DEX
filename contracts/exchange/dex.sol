//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DEX {

    IERC20 token;
    uint256 public totalLiquidity;
    mapping (address=>uint256) tokenLiquidity;

    modifier firstTimeOnly{
        require(totalLiquidity == 0, "DEX already init!");
        _;
    }

    function initialize(address _tokenAddress, uint256 _tokenAmount) firstTimeOnly payable external {
        totalLiquidity = msg.value;
        tokenLiquidity[msg.sender] = totalLiquidity;
        require(token(_tokenAddress).transferForom(smg.sender, address(this), _tokenAmount);        
    }

    function tokenPrice(uint256 _amountRequested, uint256 _reserveLevels) public returns(uint256){
    
    }

    function ethToToken(address _tokenAddress) external payable{
        uint256 reserve = token(_tokenAddress).balanceOf(this(address));
        //determine token price
        uint256 tokenAmount = price()
        request(token(_tokenAddress).transfer(msg.sender, msg.sender), "Transaction Failed!");
    }

    function tokenToEth() external{

    }

    function deposite() external{

    }

    function withdraw() external{

    }



}