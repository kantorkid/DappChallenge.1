pragma solidity ^0.5.16;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

// Interface for ERC20 WETH contract
interface WETH {
    function deposit() external payable;
    function withdraw(uint256) external;
    function approve(address, uint256) external returns (bool);
    function transfer(address, uint256) external returns (bool);
    function transferFrom(address, address, uint256) external returns (bool);
    function balanceOf(address) external view returns (uint256);
}

// Interface for Compound's cETH contract
interface cETH {
    function mint() external payable;
    function redeem(uint256) external returns (uint256);
    function supplyRatePerBlock() external view returns (uint256);
    function balanceOf(address) external view returns (uint256);
}

// Interface for Aave's lending pool contract
interface AaveLendingPool {
    function deposit(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external;
    function withdraw(
        address asset,
        uint256 amount,
        address to
    ) external;
    function getReserveData(address asset) external returns (
        uint256 configuration,
        uint128 liquidityIndex,
        uint128 variableBorrowIndex,
        uint128 currentLiquidityRate,
        uint128 currentVariableBorrowRate,
        uint128 currentStableBorrowRate,
        uint40 lastUpdateTimestamp,
        address aTokenAddress,
        address stableDebtTokenAddress,
        address variableDebtTokenAddress,
        address interestRateStrategyAddress,
        uint8 id
    );
}

contract Aggregator {
    using SafeMath for uint256;

    // Variables
    string public name = "Yield Aggregator";
    address public owner;
    address public locationOfFunds; // Keep track of where the user balance is stored
    uint256 public amountDeposited;

    WETH weth;
    cETH cEth;
    AaveLendingPool aaveLendingPool;

    // Events
    event Deposit(address owner, uint256 amount, address depositTo);
    event Withdraw(address owner, uint256 amount, address withdrawFrom);
    event Rebalance(address owner, uint256 amount, address depositTo);

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    // Constructor
    constructor(address wethAddress, address cEthAddress, address aaveLendingPoolAddress) public {
        owner = msg.sender;
        weth = WETH(wethAddress);
        cEth = cETH(cEthAddress);
        aaveLendingPool = AaveLendingPool(aaveLendingPoolAddress);
    }

    // Functions

    function deposit(uint256 _amount, uint256 _compAPY, uint256 _aaveAPY) public onlyOwner {
        require(_amount > 0);

        // Rebalance in the case of a protocol with the higher rate after their initial deposit,
        // is no longer the higher interest rate during this deposit...
        if (amountDeposited > 0) {
            rebalance(_compAPY, _aaveAPY);
        }

        // Deposit WETH
        weth.transferFrom(msg.sender, address(this), _amount);
        weth.deposit.value(_amount)();

        amountDeposited = amountDeposited.add(_amount);

        // Compare interest rates
        if (_compAPY > _aaveAPY) {
            // Deposit into Compound
            cEth.mint.value(_amount)();
            locationOfFunds = address(cEth);
        } else {
            // Deposit into Aave
            aaveLendingPool.deposit(address(weth), _amount, address(this), 0);
            locationOfFunds = address(aaveLendingPool);
        }

        emit Deposit(owner, _amount, locationOfFunds);
    }

    function withdraw(uint256 _amount) public onlyOwner {
        require(_amount > 0 && _amount <= amountDeposited);

        if (locationOfFunds == address(cEth)) {
            // Withdraw from Compound
            uint256 cEthBalance = cEth.balanceOf(address(this));
            uint256 redeemAmount = cEthBalance.mul(_amount).div(amountDeposited);
            uint256 withdrawnAmount = cEth.redeem(redeemAmount);
            require(withdrawnAmount > 0, "Compound withdraw failed");
            require(address(this).balance >= withdrawnAmount, "Insufficient ETH balance");
            msg.sender.transfer(withdrawnAmount);
        } else {
            // Withdraw from Aave
            aaveLendingPool.withdraw(address(weth), _amount, msg.sender);
        }

        amountDeposited = amountDeposited.sub(_amount);

        emit Withdraw(owner, _amount, locationOfFunds);
    }

    function rebalance(uint256 _compAPY, uint256 _aaveAPY) internal {
        if (locationOfFunds == address(cEth)) {
            uint256 cEthBalance = cEth.balanceOf(address(this));
            uint256 redeemAmount = cEthBalance.mul(amountDeposited).div(cEthBalance.add(_amount));
            uint256 redeemedAmount = cEth.redeem(redeemAmount);
            require(redeemedAmount > 0, "Compound redeem failed");
            require(address(this).balance >= redeemedAmount, "Insufficient ETH balance");
            weth.withdraw(redeemedAmount);
        } else {
            aaveLendingPool.withdraw(address(weth), amountDeposited, address(this));
        }
    }

    // Fallback function
    function() external payable {}
}
