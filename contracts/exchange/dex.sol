//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Dex {
    IERC20 token;
    uint256 public totalLiquidity;
    mapping(address => uint256) public tokenLiquidity;

    fallback() external payable {
        ethToToken(msg.value);
    }

    function initialize(address _tokenAddress, uint256 _tokenAmount)
        external
        payable
    {
        require(totalLiquidity == 0, "DEX::initialize: already init!");
        totalLiquidity = msg.value;
        tokenLiquidity[msg.sender] = totalLiquidity;
        token = IERC20(_tokenAddress);
        require(
            IERC20(_tokenAddress).transferFrom(
                msg.sender,
                address(this),
                _tokenAmount
            )
        );
    }

    function tokenPrice(
        uint256 _inputTokenAmount,
        uint256 _inputTokenReserve,
        uint256 _outputTokenReserve
    ) public view returns (uint256) {
        uint256 k = _inputTokenReserve * _outputTokenReserve;
        uint256 yToken = k / (_inputTokenReserve + _inputTokenAmount);
        return _outputTokenReserve - yToken;
    }

    function ethToToken(uint256 _inputEth) private returns (uint256) {
        uint256 tokenReserve = token.balanceOf(address(this));
        uint256 ethReserve = address(this).balance - _inputEth;
        require(
            tokenReserve > 0 && ethReserve > 0,
            "DEX::ethToToken: Reserve Too Low!"
        );
        uint256 tokenAmount = tokenPrice(_inputEth, ethReserve, tokenReserve);
        require(
            token.transfer(msg.sender, tokenAmount),
            "DEX::ethToToken: Token Transaction Failed!"
        );
        return tokenAmount;
    }

    function ethToTokenSwap() external payable returns (uint256) {
        return ethToToken(msg.value);
    }

    function tokenToEth(uint256 _tokenAmount) external returns (uint256) {
        uint256 tokenReserve = token.balanceOf(address(this));
        uint256 tokenSwapPrice = tokenPrice(
            _tokenAmount,
            tokenReserve,
            address(this).balance
        );
        (bool success, ) = payable(msg.sender).call{value: tokenSwapPrice}("");
        require(success);
        require(
            token.transferFrom(msg.sender, address(this), _tokenAmount),
            "DEX::tokenToEth: Ether Transaction Failed!"
        );
        return tokenSwapPrice;
    }

    function deposit() external payable {
        uint256 tokenBalance = token.balanceOf(address(this));
        uint256 ethReserve = address(this).balance - msg.value;
        uint256 tokenAmount = (msg.value * tokenBalance) / ethReserve;
        tokenLiquidity[msg.sender] = tokenLiquidity[msg.sender] + msg.value;
        totalLiquidity = totalLiquidity + msg.value;
        require(
            token.transferFrom(msg.sender, address(this), tokenAmount),
            "DEX::deposit:Transaction Failed!"
        );
    }

    function withdraw(uint256 _amount) external payable {
        uint256 tokenBalance = token.balanceOf(address(this));
        uint256 ethAmount = (_amount * address(this).balance) / totalLiquidity;
        uint256 tokenAmount = (_amount * tokenBalance) / totalLiquidity;
        tokenLiquidity[msg.sender] = tokenLiquidity[msg.sender] - ethAmount;
        totalLiquidity = totalLiquidity - ethAmount;
        (bool success, ) = payable(msg.sender).call{value: ethAmount}("");
        require(success);
        require(
            token.transfer(msg.sender, tokenAmount),
            "DEX::withdraw:Transaction Failed!"
        );
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
