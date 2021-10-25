//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DEX {

    IERC20 token;  
    uint256 public totalLiquidity;
    mapping (address=>uint256) public tokenLiquidity;

    modifier firstTimeOnly{
        require(totalLiquidity == 0, "DEX::initialize: already init!");
        _;
    }
    
    // Fallback
    // fallback () external payable {
    //   ethToToken(msg.value, 1, block.timestamp, msg.sender, msg.sender);
    // }

    function initialize(address _tokenAddress, uint256 _tokenAmount) firstTimeOnly payable external {
        totalLiquidity = msg.value;
        tokenLiquidity[msg.sender] = totalLiquidity;
        require(IERC20(_tokenAddress).transferFrom(msg.sender, address(this), _tokenAmount));        
    }


    //Only works for ETH to Token
    function tokenPrice(uint256 _inputTokenAmount, uint256 _inputTokenReserve, uint256 _outputTokenReserve) public view returns(uint256){
        uint k = _inputTokenReserve * _outputTokenReserve;
        uint yToken = k / (_inputTokenReserve + _inputTokenAmount);
        return _outputTokenReserve - yToken;    
    }

    function ethToToken(address _tokenAddress) external payable returns(uint256){
        uint256 tokenReserve = IERC20(_tokenAddress).balanceOf(address(this));
        uint256 ethReserve = address(this).balance - msg.value;
        uint256 tokenAmount = tokenPrice(msg.value, ethReserve ,tokenReserve);
        require(IERC20(_tokenAddress).transfer(msg.sender, tokenAmount), "Transaction Failed!");
        return tokenAmount;
    }

    function tokenToEth(address _tokenAddress, uint _tokenAmount) external returns(uint256){
        uint256 tokenReserve = IERC20(_tokenAddress).balanceOf(address(this));
        uint tokenSwapPrice = tokenPrice(_tokenAmount, tokenReserve, address(this).balance);
        (bool success,) = payable(msg.sender).call{value: tokenSwapPrice}("");
        require(success);
        require(IERC20(_tokenAddress).transferFrom(msg.sender, address(this), _tokenAmount));
        return tokenSwapPrice;
    }

    function deposit() payable external{
        uint tokenBalance = token.balanceOf(address(this));
        uint ethReserve = address(this).balance - msg.value;
        uint tokenAmount = (msg.value * tokenBalance) / ethReserve;        
        tokenLiquidity[msg.sender] = tokenLiquidity[msg.sender] + msg.value;
        totalLiquidity = totalLiquidity + msg.value;
        require(token.transferFrom(msg.sender, address(this), tokenAmount));
    }

    function withdraw(uint256 _amount) payable external{
        uint tokenBalance = token.balanceOf(address(this));        
        uint ethAmount = (_amount * address(this).balance) / totalLiquidity;
        uint tokenAmount = (_amount * tokenBalance) / totalLiquidity;
        tokenLiquidity[msg.sender] = tokenLiquidity[msg.sender] - ethAmount;
        totalLiquidity = totalLiquidity - ethAmount;
        (bool success,) = payable(msg.sender).call{value: ethAmount}("");
        require(success);
        require(token.transfer(msg.sender, tokenAmount));

    }

}

//  /**
//    * @dev Pricing function for converting between ETH && Tokens.
//    * @param output_amount Amount of ETH or Tokens being bought.
//    * @param input_reserve Amount of ETH or Tokens (input type) in exchange reserves.
//    * @param output_reserve Amount of ETH or Tokens (output type) in exchange reserves.
//    * @return Amount of ETH or Tokens sold.
//    */

//   getOutputPrice(tokens_bought, address(this).balance.sub(max_eth), token_reserve);

//   function getOutputPrice(uint256 output_amount, uint256 input_reserve, uint256 output_reserve) public view returns (uint256) {
//     require(input_reserve > 0 && output_reserve > 0); 
//     uint256 numerator = input_reserve.mul(output_amount).mul(1000);
//     uint256 denominator = (output_reserve.sub(output_amount)).mul(997);
//     return (numerator / denominator).add(1);
//   }


//    function ethToTokenOutput(uint256 tokens_bought, uint256 max_eth, uint256 deadline, address payable buyer, address recipient) private returns (uint256) {
//     require(deadline >= block.timestamp && tokens_bought > 0 && max_eth > 0);
//     uint256 token_reserve = token.balanceOf(address(this));
//     uint256 eth_sold = getOutputPrice(tokens_bought, address(this).balance.sub(max_eth), token_reserve);
//     // Throws if eth_sold > max_eth
//     uint256 eth_refund = max_eth.sub(eth_sold);
//     if (eth_refund > 0) {
//       buyer.transfer(eth_refund);
//     }
//     require(token.transfer(recipient, tokens_bought));
//     emit TokenPurchase(buyer, eth_sold, tokens_bought);
//     return eth_sold;
//   }