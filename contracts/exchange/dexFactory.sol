//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./Dex.sol";

contract DexFactory {
    event CreateExchange(
        address indexed TokenAddress,
        uint256 tokensProvided,
        uint256 ethProvided,
        address indexed ExchangeAddress
    );

    uint256 public tokenCount;
    mapping(address => address) public exchangeToToken;
    mapping(address => address) public tokenToExchange;

    function createExchange(address _tokenAddress, uint256 _tokenAmount)
        external
        payable
    {
        require(
            _tokenAddress != address(0),
            "DexFactory::createExchange: Token Address is 0!"
        );
        require(
            _tokenAmount == 0,
            "DexFactory::createExchange: Token Amount is 0!"
        );
        require(msg.value == 0, "DexFactory::createExchange: ETH sent is 0!");
        Dex dex = new Dex{value: msg.value}(_tokenAddress, _tokenAmount);

        tokenToExchange[_tokenAddress] = address(dex);
        exchangeToToken[address(dex)] = _tokenAddress;
        tokenCount++;

        emit CreateExchange(_tokenAddress, address(dex));
    }

    function getExchange(address _tokenAddress) public view returns (address) {
        return exchangeToToken[_tokenAddress];
    }

    function getToken(address _exchangeAddress) public view returns (address) {
        return tokenToExchange[_exchangeAddress];
    }
}
