//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DEX {

    // Variables, Events 

    new Event
    IERC20 token;  
    uint256 public totalLiquidity;
    mapping (address=>uint256) tokenLiquidity;

    modifier firstTimeOnly{
        require(totalLiquidity == 0, "DEX already init!");
        _;
    }

    // Fallback
    function () external payable {
      ethToTokenInput(msg.value, 1, block.timestamp, msg.sender, msg.sender);
    }

    // Initializer
    function initialize(address _tokenAddress, uint256 _tokenAmount) firstTimeOnly payable external {
        totalLiquidity = msg.value;
        tokenLiquidity[msg.sender] = totalLiquidity;
        require(token(_tokenAddress).transferForom(smg.sender, address(this), _tokenAmount);        
    }

    // Token Price Calculator
    function tokenPrice(uint256 _inputAmount, uint256 _tokenReserve) public returns(uint256){
        return ( _inputAmount * _tokenReserve) / address(this).balance;
    }

    // Transaction functions
    function ethToToken(address _tokenAddress) external payable {
        uint256 tokenReserve = token(_tokenAddress).balanceOf(this(address));
        uint256 tokenAmount = tokenPrice(msg.value, tokenReserve)
        request(token(_tokenAddress).transfer(msg.sender, tokenAmount), "Transaction Failed!");
    }

    function tokenToEth(address _tokenAddress, uint _tokenAmount) external{
        request(token(_tokenAddress).transferFrom(msg.sender, address(this), _tokenAmount))
        tokenPrice = tokenPrice(_tokenAmount, )
        // claculate token price

        (bool success,) = payable(msg.sender).call{value: msg.value}("")
    }

    function deposite() external{

    }

    function withdraw() external{

    }



}

 /**
   * @dev Pricing function for converting between ETH && Tokens.
   * @param output_amount Amount of ETH or Tokens being bought.
   * @param input_reserve Amount of ETH or Tokens (input type) in exchange reserves.
   * @param output_reserve Amount of ETH or Tokens (output type) in exchange reserves.
   * @return Amount of ETH or Tokens sold.
   */

  getOutputPrice(tokens_bought, address(this).balance.sub(max_eth), token_reserve);

  function getOutputPrice(uint256 output_amount, uint256 input_reserve, uint256 output_reserve) public view returns (uint256) {
    require(input_reserve > 0 && output_reserve > 0); 
    uint256 numerator = input_reserve.mul(output_amount).mul(1000);
    uint256 denominator = (output_reserve.sub(output_amount)).mul(997);
    return (numerator / denominator).add(1);
  }


   function ethToTokenOutput(uint256 tokens_bought, uint256 max_eth, uint256 deadline, address payable buyer, address recipient) private returns (uint256) {
    require(deadline >= block.timestamp && tokens_bought > 0 && max_eth > 0);
    uint256 token_reserve = token.balanceOf(address(this));
    uint256 eth_sold = getOutputPrice(tokens_bought, address(this).balance.sub(max_eth), token_reserve);
    // Throws if eth_sold > max_eth
    uint256 eth_refund = max_eth.sub(eth_sold);
    if (eth_refund > 0) {
      buyer.transfer(eth_refund);
    }
    require(token.transfer(recipient, tokens_bought));
    emit TokenPurchase(buyer, eth_sold, tokens_bought);
    return eth_sold;
  }