const AssetManager = artifacts.require('AssetManager');
const WETH = artifacts.require('WETH');
const CWETH = artifacts.require('CWETH');
const AWETH = artifacts.require('AWETH');
const LendingPool = artifacts.require('LendingPool');

const { expect } = require('chai');

contract('AssetManager', function(accounts) {
  let manager;
  let weth;
  let cWeth;
  let aWeth;
  let pool;

  const owner = accounts[0];
  const amount = web3.utils.toWei('1', 'ether');

  beforeEach(async function() {
    weth = await WETH.deployed();
    cWeth = await CWETH.deployed();
    aWeth = await AWETH.deployed();
    pool = await LendingPool.deployed();

    manager = await AssetManager.new(weth.address, cWeth.address, aWeth.address, pool.address, { from: owner });

    await weth.mint(amount, { from: owner });
    await weth.approve(manager.address, amount, { from: owner });
  });

  it('should deposit assets to Compound', async function() {
    const compoundRate = 3;
    const aaveRate = 2;

    await manager.depositAsset(amount, compoundRate, aaveRate, { from: owner });

    const contractBalance = await manager.contractBalance();
    expect(contractBalance.toString()).to.equal(amount);
  });

  it('should withdraw assets from Compound', async function() {
    const compoundRate = 3;
    const aaveRate = 2;

    await manager.depositAsset(amount, compoundRate, aaveRate, { from: owner });
    await manager.withdrawAsset({ from: owner });

    const contractBalance = await manager.contractBalance();
    expect(contractBalance.toString()).to.equal('0');
  });

it('should rebalance from Compound to Aave', async function() {
  const compoundRate1 = 3;
  const aaveRate1 = 2;
  const compoundRate2 = 2;
  const aaveRate2 = 3;

  // First, deposit into Compound
  await manager.depositAsset(amount, compoundRate1, aaveRate1, { from: owner });

  // Now, let's say Aave rates are better, so the assets should be rebalanced to Aave
  await manager.rebalanceAsset(compoundRate2, aaveRate2, { from: owner });

  // Verify asset location
  const location = await manager.assetStorageLocation();
  expect(location).to.equal(pool.address);
});

it('should rebalance from Aave to Compound', async function() {
  const compoundRate1 = 2;
  const aaveRate1 = 3;
  const compoundRate2 = 3;
  const aaveRate2 = 2;

  // First, deposit into Aave
  await manager.depositAsset(amount, compoundRate1, aaveRate1, { from: owner });

  // Now, let's say Compound rates are better, so the assets should be rebalanced to Compound
  await manager.rebalanceAsset(compoundRate2, aaveRate2, { from: owner });

  // Verify asset location
  const location = await manager.assetStorageLocation();
  expect(location).to.equal(cWeth.address);
});

it('should fail to deposit if not called by admin', async function() {
  const compoundRate = 3;
  const aaveRate = 2;

  // Attempt to deposit from an account that's not the admin
  await expectRevert(manager.depositAsset(amount, compoundRate, aaveRate, { from: nonOwner }), "Access denied");
});

it('should fail to withdraw if not called by admin', async function() {
  // Attempt to withdraw from an account that's not the admin
  await expectRevert(manager.withdrawAsset({ from: nonOwner }), "Access denied");
});

it('should fail to rebalance if not called by admin', async function() {
  const compoundRate = 3;
  const aaveRate = 2;

  // Attempt to rebalance from an account that's not the admin
  await expectRevert(manager.rebalanceAsset(compoundRate, aaveRate, { from: nonOwner }), "Access denied");
});

it('should fail to deposit if amount is 0', async function() {
  const compoundRate = 3;
  const aaveRate = 2;

  // Attempt to deposit 0
  await expectRevert(manager.depositAsset(0, compoundRate, aaveRate, { from: owner }), "Amount must be greater than 0");
});

it('should fail to withdraw if there is nothing to withdraw', async function() {
  // Attempt to withdraw when there are no assets
  await expectRevert(manager.withdrawAsset({ from: owner }), "No assets to withdraw");
});

it('should fail to rebalance if there are no assets', async function() {
  const compoundRate = 3;
  const aaveRate = 2;

  // Attempt to rebalance when there are no assets
  await expectRevert(manager.rebalanceAsset(compoundRate, aaveRate, { from: owner }), "No assets to rebalance");
});


});
