pragma solidity ^0.7.0;

interface CEther {
    function mint() external payable;
    function redeem(uint redeemTokens) external returns (uint);
    function balanceOf(address owner) external view returns (uint256);
}


contract Compound {
    address cethadr = 0xd6801a1DfFCd0a410336Ef88DeF4320D6DF1883e;
    CEther ceth;

    constructor() public {
        ceth = CEther(cethadr);
    }

    function supplyETH(uint256 amount) internal {
        ceth.mint{value:amount}();
    }

    function redeemETH() internal {
        ceth.redeem(ceth.balanceOf(address(this)));
    }
    
    receive() external payable {
    
    }
}