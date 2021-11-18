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

    receive() external payable {}

    function initialize(address _tokenAddress, uint256 _tokenAmount)
        external
        payable
    {
        require(totalLiquidity == 0, "DEX::initialize: already init!");
        require(
            _tokenAddress != address(0),
            "DEX::initialize:Token Address is 0!"
        );
        require(_tokenAmount != 0, "DEX::initialize: Token Amount is 0!");
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
    ) public pure returns (uint256) {
        uint256 k = _inputTokenReserve * _outputTokenReserve;
        uint256 yToken = k / (_inputTokenReserve + _inputTokenAmount);
        return _outputTokenReserve - yToken;
    }

    function ethToToken(uint256 _inputEth) private returns (uint256) {
        uint256 tokenReserve = token.balanceOf(address(this));
        uint256 ethReserve = address(this).balance - _inputEth;
        uint256 tokenAmount = tokenPrice(_inputEth, ethReserve, tokenReserve);
        require(
            tokenReserve > 0 && ethReserve > 0,
            "DEX::ethToToken: Reserve Too Low!"
        );
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
        uint256 tokenAmount = msg.value * (tokenBalance / ethReserve);
        tokenLiquidity[msg.sender] = tokenLiquidity[msg.sender] + msg.value;
        totalLiquidity = totalLiquidity + msg.value;
        require(
            token.transferFrom(msg.sender, address(this), tokenAmount),
            "DEX::deposit:Token Transaction Failed!"
        );
    }

    function withdraw(uint256 _amount) external payable {
        uint256 tokenBalance = token.balanceOf(address(this));
        uint256 ethAmount = _amount * (address(this).balance / totalLiquidity);
        uint256 tokenAmount = _amount * (tokenBalance / totalLiquidity);
        tokenLiquidity[msg.sender] = tokenLiquidity[msg.sender] - ethAmount;
        totalLiquidity = totalLiquidity - ethAmount;
        (bool success, ) = payable(msg.sender).call{value: ethAmount}("");
        require(success, "DEX::withdraw: ETH Transaction Failed!");
        require(
            token.transfer(msg.sender, tokenAmount),
            "DEX::withdraw: Token Transaction Failed!"
        );
    }
}
