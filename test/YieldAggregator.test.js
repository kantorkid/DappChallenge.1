// Import the necessary libraries and modules
const { ethers } = require("hardhat");
const { expect } = require("chai");

// Describe the test suite
describe('AssetManager', function() {
  // Declare the variables we will use throughout the test
  let AssetManager, WETH, CWETH, AWETH, LendingPool, owner, nonOwner, manager, weth, cWeth, aWeth, pool;
  // Set the amount of tokens to be minted and approved
  const amount = ethers.utils.parseEther("1");

  // Run setup before each test
  beforeEach(async function() {
    // Get list of signers
    [owner, nonOwner, ...accounts] = await ethers.getSigners();

    // Get the contract factories for each contract
    AssetManager = await ethers.getContractFactory('AssetManager');
    WETH = await ethers.getContractFactory('WETH');
    CWETH = await ethers.getContractFactory('CWETH');
    AWETH = await ethers.getContractFactory('AWETH');
    LendingPool = await ethers.getContractFactory('LendingPool');

    // Deploy each contract
    weth = await WETH.deploy();
    await weth.deployed();
    
    cWeth = await CWETH.deploy();
    await cWeth.deployed();
    
    aWeth = await AWETH.deploy();
    await aWeth.deployed();
    
    pool = await LendingPool.deploy();
    await pool.deployed();

    // Deploy the manager contract with the addresses of the other contracts as parameters
    manager = await AssetManager.deploy(weth.address, cWeth.address, aWeth.address, pool.address);
    await manager.deployed();

    // Mint tokens and approve the manager to spend them
    await weth.mint(owner.address, amount);
    await weth.connect(owner).approve(manager.address, amount);
  });

  // Test that assets can be deposited into Compound
  it('should deposit assets to Compound', async function() {
    const compoundRate = 3;
    const aaveRate = 2;

    // Call the depositAsset function
    await manager.connect(owner).depositAsset(amount, compoundRate, aaveRate);

    // Check that the contract balance is correct
    const contractBalance = await manager.contractBalance();
    expect(contractBalance).to.equal(amount);
  });

  // Test that assets can be withdrawn from Compound
  it('should withdraw assets from Compound', async function() {
    const compoundRate = 3;
    const aaveRate = 2;

    // Call the depositAsset and withdrawAsset functions
    await manager.connect(owner).depositAsset(amount, compoundRate, aaveRate);
    await manager.connect(owner).withdrawAsset();

    // Check that the contract balance is 0
    const contractBalance = await manager.contractBalance();
    expect(contractBalance).to.equal(0);
  });

  // Test that assets can be rebalanced from Compound to Aave
  it('should rebalance from Compound to Aave', async function() {
    const compoundRate1 = 3;
    const aaveRate1 = 2;
    const compoundRate2 = 2;
    const aaveRate2 = 3;

    // Call the depositAsset and rebalanceAsset functions
    await manager.connect(owner).depositAsset(amount, compoundRate1, aaveRate1);
    await manager.connect(owner).rebalanceAsset(compoundRate2, aaveRate2);

    // Check that the assets are stored in the correct location
    const location = await manager.assetStorageLocation();
    expect(location).to.equal(pool.address);
  });

  // Test that assets can be rebalanced from Aave to Compound
  it('should rebalance from Aave to Compound', async function() {
    const compoundRate1 = 2;
    const aaveRate1 = 3;
    const compoundRate2 = 3;
    const aaveRate2 = 2;

    // Call the depositAsset and rebalanceAsset functions
    await manager.connect(owner).depositAsset(amount, compoundRate1, aaveRate1);
    await manager.connect(owner).rebalanceAsset(compoundRate2, aaveRate2);

    // Check that the assets are stored in the correct location
    const location = await manager.assetStorageLocation();
    expect(location).to.equal(cWeth.address);
  });

  // Test that non-admins cannot deposit assets
  it('should fail to deposit if not called by admin', async function() {
    const compoundRate = 3;
    const aaveRate = 2;

    // Call the depositAsset function from a non-admin account and check for a revert
    await expect(manager.connect(nonOwner).depositAsset(amount, compoundRate, aaveRate)).to.be.revertedWith("Access denied");
  });

  // Test that non-admins cannot withdraw assets
  it('should fail to withdraw if not called by admin', async function() {
    // Call the withdrawAsset function from a non-admin account and check for a revert
    await expect(manager.connect(nonOwner).withdrawAsset()).to.be.revertedWith("Access denied");
  });

  // Test that non-admins cannot rebalance assets
  it('should fail to rebalance if not called by admin', async function() {
    const compoundRate = 3;
    const aaveRate = 2;

    // Call the rebalanceAsset function from a non-admin account and check for a revert
    await expect(manager.connect(nonOwner).rebalanceAsset(compoundRate, aaveRate)).to.be.revertedWith("Access denied");
  });

  // Test that deposits of 0 are not allowed
  it('should fail to deposit if amount is 0', async function() {
    const compoundRate = 3;
    const aaveRate = 2;

    // Call the depositAsset function with an amount of 0 and check for a revert
    await expect(manager.connect(owner).depositAsset(0, compoundRate, aaveRate)).to.be.revertedWith("Amount must be greater than 0");
  });

  // Test that withdrawals cannot be made if there are no assets to withdraw
  it('should fail to withdraw if there is nothing to withdraw', async function() {
    // Call the withdrawAsset function when there are no assets and check for a revert
    await expect(manager.connect(owner).withdrawAsset()).to.be.revertedWith("No assets to withdraw");
  });

  // Test that assets cannot be rebalanced if there are no assets to rebalance
  it('should fail to rebalance if there are no assets', async function() {
    const compoundRate = 3;
    const aaveRate = 2;

    // Call the rebalanceAsset function when there are no assets and check for a revert
    await expect(manager.connect(owner).rebalanceAsset(compoundRate, aaveRate)).to.be.revertedWith("No assets to rebalance");
  });
});
