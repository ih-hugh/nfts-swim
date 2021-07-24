pragma solidity ^0.7.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract NFTShardERC20 is ERC20 {

    constructor(string memory name, string memory symbol) public ERC20(name,symbol) {

    }

    function mint(address owner, uint256 amount) public {
        _mint(owner, amount);
    }
}