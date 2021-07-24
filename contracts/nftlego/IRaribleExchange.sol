pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

interface IRaribleExchange {
    
    struct AssetType {
        bytes4 assetClass;
        bytes data;
    }

    struct Asset {
        AssetType assetType;
        uint value;
    }
    
    struct Order {
        address maker;
        Asset makeAsset;
        address taker;
        Asset takeAsset;
        uint salt;
        uint start;
        uint end;
        bytes4 dataType;
        bytes data;
    }
    
    function matchOrders(
        Order memory orderLeft,
        bytes memory signatureLeft,
        Order memory orderRight,
        bytes memory signatureRight
    ) external payable;
}