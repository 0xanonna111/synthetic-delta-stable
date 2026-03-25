# Synthetic Delta Stablecoin

This repository demonstrates the architecture for a synthetic stablecoin (sUSD). Unlike over-collateralized stablecoins (DAI) or algorithmic ones (UST), this model relies on **Delta Neutrality**.

## Core Logic
1. **Minting**: User deposits $100 worth of ETH to mint 100 sUSD.
2. **Backing**: The ETH is held as collateral. In a production environment, an equal "short" position would be opened on a Perps DEX (like GMX or Synthetix) to negate ETH price movements.
3. **Redemption**: Users can always redeem 1 sUSD for $1.00 worth of ETH, regardless of whether ETH is at $1,000 or $10,000.

## Security
* **Oracle Integration**: Uses Chainlink for real-time ETH/USD pricing.
* **Slippage Protection**: Minimum output checks on all mint/redeem functions.
* **Emergency Shutdown**: Owner-controlled pause for volatile market conditions.
