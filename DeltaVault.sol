// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./SyntheticUSD.sol";

contract DeltaVault is ReentrancyGuard {
    SyntheticUSD public immutable sUSD;
    AggregatorV3Interface internal immutable priceFeed;

    event Minted(address indexed user, uint256 ethIn, uint256 sUSDOut);
    event Redeemed(address indexed user, uint256 sUSDIn, uint256 ethOut);

    constructor(address _priceFeed) {
        sUSD = new SyntheticUSD();
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    function getETHPrice() public view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return uint256(price) * 1e10; // Scale to 18 decimals
    }

    function mint() external payable nonReentrant {
        uint256 ethPrice = getETHPrice();
        uint256 sUSDToMint = (msg.value * ethPrice) / 1e18;
        
        require(sUSDToMint > 0, "Amount too small");
        sUSD.mint(msg.sender, sUSDToMint);
        
        emit Minted(msg.sender, msg.value, sUSDToMint);
    }

    function redeem(uint256 _sUSDAmount) external nonReentrant {
        require(sUSD.balanceOf(msg.sender) >= _sUSDAmount, "Insufficient balance");
        
        uint256 ethPrice = getETHPrice();
        uint256 ethToReturn = (_sUSDAmount * 1e18) / ethPrice;
        
        require(address(this).balance >= ethToReturn, "Vault insufficient liquidity");
        
        sUSD.burn(msg.sender, _sUSDAmount);
        (bool success, ) = payable(msg.sender).call{value: ethToReturn}("");
        require(success, "ETH transfer failed");

        emit Redeemed(msg.sender, _sUSDAmount, ethToReturn);
    }

    receive() external payable {}
}
