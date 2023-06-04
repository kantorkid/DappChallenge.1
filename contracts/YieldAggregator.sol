// Import necessary dependencies and interfaces

contract YieldAggregator {
    address public compoundContract; // Address of Compound V3 contract
    address public aaveContract; // Address of Aave V3 contract
    
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
