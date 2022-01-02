//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./DexFactory.sol";

/// @title Solidity-swap
/// @author Lazar
/// @notice This is a personal project with the goal of better understanding AMM
/// @notice This contract is not tested and is currently in dev phase DO NOT USE IT!
contract Dex is ERC20 {
    /* ========== STATE VARIABLES ========== */
    IERC20 public token;
    DexFactory public factory;

    uint256 public invariant;
    uint256 public totalSupplySwap;
    uint256 public totalLiquidity;
    uint256 public rewardRatePerBlock = 100;
    uint256 public rewardPerTokenAmount;
    uint256 public lastUpdateTime;

    mapping(address => uint256) public tokenLiquidity;
    mapping(address => uint256) public tokensStaked;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) rewards;

    /* ========== FALLBACKS & MODIFIERS ========== */

    fallback() external payable {
        ethToToken(msg.value);
    }

    receive() external payable {}

    modifier updateRewards() {
        lastUpdateTime = block.timestamp;
        rewardPerTokenAmount = rewardPerToken();

        rewards[msg.sender] = earned(msg.sender);
        userRewardPerTokenPaid[msg.sender] = rewardPerTokenAmount;
        _;
    }

    /* ========== FUNCTIONS ========== */

    /// Constructor
    /// @param _tokenAddress ERC20 contract address
    /// @param _tokenAmount amount of ERC20 tokens
    /// @dev msg.value amount of ETH to be pooled
    /// @dev invariant = msg.value * _tokenAmount
    /// @dev LP token amount is a percentage (share) of total liquidity provided by user
    /// @dev LP token amount = tokenLiquidity[msg.sender] / totalLiquidity
    constructor(address _tokenAddress, uint256 _tokenAmount)
        payable
        ERC20("LPDex", "LPD")
    {
        require(totalLiquidity == 0, "DEX::initialize: already init!");
        require(
            _tokenAddress != address(0),
            "DEX::initialize:Token Address is 0!"
        );

        require(_tokenAmount != 0, "DEX::initialize: Token Amount is 0!");
        invariant = msg.value * _tokenAmount;

        totalLiquidity = msg.value;
        tokenLiquidity[msg.sender] = totalLiquidity;
        token = IERC20(_tokenAddress);
        factory = DexFactory(msg.sender);
        require(
            IERC20(_tokenAddress).transferFrom(
                msg.sender,
                address(this),
                _tokenAmount
            )
        );
    }

    function earned(address _account) public view returns (uint256) {
        return
            ((tokensStaked[_account] *
                (rewardPerToken() - userRewardPerTokenPaid[_account])) / 1e18) +
            rewards[_account];
    }

    /// Return amount of tokens to be received.
    /// @param _inputTokenAmount amount of tokens to be swapped for target token
    /// @param _inputTokenReserve current reserves of  input token (ETH or ERC20)
    /// @param _outputTokenReserve current reserves of output token (ETH or ERC20)
    /// @return amount of tokens that can be swapped for a given input amount
    function tokenPrice(
        uint256 _inputTokenAmount,
        uint256 _inputTokenReserve,
        uint256 _outputTokenReserve
    ) public view returns (uint256) {
        uint256 yToken = invariant / (_inputTokenReserve + _inputTokenAmount);
        return _outputTokenReserve - yToken;
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalSupplySwap == 0) {
            return 0;
        }

        return
            (block.timestamp - lastUpdateTime * rewardRatePerBlock * 1e18) /
            totalSupplySwap;
    }

    function ethToToken(uint256 _inputEth) private returns (uint256) {
        uint256 ethReserve = address(this).balance - _inputEth;
        uint256 tokenReserve = token.balanceOf(address(this));
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

    function deposit() external payable updateRewards {
        uint256 tokenBalance = token.balanceOf(address(this));
        uint256 ethReserve = address(this).balance - msg.value;
        uint256 tokenAmount = tokenBalance * (msg.value / ethReserve);
        tokenLiquidity[msg.sender] = tokenLiquidity[msg.sender] + msg.value;
        tokensStaked[msg.sender] = tokensStaked[msg.sender] + tokenAmount;

        totalLiquidity = totalLiquidity + msg.value;
        require(
            token.transferFrom(msg.sender, address(this), tokenAmount),
            "DEX::deposit:Token Transaction Failed!"
        );
    }

    function withdraw(uint256 _amount) external payable updateRewards {
        uint256 tokenBalance = token.balanceOf(address(this));
        uint256 ethAmount = _amount * (address(this).balance / totalLiquidity);
        uint256 tokenAmount = _amount * (tokenBalance / totalLiquidity);

        tokenLiquidity[msg.sender] = tokenLiquidity[msg.sender] - ethAmount;
        tokensStaked[msg.sender] = tokensStaked[msg.sender] - tokenAmount;

        totalLiquidity = totalLiquidity - ethAmount;

        (bool success, ) = payable(msg.sender).call{value: ethAmount}("");
        require(success, "DEX::withdraw: ETH Transaction Failed!");
        require(
            token.transfer(msg.sender, tokenAmount),
            "DEX::withdraw: Token Transaction Failed!"
        );
    }
}
