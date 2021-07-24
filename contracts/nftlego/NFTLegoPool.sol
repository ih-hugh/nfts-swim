pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;


import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721Holder.sol";
import "./RaribleERC721.sol";
import "./NFTShardERC20.sol";
import "./Compound.sol";
import "./IChainlinkPriceFeed.sol";
import "./IRaribleExchange.sol";

contract NFTLegoPool is Compound,ERC721Holder {
    
    using SafeMath for uint256;
    
    enum PoolStatus {active, inactive, claim}

    struct PoolDetails {
        uint256 tokenId;
        uint256 totalPrice;
        uint256 totalPriceInUSD;
        uint256 totalShards;
        uint256 soldPrice;
        uint256 soldPriceInUSD;
        uint256 lendingProfit;
        PoolStatus status;
        address token;
        address payable owner;
        address exchangeTo;
        bytes data;
        string hash;
    }
    
    bool initialised;
    RaribleERC721 tokenERC721;
    NFTShardERC20 tokenERC20;
    PoolDetails public pool;
    IChainlinkPriceFeed priceFeed;

    mapping(address => uint256) public buyers;

    address[] public buyersList;
    
    modifier onlyOwner() {
        require(msg.sender == pool.owner, "Pool owner can only do this");
        _;
    }

    constructor(
        string memory poolTokenName,
        string memory poolSymbol,
        string memory _hash,
        address _token,
        uint256 tokenId,
        address payable _owner,
        uint256 _totalPrice,
        uint256 _totalShards,
        address _tokenERC721,
        address _priceFeed
        ) Compound() public 
    {
        initialised = false;
        priceFeed = IChainlinkPriceFeed(_priceFeed);
        pool.totalPrice = _totalPrice;
        pool.totalPriceInUSD = _totalPrice.mul(priceFeed.getThePrice()).div(10**8);
        pool.totalShards = _totalShards;
        pool.soldPrice = 0;
        pool.soldPriceInUSD = 0;
        pool.status = PoolStatus.active;
        pool.owner = _owner;
        pool.lendingProfit = 0;
        pool.exchangeTo = address(0);
        pool.data = "0x0";
        tokenERC20 = (new NFTShardERC20(poolTokenName, poolSymbol));
        tokenERC721 = RaribleERC721(_tokenERC721);
        // now minting dummy tokens -- later to be replced by NFTFY returned ERC20 tokens
        tokenERC20.mint(address(this), _totalShards.mul(10**18));
    }
    
    function setMatchOrderData(address _to, uint256 value, bytes calldata _data) external onlyOwner {
        require(!initialised, "Match Order data has been initialised");
        initialised = true;
        pool.exchangeTo = _to;
        pool.totalPrice = value;
        pool.data = _data[4:];
    }

    function buyShards() public payable returns(bool) {
        require(msg.value > 0 , "amount should be more than 0");
        require(pool.status == PoolStatus.active, "Pool is not active anymore");
        buyers[msg.sender] = buyers[msg.sender].add(msg.value);
        pool.soldPrice = pool.soldPrice.add(msg.value);
        pool.soldPriceInUSD =  pool.soldPriceInUSD.mul(priceFeed.getThePrice()).div(10**8);
        
        if(!buyerAlreadyInList(msg.sender)) {
            buyersList.push(msg.sender);
        }
    
        if(pool.soldPrice >= pool.totalPrice) {
            // withdraw from aave/compound
            redeemETH();
            pool.lendingProfit = address(this).balance - pool.soldPrice;
            // buy from rarible
            buy();
            // distribute shards
            transferShardsToBuyers();
            // pool status inactive
            pool.status = PoolStatus.inactive;
            // send profit from aave/compound to owner
            pool.owner.transfer(address(this).balance);
            return true;
        } else {
            // deposit to aave/compound
            supplyETH(msg.value);
            return true;
        }
        return false;
    }

   
    function buy() internal {
        // require NFt still available to buy
        // if not, set status claim and return
        (IRaribleExchange.Order memory orderLeft,
         bytes memory signatureLeft,
        IRaribleExchange.Order memory orderRight,
        bytes memory signatureRight) =  abi.decode(pool.data, (IRaribleExchange.Order, bytes, IRaribleExchange.Order,  bytes));
        IRaribleExchange(pool.exchangeTo).matchOrders{value:pool.totalPrice}(orderLeft,signatureLeft,orderRight,signatureRight);
        // emit details(orderLeft,signatureLeft,orderRight,signatureRight);
    }

    function withdrawETH() public {
        require(pool.status == PoolStatus.claim, "Pool must be inactive");
        require(buyers[msg.sender] > 0, "No shards bought");
        // add profit to it once aave/compound is there
        uint256 profit = (buyers[msg.sender]).mul(pool.lendingProfit).div(pool.soldPrice);
        msg.sender.transfer(buyers[msg.sender].add(profit));
        buyers[msg.sender] = 0;
    }

    function closePool() public onlyOwner returns(bool) {
        // some logic
        return true;
    }

    function getBuyersCount() public view returns(uint256 count) {
        return buyersList.length;
    }

    function buyerAlreadyInList(address searchUser) internal view  returns(bool){
        for(uint256 i = 0; i< buyersList.length; i++) {
            if(buyersList[i] == searchUser) {
                return true;
            }
        }
        return false;
    }

    function transferShardsToBuyers() internal {
        for(uint256 i = 0; i< buyersList.length; i++) {
            uint256 share = (buyers[buyersList[i]]).mul(pool.totalShards).div(pool.soldPrice); 
            (tokenERC20).transfer(buyersList[i], share.mul(10**18));    
        }
    }
    
}
