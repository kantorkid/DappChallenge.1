// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


// Interface for WETH
interface Token {
    function approve(address, uint256) external returns (bool);
    function transfer(address, uint256) external returns (bool);
    function transferFrom(address, address, uint256) external returns (bool);
    function balanceOf(address) external view returns (uint256);
}

// Interface for Compound's cWETH
interface cToken {
    function mint(uint256) external returns (uint256);
    function redeem(uint256) external returns (uint256);
    function supplyRatePerBlock() external returns (uint256);
    function balanceOf(address) external view returns (uint256);
}

// Interface for Aave's aWETH
interface aToken {
    function balanceOf(address) external view returns (uint256);
}

// Interface for Aave's LendingPool
interface LendingPool {
    function deposit(address asset, uint256 amount, address onBehalfOf, uint16 referralCode) external;
    function withdraw(address asset, uint256 amount, address to) external;
    function getReserveData(address asset) external returns (
        uint256, uint128, uint128, uint128, uint128, uint128, uint40, address, address, address, address, uint8);
}

contract AssetManager is ReentrancyGuard {
    string public contractAlias = "AssetManager";
    address public admin;
    address public assetLocation;
    uint256 public depositValue;

    IERC20 public weth;
    cToken public cWeth;
    aToken public aWeth;
    LendingPool public pool;

    event AssetDeposited(address indexed assetHolder, uint256 amount, address indexed recipient);
    event AssetWithdrawn(address indexed assetHolder, uint256 amount, address indexed source);
    event AssetRebalanced(address indexed assetHolder, uint256 amount, address indexed recipient);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Access denied");
        _;
    }

    constructor(
        address _wethAddress,
        address _cWethAddress,
        address _aWethAddress,
        address _poolAddress
    ) {
        admin = msg.sender;
        weth = IERC20(_wethAddress);
        cWeth = cToken(_cWethAddress);
        aWeth = aToken(_aWethAddress);
        pool = LendingPool(_poolAddress);
    }

// Main Functions
    function depositAsset(uint256 _amount, uint256 _compoundRate, uint256 _aaveRate) public onlyAdmin {
        require(_amount > 0);

        // Rebalance assets if necessary
        if (depositValue > 0) {
            rebalanceAsset(_compoundRate, _aaveRate);
        }

        // Transfer the assets to this contract and update the total deposit value
        weth.transferFrom(msg.sender, address(this), _amount);
        depositValue = depositValue + _amount;

        // Decide where to deposit the assets based on the rates provided
        if (_compoundRate > _aaveRate) {
            require(depositToCompound(_amount) == 0);
            assetLocation = address(cWeth);
        } else {
            depositToAave(_amount);
            assetLocation = address(pool);
        }

        // Emit an event
        emit AssetDeposited(msg.sender, _amount, assetLocation);
    }

    function withdrawAsset() public onlyAdmin {
        require(depositValue > 0);

        // Withdraw from the correct location
        if (assetLocation == address(cWeth)) {
            require(withdrawFromCompound() == 0);
        } else {
            withdrawFromAave();
        }

        // Transfer the assets back to the admin
        uint256 balance = weth.balanceOf(address(this));
        weth.transfer(msg.sender, balance);
        emit AssetWithdrawn(msg.sender, depositValue, assetLocation);
        depositValue = 0;
    }

    function rebalanceAsset(uint256 _compoundRate, uint256 _aaveRate) public onlyAdmin {
        require(depositValue > 0);
        uint256 balance;
        if ((_compoundRate > _aaveRate) && (assetLocation != address(cWeth))) {
            withdrawFromAave();
            balance = weth.balanceOf(address(this));
            depositToCompound(balance);
            assetLocation = address(cWeth);
            emit AssetRebalanced(msg.sender, depositValue, assetLocation);
        } else if ((_aaveRate > _compoundRate) && (assetLocation != address(pool))) {
            withdrawFromCompound();
            balance = weth.balanceOf(address(this));
            depositToAave(balance);
            assetLocation = address(pool);
            emit AssetRebalanced(msg.sender, depositValue, assetLocation);
        }
    }

    // Internal Functions
    function depositToCompound(uint256 _amount) internal returns (uint256) {
        require(weth.approve(address(cWeth), _amount));
        uint256 result = cWeth.mint(_amount);
        return result;
    }

    function withdrawFromCompound() internal returns (uint256) {
        uint256 balance = cWeth.balanceOf(address(this));
        uint256 result = cWeth.redeem(balance);
        return result;
    }

    function depositToAave(uint256 _amount) internal {
        require(weth.approve(address(pool), _amount));
        pool.deposit(address(weth), _amount, address(this), 0);
    }

    function withdrawFromAave() internal {
        uint256 balance = aWeth.balanceOf(address(this));
        pool.withdraw(address(weth), balance, address(this));
    }

    // View Functions
    function contractBalance() public view returns (uint256) {
        if (assetLocation == address(cWeth)) {
            return cWeth.balanceOf(address(this));
        } else {
            return aWeth.balanceOf(address(this));
        }
    }

    function assetStorageLocation() public view returns (address) {
        return assetLocation;
    }
}

