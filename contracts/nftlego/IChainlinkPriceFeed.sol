pragma solidity ^0.7.0;

interface IChainlinkPriceFeed {
     function getThePrice() external view returns (uint);
}