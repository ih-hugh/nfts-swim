pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

interface RaribleERC721 {
    
    struct Part {
        address payable account;
        uint96 value;
    }

    struct Mint721Data {
     uint tokenId;
     string uri;
     Part[] creators;
     Part[] royalties;
     bytes[] signatures;
    }
    
    function mintAndTransfer(Mint721Data memory data, address to) external;
}