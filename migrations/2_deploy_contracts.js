var RPS = artifacts.require("./RPS.sol");
var Base = artifacts.require("./Base.sol");

module.exports = function(deployer) {
    deployer.deploy(Base);
    deployer.deploy(RPS);
};
