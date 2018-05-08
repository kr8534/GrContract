var SafeMath = artifacts.require("./SafeMath.sol");
var GrSale = artifacts.require("./GrSale.sol");
var GrToken = artifacts.require("./GrToken.sol");

module.exports = function(deployer) {
  deployer.deploy(SafeMath);
  deployer.link(SafeMath, GrToken);
  deployer.deploy(GrToken);
};
