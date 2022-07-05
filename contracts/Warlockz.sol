// SPDX-License-Identifier: MIT

pragma solidity >=0.6.12 <0.9.0;

import "./ERC721A.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface ISac {
    function burn(address _from, uint256 _amount) external;
    function updateReward(address _from, address _to) external;
}

contract Warlockz is ERC721A, Ownable, ReentrancyGuard {
    using Address for address;
    using SafeMath for uint256;
    // Sale Information

    uint256 public price = 0.04 ether; // TODO
    uint256 public MAX_PER_TX = 2; // TODO
    uint256 public MAX_ADMIN_MINT = 40;
    uint256 public MAX_GENESIS_SUPPLY = 4000;
    uint256 public MAX_SUPPLY = 6000;
    uint256 public babyCount;
    bool public saleLive = false;
    bool public adminMinted = false;
    string public baseURI = "ipfs"; // TODO

    ISac public Sac;
    uint256 public SPAWN_PRICE = 700 ether; 

    mapping(address => uint256) public balanceGenesis;

    modifier warlockOwner(uint256 warlockId) {
        require(
            ownerOf(warlockId) == msg.sender,
            "Cannot interact with a Warlock you do not own"
        );
        _;
    }

    constructor() ERC721A("Warlockz", "LOCKZ") {}

    // Main Sale Minting
    function mintGensisWarlockz(uint256 _amount) external payable {
        uint256 supply = totalSupply();
        require(msg.sender == tx.origin, "No contract exploits allowed");
        require(saleLive, "Sale Not Active");
        require(
            supply + _amount <= MAX_GENESIS_SUPPLY,
            "No more Genesis's to be minted"
        );
        require(_amount > 0 && _amount <= MAX_PER_TX, "Max per TX is 2");
        require(msg.value == price * _amount, "Incorrect Amount Of ETH Sent");

        _safeMint(msg.sender, _amount);
    }

    function adminMint() external onlyOwner {
        require(adminMinted == false, "Admin already minted their supply");
        _safeMint(msg.sender, MAX_ADMIN_MINT);
        adminMinted = true;
    }

    function spawnCompanion(uint256 parent) external warlockOwner(parent) {
        uint256 supply = totalSupply();
        require(supply <= MAX_SUPPLY, "All babies have been minted");
        require(
            parent <= MAX_GENESIS_SUPPLY,
            "You need to spawn a baby from a genesis Warlock"
        );
        Sac.burn(msg.sender, SPAWN_PRICE);
        babyCount++;
        _safeMint(msg.sender, 1);
    }

    function setSacAddress(address SacAddress) external onlyOwner {
        Sac = ISac(SacAddress);
    }

    // Flipstate for sale
    function setSaleActive(bool val) public onlyOwner {
        saleLive = val;
    }

    // Withdraw all funds
    function withdrawAll() external onlyOwner {
        require(payable(msg.sender).send(address(this).balance));
    }

    // Returns baseURI
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    // Update baseURI
    function setBaseURI(string calldata _uri) external onlyOwner {
        baseURI = _uri;
    }

    function _afterTokenTransfers(
        address from,
        address to,
        uint256 startTokenId,
        uint256 quantity
    ) internal virtual override {
        // only runs if genesis nfts are being transfered
        if (startTokenId < MAX_GENESIS_SUPPLY) {
            // this is the code that runs if a genesis nft is minted
            if (from == address(0)) {
                balanceGenesis[to] += quantity;
                return;
            }
            // if a genesis is burned
            if (to == address(0)) {
                balanceGenesis[from] -= quantity;
                return;
            }
            else {
                balanceGenesis[from] -= quantity;
                balanceGenesis[to] += quantity;
            }
        }
    }
}



