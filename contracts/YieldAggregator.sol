// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// Define interface for Aave
interface IAave {
    function deposit(address asset, uint256 amount, address onBehalfOf, uint16 referralCode) external;
    function withdraw(address asset, uint256 amount, address to) external;
    function getReserveData(address asset) external view returns (
        uint256 ltv,
        uint256 liquidationThreshold,
        uint256 liquidationBonus,
        uint256 reserveFactor,
        uint256 usageAsCollateralEnabled,
        uint256 borrowingEnabled,
        uint256 stableBorrowRateEnabled,
        uint256 isActive,
        uint256 isFrozen,
        uint256 WETH,
        uint256 aTokenAddress,
        uint256 stableDebtTokenAddress,
        uint256 variableDebtTokenAddress,
        uint256 interestRateStrategyAddress,
        uint256 id
    );
}

// Define interface for Compound
interface ICompound {
    function mint(uint mintAmount) external returns (uint);
    function redeem(uint redeemTokens) external returns (uint);
    function exchangeRateCurrent() external returns (uint);
    function supplyRatePerBlock() external returns (uint);
    function balanceOf(address owner) external view returns (uint);
}

contract YieldAggregator {
    
    //Instances
    IERC20 public weth;    // Instance of WETH contract
    IAave public aave;    // Instance of Aave contract
    ICompound public compound;    // Instance of Compound contract


    // Mapping
    mapping(address => uint256) public deposits;    // Mapping to track user deposits


    constructor(
        address _wethAddress, 
        address _aaveAddress, 
        address _compoundAddress
    ) {
        weth = IERC20(_wethAddress);
        aave = IAave(_aaveAddress);
        compound = ICompound(_compoundAddress);
    }

    function deposit(uint256 _amount) external {
        // Transfer WETH from the user to this contract
        weth.transferFrom(msg.sender, address(this), _amount);

        // Update user deposit amount
        deposits[msg.sender] += _amount;

        // Decide where to deposit based on current rates
        if (getAaveLiquidityRate() > getCompoundSupplyRate()) {
            // Approve the Aave LendingPool contract to spend WETH on behalf of this contract
            weth.approve(address(aave), _amount);

            // Deposit WETH into Aave
            aave.deposit(address(weth), _amount, address(this), 0);
        } else {
            // Approve the Compound contract to spend WETH on behalf of this contract
            weth.approve(address(compound), _amount);

            // Deposit WETH into Compound
            compound.mint(_amount);
        }
    }

    // Implement other functions...

    function getAaveLiquidityRate() public view returns (uint256) {
        (,,,,,,,bool isActive,,,,,,,) = aave.getReserveData(address(weth));
        require(isActive, "Reserve is not active on Aave");
        return aave.getReserveData(address(weth)).liquidityRate;
    }

    function getCompoundSupplyRate() public view returns (uint256) {
        return compound.supplyRatePerBlock();
    }
}
