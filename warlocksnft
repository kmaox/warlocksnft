import "openzeppelin-solidity/contracts/utils/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Counters.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Strings.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Context.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721Receiver.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/introspection/IERC165.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/introspection/ERC165.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/extensions/ERC721Enumerable.sol";


interface ISac {
    function balance(address _user) external view returns(uint256);
}

contract SacrificalToken is ERC20("SacrificalToken", "SAC") {
    using SafeMath for uint256;
    uint256 public TotalBurned = 0;
    address[] internal stakeholders;
    address  payable private owner;
    uint256 public totalTokensBurned = 0;

    // Token Generation for Genesis per day TODO
    uint256 constant public GENESIS_GEN = 10 ether;

    // Token Generation for Genesis per day TODO
    uint256 constant public REGULAR_GEN = 2 ether;

    // Token issued when minting a genesis TODO
    uint256 constant public GEN_GRANT = 50 ether;

    // Token issued when minting a reg TODO
    uint256 constant public REG_GRANT = 2 ether;

    mapping(address => uint256) public rewards;
	mapping(address => uint256) public lastUpdate;
	
	
    ISac public SACcontract;
   
    constructor(address initSACcontract) 
    {
        owner = payable(msg.sender);
        SACcontract = ISac(initSACcontract);
    }
   
    function WhoOwns() public view returns (address) {
        return owner;
    }
   
    modifier Owned {
         require(msg.sender == owner);
         _;
}
   
    function getContractAddress() public view returns (address) {
        return address(this);
    }

	function min(uint256 a, uint256 b) internal pure returns (uint256) {
		return a < b ? a : b;
	}    
	
	modifier contractAddressOnly
    {
         require(msg.sender == address(SACcontract));
         _;
    }

    
       // ERC20 token given when minting NFT via other contract
    function updateRewardOnMint (address _minter, uint256 _tokenId) external {
        if(_tokenId <= 1000)
        {
            _mint(_minter,GEN_GRANT);
        }
        else if(_tokenId >= 1001)
        {
            _mint(_minter,REG_GRANT);
        }
    }

    function getReward(address _to, uint256 totalPayout) external contractAddressOnly {
        _mint(_to, (totalPayout * 10 ** 18));
    }

    function burn(address _from, uint256 _amount) external {
        require(msg.sender == _from, "You do not own these tokens");
        _burn(_from, _amount);
        totalTokensBurned += _amount;
    }
}

pragma solidity ^0.8.6;

/// SPDX-License-Identifier: UNLICENSED

