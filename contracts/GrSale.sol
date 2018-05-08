pragma solidity ^0.4.18;

import "./ownable.sol";
import "./SafeMath.sol";
import "./GrToken.sol";

contract GrSale is Ownable {
    using SafeMath for uint256;
    enum State { Standby, Ongoing, Closed, Refund }

    uint256 public constant changeRate = 10000;
    uint256 public constant openTime = 1525824000000;
    uint256 public constant closeTime = 1526036400000;
    uint public constant maxcap = 1000 ether;
    uint public constant softcap = 500 ether;

    uint public raised = 0;

    GrToken public token;

    State public state;

    mapping (address => uint) public wallets;
    // should buyers be private?
    address[] public buyers;

    // is it proper to use "getter"? just merge buyer and getter?
    event TokenPurchase(address buyer, address getter, uint value, uint amount);
    event CloseSale(uint closeTime);

    // constructor
    function GrSale(GrToken _token) public {
        require(_token != address(0));

        token = _token;
        state = State.Standby;
    }


    // buyToken stuff

    function () payable public {
        buyToken(msg.sender);
    }

    function buyToken(address _getter) public payable {
        require (state == State.Ongoing);
        require (raised < maxcap);
        uint amount = raised.add(msg.value);

        // is this comparison possible?
        if (amount > maxcap) {
            uint inserted = amount.sub(maxcap);
            uint reverted = msg.value.sub(inserted);

            // insert money to wallets & add to buyer list
            wallets[_getter] = wallets[_getter].add(_getToken(inserted));
            if(wallets[_getter] == 0) {
                buyers.push(_getter);
            }
            // add raised
            raised = raised.add(inserted);
            TokenPurchase(msg.sender, _getter, msg.value, _getToken(inserted));
            // refund money to msg.sender
            _refund(msg.sender, reverted);

        } else {
            // insert money to wallets & add to buyer list
            wallets[_getter] = wallets[_getter].add(msg.value * changeRate);
            if(wallets[_getter] == 0) {
                buyers.push(_getter);
            }

            // add raised
            raised = raised.add(msg.value);
            TokenPurchase(msg.sender, _getter, msg.value, _getToken(msg.value));
        }
    }

    function startSale() public onlyOwner {
        require(now > openTime);
        state = State.Ongoing;
    }

    function closeSale() public payable onlyOwner{
        require(now > closeTime);
        CloseSale(now);
        if(raised < softcap) {
            state = State.Refund;
            // refund stuff
            // should add check gasLimit stuff?
            // does buyers and wallets' size are always same?
            for (uint i = 0; i < buyers.length; ++i) {
                _refund(buyers[i], wallets[buyers[i]].div(changeRate));
            }
        } else {
            state = State.Closed;
        }
    }

    // util functions
    function _refund(address _return, uint amount) internal {
        require(msg.sender.balance >= amount);
        _return.transfer(amount);
    }

    function _getToken(uint amount) internal view returns (uint) {
        return amount.mul(changeRate);
    }

    // getter functions
    function getRaised() public view returns (uint) {
        return raised;
    }

}
