//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract LPToken is ERC20 {
    uint256 public totalSupplySwap;
    uint256 public rewardRatePerBlock = 100;
    uint256 public rewardPerTokenAmount;
    uint256 public lastUpdateTime;

    mapping(address => uint256) public tokensStaked;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) rewards;

    /* ========== FALLBACKS & MODIFIERS ========== */

    modifier updateRewards() {
        lastUpdateTime = block.timestamp;
        rewardPerTokenAmount = rewardPerToken();
        rewards[msg.sender] = earned(msg.sender);
        userRewardPerTokenPaid[msg.sender] = rewardPerTokenAmount;
        _;
    }

    /* ========== CONSTRUCTOR ========== */

    constructor(string memory _tokenName, string memory _tokenAbbrev)
        ERC20(_tokenName, _tokenAbbrev)
    {}

    /* ========== FUNCTIONS ========== */

    function earned(address _account) public view returns (uint256) {
        return
            ((tokensStaked[_account] *
                (rewardPerToken() - userRewardPerTokenPaid[_account])) / 1e18) +
            rewards[_account];
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalSupplySwap == 0) {
            return 0;
        }

        return
            (block.timestamp - lastUpdateTime * rewardRatePerBlock * 1e18) /
            totalSupplySwap;
    }
}
