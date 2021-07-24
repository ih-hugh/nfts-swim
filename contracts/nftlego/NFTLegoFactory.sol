pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./NFTLegoPool.sol";

contract NFTLegoFactory is ReentrancyGuard {

    using SafeMath for uint256;
    uint256 public ID;
    address public NFTShardERC721;
    address public ChainlinkPriceFeedAddr;

    struct Pool {
        uint256 id;
        string hash;
        address poolAddress;
        address poolOwner;
    }

    Pool[] poolList;

    constructor(address _addr, address _priceFeed) public {
        NFTShardERC721 = _addr;
        ChainlinkPriceFeedAddr = _priceFeed;
        ID = 0;
    }

    function createPool(string memory poolTokenName, string memory poolSymbol, string memory hash, address token, uint256 tokenId, uint256 totalPrice, uint256 totalShards) public nonReentrant returns (bool) {
       // require to check if unique NFT
       // check if msg.sender is real owner or not
       require(totalShards > 0 && totalPrice> 0, "value input is 0");
       NFTLegoPool _newPoolAddress = new NFTLegoPool(
           poolTokenName,
           poolSymbol,
           hash,
           token,
           tokenId,
           msg.sender,
           totalPrice,
           totalShards,
           NFTShardERC721,
           ChainlinkPriceFeedAddr);
       
       Pool memory _newPool = Pool({
           id: ID,
           hash: hash,
           poolAddress: address(_newPoolAddress),
           poolOwner: msg.sender
       });
       poolList.push(_newPool);

       ID = ID.add(1); 

       return true;
    }


    function listPools() public view returns(Pool[] memory) {
        return poolList;
    }

}