const Aggregator = artifacts.require("./Aggregator")
const wethABI = require("../mint-weth/weth-abi.json")
const cWETH_ABI = require("../src/helpers/cWeth-abi.json")
const AAVE_ABI = require("../src/helpers/aaveLendingPool-abi.json")
const getAPY = require("../src/helpers/calculateAPY")

require('chai')
    .use(require('chai-as-promised'))
    .should()

const WETH = '0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2' // ERC20 WETH Address
const cWETH = '0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5' // Compound's cWETH Address
const aaveLendingPool = '0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9' // Aave's Lending Pool Contract

const EVM_REVERT = 'VM Exception while processing transaction: revert'

contract('Aggregator', ([deployer, user2]) => {

    const wethContract = new web3.eth.Contract(wethABI, WETH)
    const cWETH_contract = new web3.eth.Contract(cWETH_ABI, cWETH)
    const aaveLendingPool_contract = new web3.eth.Contract(AAVE_ABI, aaveLendingPool)

    let aggregator

    beforeEach(async () => {
        // Fetch contract
        aggregator = await Aggregator.new()
    })

    describe('deployment', () => {

        it('passes the smoke test', async () => {
            const result = await aggregator.name()
            result.should.equal("Yield Aggregator")
        })
    })

    describe('exchange rates', async () => {

        it('fetches compound exchange rate', async () => {
            let result = await getAPY.getCompoundAPY(cWETH_contract)
            console.log(result.toString())
            result.should.not.equal(0)
        })

        it('fetches aave exchange rate', async () => {
            let result = await getAPY.getAaveAPY(aaveLendingPool_contract)
            console.log(result.toString())
            result.should.not.equal(0)
        })
    })

    describe('deposits', async () => {

        let amount = 10
        let amountInWei = web3.utils.toWei(amount.toString(), 'ether')
        let compAPY, aaveAPY
        let result

        describe('success', async () => {
            beforeEach(async () => {

                // Fetch Compound APY
                compAPY = await getAPY.getCompoundAPY(cDAI_contract)

                // Fetch Aave APY
                aaveAPY = await getAPY.getAaveAPY(aaveLendingPool_contract)

                // Approve
                await daiContract.methods.approve(aggregator.address, amountInWei).send({ from: deployer })

                // Initiate deposit
                result = await aggregator.deposit(amountInWei, compAPY, aaveAPY, { from: deployer })
            })

            it('tracks the dai amount', async () => {
                // Check dai balance in smart contract
                let balance
                balance = await aggregator.amountDeposited.call()
                balance.toString().should.equal(amountInWei.toString())
            })

            it('tracks where dai is stored', async () => {
                result = await aggregator.balanceWhere.call()
                console.log(result)
            })

            it('emits deposit event', async () => {
                const log = result.logs[0]
                log.event.should.equal('Deposit')
            })
        })

        describe('failure', async () => {

            it('fails when transfer is not approved', async () => {
                await aggregator.deposit(amountInWei, compAPY, aaveAPY, { from: deployer }).should.be.rejectedWith(EVM_REVERT)
            })

            it('fails when amount is 0', async () => {
                await aggregator.deposit(0, compAPY, aaveAPY, { from: deployer }).should.be.rejectedWith(EVM_REVERT)
            })

        })

    })

    describe('withdraws', async () => {

        let amount = 10
        let amountInWei = web3.utils.toWei(amount.toString(), 'ether')
        let compAPY, aaveAPY
        let result

        describe('success', async () => {
            beforeEach(async () => {
                // Fetch Compound APY
                compAPY = await getAPY.getCompoundAPY(cDAI_contract)

                // Fetch Aave APY
                aaveAPY = await getAPY.getAaveAPY(aaveLendingPool_contract)

                // Approve
                await daiContract.methods.approve(aggregator.address, amountInWei).send({ from: deployer })

                // Initiate deposit
                await aggregator.deposit(amountInWei, compAPY, aaveAPY, { from: deployer })
            })

            it('emits withdraw event', async () => {
                result = await aggregator.withdraw({ from: deployer })
                const log = result.logs[0]
                log.event.should.equal('Withdraw')
            })

            it('updates the user contract balance', async () => {
                await aggregator.withdraw({ from: deployer })
                result = await aggregator.amountDeposited.call()
                result.toString().should.equal("0")
            })

        })

        describe('failure', async () => {

            it('fails if user has no balance', async () => {
                await aggregator.withdraw({ from: deployer }).should.be.rejectedWith(EVM_REVERT)
            })

            it('fails if a different user attempts to withdraw', async () => {
                await aggregator.withdraw({ from: user2 }).should.be.rejectedWith(EVM_REVERT)
            })

        })

    })

    describe('rebalance', async () => {

        let compAPY, aaveAPY

        describe('failure', async () => {
            beforeEach(async () => {
                // Fetch Compound APY
                compAPY = await getAPY.getCompoundAPY(cDAI_contract)

                // Fetch Aave APY
                aaveAPY = await getAPY.getAaveAPY(aaveLendingPool_contract)
            })

            it('fails if user has no balance', async () => {
                await aggregator.rebalance(compAPY, aaveAPY, { from: deployer }).should.be.rejectedWith(EVM_REVERT)
            })

        })

    })

})