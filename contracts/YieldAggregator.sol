
////////////////// 1


// Import necessary dependencies and interfaces
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import { Pool } from "aave-v3-core/contracts/protocol/pool/Pool.sol";

contract YieldAggregator {
    address public compoundContract; // Address of Compound V3 contract
    address public aaveContract = 0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9; // Address of Aave V3 contract 
    
    // Other state variables and mappings
    
    constructor(address _compoundContract, address _aaveContract) {
        compoundContract = _compoundContract;
        aaveContract = _aaveContract;
    }
    
    // Deposit user funds into either Compound or Aave depending on higher APY
    function deposit(uint256 amount) external {
        // Calculate APY for Compound and Aave
        // Determine which platform has a higher APY
        
        // Deposit funds into the platform with a higher APY
        if (compoundHasHigherAPY) {
            // Deposit into Compound
            // Update necessary state variables
        } else {
            // Deposit into Aave
            // Update necessary state variables
        }
        
        // Emit event
    }
    
    // Withdraw funds from one platform to another if the APY is higher on the other platform
    function rebalance() external {
        // Check if rebalancing is necessary (based on APY)
        
        // If rebalancing is required, withdraw funds from the platform with a lower APY
        // and deposit into the platform with a higher APY
        
        // Update necessary state variables
        
        // Emit event
    }
    
    // Withdraw user funds from either Compound or Aave and return to their account
    function withdraw(uint256 amount) external {
        // Check from which platform the user wants to withdraw
        
        // Withdraw funds from the selected platform
        
        // Update necessary state variables
        
        // Emit event
    }
    
    // Other helper functions and event declarations
}




///////////////// 2



// Import necessary dependencies and interfaces
import { Pool } from "aave-v3-core/contracts/protocol/pool/Pool.sol";

contract YieldAggregator {
    address public WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // Address of WETH contract
    address public cWETH = 0xA17581A9E3356d9A858b789D68B4d866e593aE94; // Address of cWETH contract, Compund's placeholder token
    address public aaveContract = 0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9; // Address of Aave V3 contract 
    
    // Other state variables and mappings
    
    constructor(address _compoundContract, address _aaveContract) {
        compoundContract = _compoundContract;
        aaveContract = _aaveContract;
    }
    
    // Deposit user funds into either Compound or Aave depending on higher APY
    function deposit(uint256 amount) external {
        // Calculate APY for Compound and Aave
        uint256 compoundAPY = getCompoundAPY();
        uint256 aaveAPY = getAaveAPY();
        
        // Determine which platform has a higher APY
        bool compoundHasHigherAPY = compoundAPY > aaveAPY;
        
        // Deposit funds into the platform with a higher APY
        if (compoundHasHigherAPY) {
            // Deposit into Compound
            Compound.deposit(amount);
            
            // Update necessary state variables
        } else {
            // Deposit into Aave
            Aave.deposit(amount);
            
            // Update necessary state variables
        }
        
        // Emit event
    }
    
    // Withdraw funds from one platform to another if the APY is higher on the other platform
    function rebalance() external {
        // Check if rebalancing is necessary (based on APY)
        uint256 compoundAPY = getCompoundAPY();
        uint256 aaveAPY = getAaveAPY();
        
        bool compoundHasHigherAPY = compoundAPY > aaveAPY;
        
        if (compoundHasHigherAPY) {
            // Withdraw from Aave and deposit into Compound
            Aave.withdraw(amount);
            Compound.deposit(amount);
            
            // Update necessary state variables
        } else {
            // Withdraw from Compound and deposit into Aave
            Compound.withdraw(amount);
            Aave.deposit(amount);
            
            // Update necessary state variables
        }
        
        // Emit event
    }
    
    // Withdraw user funds from either Compound or Aave and return to their account
    function withdraw(uint256 amount) external {
        // Check from which platform the user wants to withdraw
        bool withdrawFromCompound = // Logic to determine if user wants to withdraw from Compound
        
        if (withdrawFromCompound) {
            // Withdraw from Compound
            Compound.withdraw(amount);
            
            // Update necessary state variables
        } else {
            // Withdraw from Aave
            Aave.withdraw(amount);
            
            // Update necessary state variables
        }
        
        // Emit event
    }
    
    // Other helper functions and event declarations
}







