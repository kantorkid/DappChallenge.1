const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Aggregator", function () {
  let Aggregator, aggregator, owner, addr1, addr2;

  beforeEach(async function () {
    Aggregator = await ethers.getContractFactory("Aggregator");
    [owner, addr1, addr2, _] = await ethers.getSigners();
    aggregator = await Aggregator.deploy();
    await aggregator.deployed();
  });

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      expect(await aggregator.owner()).to.equal(owner.address);
    });
  });

  describe("Transactions", function () {
    it("Should deposit WETH to the right platform", async function () {
      // Assuming that 100 WETH tokens are approved to be spent by the contract
      await aggregator.connect(owner).deposit(100, 2, 1);
      expect(await aggregator.locationOfFunds()).to.equal(cWeth.address);
    });

    it("Should rebalance WETH from Compound to Aave", async function () {
      await aggregator.connect(owner).deposit(100, 1, 2);
      await aggregator.connect(owner).rebalance(1, 2);
      expect(await aggregator.locationOfFunds()).to.equal(
        aaveLendingPool.address
      );
    });

    it("Should allow withdrawal of deposited WETH", async function () {
      await aggregator.connect(owner).deposit(100, 2, 1);
      await aggregator.connect(owner).withdraw();
      expect(await aggregator.amountDeposited()).to.equal(0);
    });
  });
});
