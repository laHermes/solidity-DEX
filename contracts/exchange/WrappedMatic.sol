//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract WrappedMatic is ERC20 {
    event Mint(address indexed _account, uint256 _amount);
    event Burn(address indexed _account, uint256 _amount);

    constructor() ERC20("WrappedMatic", "WM") {}

    function mint() external payable {
        _mint(msg.sender, msg.value);
        emit Mint(msg.sender, msg.value);
    }

    function burn(uint256 _amount) external {
        transfer(msg.sender, _amount);
        _burn(msg.sender, _amount);
        emit Burn(msg.sender, _amount);
    }
}
