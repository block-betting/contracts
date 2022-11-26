const BettingContract = artifacts.require("BettingContract");
const BetFactory = artifacts.require("BetFactory");

module.exports = function(deployer) {
    deployer.deploy(BetFactory);
};  