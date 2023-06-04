// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// Define interfaces for Aave and Compound
interface IAave {
    function deposit(address asset, uint256 amount, address onBehalfOf, uint16 referralCode) external;
    function withdraw(address asset, uint256 amount, address to) external;
    // Add methods to get APY etc
}

interface ICompound {
    function mint(uint mintAmount) external returns (uint);
    function redeem(uint redeemTokens) external returns (uint);
    // Add methods to get APY etc
}

contract YieldAggregator {
    IERC20 public weth;
    IAave public aave;
    ICompound public compound;
    address public owner;
    uint256 public totalDeposits;

    enum Protocol { None, Aave, Compound }
    Protocol public currentProtocol = Protocol.None;

    constructor(address _weth, address _aave, address _compound) {
        weth = IERC20(_weth);
        aave = IAave(_aave);
        compound = ICompound(_compound);
        owner = msg.sender;
    }

    function deposit(uint256 _amount) public {
        // First transfer WETH from the user to this contract
        weth.transferFrom(msg.sender, address(this), _amount);
        totalDeposits += _amount;

        // Decide whether to use Aave or Compound depending on APY
        // TODO: Implement getAaveAPY() and getCompoundAPY() methods
        if (getAaveAPY() > getCompoundAPY()) {
            aave.deposit(address(weth), _amount, address(this), 0);
            currentProtocol = Protocol.Aave;
        } else {
            // For Compound, we first approve the transfer
            weth.approve(address(compound), _amount);
            compound.mint(_amount);
            currentProtocol = Protocol.Compound;
        }
    }

    function rebalance() public {
        // TODO: Implement this
    }

    function withdraw(uint256 _amount) public {
        // TODO: Implement this
    }

    // Helper functions to get APY for Aave and Compound
    function getAaveAPY() public view returns (uint256) {
        // TODO: Implement this
        return 0;
    }

    function getCompoundAPY() public view returns (uint256) {
        // TODO: Implement this
        return 0;
    }
}
