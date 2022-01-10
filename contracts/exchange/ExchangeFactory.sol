//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./Exchange.sol";

contract ExchangeFactory {
    event CreateExchange(
        address indexed TokenAddress,
        address indexed ExchangeAddress,
        uint256 tokensProvided,
        uint256 ethProvided
    );

    uint256 public tokenCount;
    mapping(address => address) public exchangeToToken;
    mapping(address => address) public tokenToExchange;
    address[] public allPairs;

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
        Exchange exchange = new Exchange{value: msg.value}(
            _tokenAddress,
            _tokenAmount
        );

        tokenToExchange[_tokenAddress] = address(exchange);
        exchangeToToken[address(exchange)] = _tokenAddress;
        tokenCount++;
        allPairs.push(address(exchange));
        emit CreateExchange(
            _tokenAddress,
            address(exchange),
            _tokenAmount,
            msg.value
        );
    }

    function getExchange(address _tokenAddress) public view returns (address) {
        return exchangeToToken[_tokenAddress];
    }

    function getToken(address _exchangeAddress) public view returns (address) {
        return tokenToExchange[_exchangeAddress];
    }
}
