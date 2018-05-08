pragma solidity ^0.4.18;

import "./SafeMath.sol";
import "./ownable.sol";

// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md

contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract GrToken is ERC20Interface, Ownable{
	using SafeMath for uint256;

    string public constant symbol = "HGR";
    string public constant name = "Han, GyeoRe";
    uint8 public constant decimals = 18;
    uint public constant _totalSupply = 1000000000;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;


    // Constructor
    function GrToken() public {
        balances[0xe2cfd16a9C38d697b1BeaF4BD13EC3A1Fc225867] = _totalSupply;
        Transfer(address(0), 0xe2cfd16a9C38d697b1BeaF4BD13EC3A1Fc225867, _totalSupply);
    }


    // Total supply
    function totalSupply() public view returns (uint) {
        return _totalSupply.sub(balances[address(0)]);
    }

    // Get the token balance for account tokenOwner
    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }


    // Transfer the balance from token owner's account to to account
    function transfer(address to, uint tokens) public returns (bool success) {
		require(balances[msg.sender] >= tokens);
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        Transfer(msg.sender, to, tokens);
        return true;
    }

    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        Approval(msg.sender, spender, tokens);
        return true;
    }

    // Transfer tokens from the from account to the to account
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
		require(balances[from] >= tokens && allowed[from][msg.sender] >= tokens);
        balances[from] = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        Transfer(from, to, tokens);
        return true;
    }

    // Returns the amount of tokens approved by the owner that can be transferred to the spender's account
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

}