//////////////////// 3





// Import necessary dependencies and interfaces
import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import { Pool } from "aave-v3-core/contracts/protocol/pool/Pool.sol";

contract YieldAggregator {
    using SafeMath for uint256;
    
    address public WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // Address of WETH contract
    address public cWETH = 0xA17581A9E3356d9A858b789D68B4d866e593aE94; // Address of cWETH contract, Compound's placeholder token
    address public aaveContract = 0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9; // Address of Aave V3 contract 
    
    // Other state variables and mappings
    
    constructor(address _compoundContract, address _aaveContract) {
        aaveContract = _aaveContract;
        WETHContract = _wethContract;
        cWETHContract = _cWETHContract;
    }
    
    // Deposit user funds into either Compound or Aave depending on higher APY
    function deposit(uint256 amount) external {
        // Calculate APY for Compound and Aave
        uint256 compoundAPY = getCompoundAPY();
        uint256 aaveAPY = getAaveAPY();
        
        // Determine which platform has a higher APY
        bool compoundHasHigherAPY = compoundAPY > aaveAPY;
        
        // Deposit funds into the platform with a higher APY
        if (compoundHasHigherAPY) {
            // Deposit into Compound
            Compound(compoundContract).deposit(amount);
            
            // Update necessary state variables
        } else {
            // Deposit into Aave
            Aave(aaveContract).deposit(amount, WETH, address(this), 0);
            
            // Update necessary state variables
        }
        
        // Emit event
    }
    
    // Withdraw funds from one platform to another if the APY is higher on the other platform
    function rebalance() external {
        // Check if rebalancing is necessary (based on APY)
        uint256 compoundAPY = getCompoundAPY();
        uint256 aaveAPY = getAaveAPY();
        
        bool compoundHasHigherAPY = compoundAPY > aaveAPY;
        
        if (compoundHasHigherAPY) {
            // Withdraw from Aave and deposit into Compound
            Aave(aaveContract).withdraw(WETH, type(uint256).max, address(this));
            Compound(compoundContract).deposit(amount);
            
            // Update necessary state variables
        } else {
            // Withdraw from Compound and deposit into Aave
            Compound(compoundContract).withdraw(cWETH, amount);
            Aave(aaveContract).deposit(amount, WETH, address(this), 0);
            
            // Update necessary state variables
        }
        
        // Emit event
    }
    
    // Withdraw user funds from either Compound or Aave and return to their account
    function withdraw(uint256 amount) external {
        // Check from which platform the user wants to withdraw
        bool withdrawFromCompound = // Logic to determine if user wants to withdraw from Compound
        
        if (withdrawFromCompound) {
            // Withdraw from Compound
            Compound(compoundContract).withdraw(cWETH, amount);
            
            // Update necessary state variables
        } else {
            // Withdraw from Aave
            Aave(aaveContract).withdraw(WETH, amount, msg.sender);
            
            // Update necessary state variables
        }
        
        // Emit event
    }
    
    // Helper function to get the APY for Compound
    function getCompoundAPY() internal view returns (uint256) {
        // Implement the logic to fetch the Compound APY
    }
    
    // Helper function to get the APY for Aave
    function getAaveAPY() internal view returns (uint256) {
        // Implement the logic to fetch the Aave APY
    }
    
    // Other helper functions and event declarations
}





////////////////////// 4



pragma solidity ^0.5.16;

