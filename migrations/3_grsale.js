var SafeMath = artifacts.require("./SafeMath.sol");
var GrSale = artifacts.require("./GrSale.sol");
var GrToken = artifacts.require("./GrToken.sol");

module.exports = async function(deployer) {

  const erc20 = await GrToken.deployed();

  await deployer.link(SafeMath, GrSale);
  await deployer.deploy(GrSale, erc20.address);
};