contract WNP721 is ERC721Enumerable, IERC721Receiver, Ownable {
   
   using Strings for uint256;
   using EnumerableSet for EnumerableSet.UintSet;
   
    SacrificalToken public sacrificalToken; // linking to erc20 token
    
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdTracker;
    
    string public baseURI;
    string public baseExtension = ".json";
    
    // 2 per tx limit for wl, 5 per tx/wallet limit per public
    uint public maxPerTxPublic = 5;
    uint public maxPerTxWL = 2; 
    uint public genesisSupply = 22;
    uint public maxSupply = 6666;
    uint256 public price = 0.07 ether; //TODO

    bool public openPubSale = false;   
    bool public openPreSale = false;

    struct Whitelist {
        address addr;
        uint minted;
    }    
    
    event mint(address to, uint total);
    event withdraw(uint total);
    
    mapping(address => uint256) public balanceOG;
    mapping(address => uint256) public maxWallet;
    mapping(address => EnumerableSet.UintSet) private _deposits;
    mapping(uint256 => uint256) public _deposit_blocks;
    mapping(address => bool) public addressStaked;
    mapping(address => Whitelist) public whitelist;

    // ID - Days staked;
    mapping(uint256 => uint256) public IDvsDaysStaked;    

   address internal communityWallet = 0xdA27937582B0ed4211e9C322778658b7B151e44d;
   
    constructor(string memory _initBaseURI) ERC721("Warlocks", "LOCK")
    {
        setBaseURI(_initBaseURI);
    }
   
    function setPrice(uint256 newPrice) external onlyOwner {
        price = newPrice;
    }
    
    // Set this to $SAC token address
    function setYieldToken(address _yield) external onlyOwner {
		sacrificalToken = SacrificalToken(_yield);
	}

    // Flipstate for private sale 
    function togglePreSales() external onlyOwner {
        openPreSale = !openPreSale;
    }

    // Flipstate for public sale 
    function togglePubSales() external onlyOwner {
        openPubSale = !openPubSale;
    }

	function totalToken() public view returns (uint256) {
            return _tokenIdTracker.current();
    }


    // Mint function for public genesis sale 
    function GenesisMint(uint256 mintTotal) public payable {
        require(openPubSale == true); // check for sale live
        require(mintTotal <= maxPerTxPublic); // max of 5 tx limit
        require(totalToken() + mintTotal <= genesisSupply, "SOLD OUT!");
        require(msg.value >= price * mintTotal && msg.value <= price * mintTotal, "Incorrect price, XXX costs 0.0XX per"); //TODO        
    
        // looping per mint the user purchases
        for(uint8 i=0;i<mintTotal;i++) {
            maxWallet[msg.sender] += 1;
            _tokenIdTracker.increment();
            _safeMint(msg.sender, totalToken());
            sacrificalToken.updateRewardOnMint(msg.sender, totalToken()); //sending SAC to minter 
            emit mint(msg.sender, totalToken());
        }
    }	
    
    // Mint function for whitelist genesis sale 
    function WhitelistMint(uint256 mintTotal) public payable {
        require(openPreSale == true, "Whitelist sale not live"); 
        require(totalToken() < genesisSupply, "SOLD OUT!");
        require(isWhitelisted(msg.sender), "Is not whitelisted");
        require(whitelist[msg.sender].minted < maxPerTxWL, "You've minted your maximum whitelist mints");
        require(msg.value >= price * mintTotal && msg.value <= price * mintTotal, "Incorrect price, XXX costs 0.0XX per"); //TODO        

        // looping per mint the user purchases
        for(uint8 i=0;i<mintTotal;i++) {
            maxWallet[msg.sender] += 1;
            _tokenIdTracker.increment();
            _safeMint(msg.sender, totalToken());
            sacrificalToken.updateRewardOnMint(msg.sender, totalToken()); // sending SAC to minter 
            whitelist[msg.sender].minted++; // updating how much has been minted from this address
            emit mint(msg.sender, totalToken());
        }
    }

    // Whitelist function
    function addWhitelist(address[] calldata _addresses) external onlyOwner {
        for (uint i=0; i<_addresses.length; i++) {
            whitelist[_addresses[i]].addr = _addresses[i]; // loop to add each array entry into whitelist
            whitelist[_addresses[i]].minted = 0; //mint of 2 token allowed per whitelist 
        }
    }
    

    function isWhitelisted(address addr) public view returns (bool isWhiteListed) {
        return whitelist[addr].addr == addr;
    }

    function withdrawContractEther(address payable recipient) external onlyOwner
    {
        emit withdraw(getBalance());
        recipient.transfer(getBalance());
    }
    function getBalance() public view returns(uint)
    {
        return address(this).balance;
    }
   
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }
   
    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }
   
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory)
    {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0 ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension)) : "";
    }
    
	function getReward(uint256 CalculatedPayout) internal
	{
		sacrificalToken.getReward(msg.sender, CalculatedPayout);
	}    
    
    // Staking Functions
    function depositStake(uint256[] calldata tokenIds) external {
        
        require(isApprovedForAll(msg.sender, address(this)), "You are not Approved!");
        
        
        for (uint256 i; i < tokenIds.length; i++) {
            safeTransferFrom(
                msg.sender,
                address(this),
                tokenIds[i],
                ''
            );
            
            _deposits[msg.sender].add(tokenIds[i]);
            addressStaked[msg.sender] = true;
            
            
            _deposit_blocks[tokenIds[i]] = block.timestamp;
            

            IDvsDaysStaked[tokenIds[i]] = block.timestamp;
        }
        
    }
    function withdrawStake(uint256[] calldata tokenIds) external {
        
        require(isApprovedForAll(msg.sender, address(this)), "You are not Approved!");
        
        for (uint256 i; i < tokenIds.length; i++) {
            require(
                _deposits[msg.sender].contains(tokenIds[i]),
                "Token not deposited"
            );
            
            sacrificalToken.getReward(msg.sender,totalRewardsToPay(tokenIds[i]));
            
            _deposits[msg.sender].remove(tokenIds[i]);
             _deposit_blocks[tokenIds[i]] = 0;
            addressStaked[msg.sender] = false;
            IDvsDaysStaked[tokenIds[i]] = block.timestamp;
            
            this.safeTransferFrom(
                address(this),
                msg.sender,
                tokenIds[i],
                ''
            );
        }
    }
    function viewRewards() external view returns (uint256)
    {
        uint256 payout = 0;
        
        for(uint256 i = 0; i < _deposits[msg.sender].length(); i++)
        {
            payout = payout + totalRewardsToPay(_deposits[msg.sender].at(i));
        }
        return payout;
    }
    
    function claimRewards() external
    {
        for(uint256 i = 0; i < _deposits[msg.sender].length(); i++)
        {
            sacrificalToken.getReward(msg.sender, totalRewardsToPay(_deposits[msg.sender].at(i)));
            IDvsDaysStaked[_deposits[msg.sender].at(i)] = block.timestamp;
        }
    }   
    
    function totalRewardsToPay(uint256 tokenId) internal view returns(uint256)
    {
        uint256 payout = 0;
        
        if(tokenId > 0 && tokenId <= genesisSupply)
        {
            payout = howManyDaysStaked(tokenId) * 20;
        }
        else if (tokenId > genesisSupply && tokenId <= maxSupply)
        {
            payout = howManyDaysStaked(tokenId) * 5;
        }
        
        return payout;
    }
    
    function howManyDaysStaked(uint256 tokenId) public view returns(uint256)
    {
        
        require(
            _deposits[msg.sender].contains(tokenId),
            'Token not deposited'
        );
        
        uint256 returndays;
        uint256 timeCalc = block.timestamp - IDvsDaysStaked[tokenId];
        returndays = timeCalc / 86400;
       
        return returndays;
    }
    
    function walletOfOwner(address _owner) external view returns (uint256[] memory) {
        uint256 tokenCount = balanceOf(_owner);

        uint256[] memory tokensId = new uint256[](tokenCount);
        for (uint256 i = 0; i < tokenCount; i++) {
            tokensId[i] = tokenOfOwnerByIndex(_owner, i);
        }

        return tokensId;
    }
    
    function returnStakedTokens() public view returns (uint256[] memory)
    {
        return _deposits[msg.sender].values();
    }
    
    function totalTokensInWallet() public view returns(uint256)
    {
        return sacrificalToken.balanceOf(msg.sender);
    }
    
   
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}