contract Aggregator {
    // Variables
    string public name = "Dapp University Challenge";
    address public owner;
    address public locationOfFunds; // Keep track of where the user balance is stored
    uint256 public amountDeposited;

    // TODO: Define the addresses for ETH, cETH, and Aave Lending Pool

    // Events
    event Deposit(address owner, uint256 amount, address depositTo);
    event Withdraw(address owner, uint256 amount, address withdrawFrom);
    event Rebalance(address owner, uint256 amount, address depositTo);

    modifier onlyOwner() {
        // TODO: Implement the onlyOwner modifier
        _;
    }

    // Constructor
    constructor() public {
        owner = msg.sender;
    }

    // Functions

    function deposit(
        uint256 _amount,
        uint256 _compAPY,
        uint256 _aaveAPY
    ) public onlyOwner {
        // TODO: Implement the deposit function

        // Emit Deposit event
        emit Deposit(msg.sender, _amount, locationOfFunds);
    }

    function withdraw() public onlyOwner {
        // TODO: Implement the withdraw function

        // Emit Withdraw event
        emit Withdraw(msg.sender, amountDeposited, locationOfFunds);

        // Reset user balance
        amountDeposited = 0;
    }

    function rebalance(uint256 _compAPY, uint256 _aaveAPY) public onlyOwner {
        // TODO: Implement the rebalance function

        // Emit Rebalance event
        emit Rebalance(msg.sender, amountDeposited, locationOfFunds);
    }

    // ---

    function balanceOfContract() public view returns (uint256) {
        // TODO: Implement the balanceOfContract function
    }

    function balanceWhere() public view returns (address) {
        return locationOfFunds;
    }
}





///////////////// 5




pragma solidity ^0.5.16;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import { Pool } from "aave-v3-core/contracts/protocol/pool/Pool.sol";

contract YieldAggregator {
    using SafeMath for uint256;

    string public name = "Dapp University Challenge";
    address public owner;
    address public locationOfFunds;
    uint256 public amountDeposited;
    address public compoundContract;
    address public aaveContract = 0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9;

    event Deposit(address indexed owner, uint256 amount, address indexed depositTo);
    event Withdraw(address indexed owner, uint256 amount, address indexed withdrawFrom);
    event Rebalance(address indexed owner, uint256 amount, address indexed depositTo);

    constructor(address _compoundContract) public {
        owner = msg.sender;
        compoundContract = _compoundContract;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    function deposit(uint256 _amount, uint256 _compAPY, uint256 _aaveAPY) public onlyOwner {
        require(_amount > 0, "Deposit amount must be greater than zero");

        // Calculate APY for Compound and Aave
        // Determine which platform has a higher APY
        bool compoundHasHigherAPY = _compAPY > _aaveAPY;

        // Deposit funds into the platform with a higher APY
        if (compoundHasHigherAPY) {
            // Deposit into Compound
            // Update necessary state variables
            // ...

            // Emit Deposit event
            emit Deposit(msg.sender, _amount, locationOfFunds);
        } else {
            // Deposit into Aave
            // Update necessary state variables
            // ...

            // Emit Deposit event
            emit Deposit(msg.sender, _amount, locationOfFunds);
        }
    }

    function withdraw() public onlyOwner {
        require(amountDeposited > 0, "No funds available for withdrawal");

        // Withdraw funds from the selected platform
        // Update necessary state variables
        // ...

        // Emit Withdraw event
        emit Withdraw(msg.sender, amountDeposited, locationOfFunds);

        // Reset user balance
        amountDeposited = 0;
    }

    function rebalance(uint256 _compAPY, uint256 _aaveAPY) public onlyOwner {
        require(amountDeposited > 0, "No funds available for rebalance");

        // Check if rebalancing is necessary (based on APY)
        bool compoundHasHigherAPY = _compAPY > _aaveAPY;
        if ((compoundHasHigherAPY && locationOfFunds != compoundContract) ||
            (!compoundHasHigherAPY && locationOfFunds != aaveContract)) {
            // If rebalancing is required, withdraw funds from the platform with a lower APY
            // and deposit into the platform with a higher APY
            // Update necessary state variables
            // ...

            // Emit Rebalance event
            emit Rebalance(msg.sender, amountDeposited, locationOfFunds);
        }
    }

    function balanceOfContract() public view returns (uint256) {
        // TODO: Implement the balanceOfContract function
    }

    function balanceWhere() public view returns (address) {
        return locationOfFunds;
    }
}
