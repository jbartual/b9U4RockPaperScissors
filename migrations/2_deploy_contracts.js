var RPS = artifacts.require("RPS");
var Base = artifacts.require("Base");

module.exports = function(deployer) {
    deployer.deploy(Base);
    deployer.deploy(RPS);
};
