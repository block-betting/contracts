const BettingContract = artifacts.require("BettingContract");
const { assert } = require("chai");
const { shouldThrow } = require("./helpers/utils");

contract("BettingContract", (accounts) => {

    let [ admin, alice, bob, carlos ] = accounts;
    let contract;

    context("Block Betting contract test cases:", () => {

        beforeEach(async () => {
            contract = await BettingContract.new(["team1", "team2"], { from: admin });
        });

        it("should be able to create a new betting contract", async () => {
            assert(contract.address !== "");
        });

        it("should be able to bet on a team", async () => {
            await contract.createBet(0, { from: alice, value: 1000000000000000000 });
            await contract.createBet(1, { from: bob, value: 1000000000000000000 });

            await contract.bets(alice);
            const aliceBet = await contract.bets(alice);
            const bobBet = await contract.bets(bob);

            assert(aliceBet.amount.toString() === '1000000000000000000');
            assert(bobBet.amount.toString() === '1000000000000000000'); 
            assert(aliceBet.name === "team1");
            assert(bobBet.name === "team2");        
        });

        it("should assert bets sum up to team totals", async () => {
            await contract.createBet(0, { from: alice, value: 1000000000000000000 });
            await contract.createBet(1, { from: bob, value: 1000000000000000000 });
            await contract.createBet(0, { from: carlos, value: 1000000000000000000 });
            
            const team1Total = await contract.teams(0);
            const team2Total = await contract.teams(1);

            assert(team1Total.totalBetAmount.toString() === '2000000000000000000');
            assert(team2Total.totalBetAmount.toString() === '1000000000000000000');
        });
        

    });

});