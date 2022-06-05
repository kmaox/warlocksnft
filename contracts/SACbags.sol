// SPDX-License-Identifier: MIT

pragma solidity >=0.6.12 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface ISac {
    function burn(address _from, uint256 _amount) external;
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFromSacBags(address to, uint256 amount) external;
}

contract Sacbags is ERC721, Ownable, ReentrancyGuard {
    ISac public Sac;

    // how much SAC is in each bag
    uint256 smallBag = 100 ether;
    uint256 mediumBag = 250 ether;
    uint256 largeBag = 500 ether;
    uint256 jumboBag = 1000 ether;

    uint256 tokenIDToMint = 1;

    mapping(uint256 => uint256) bagValue;
    
    constructor(address sacrificeAddress) ERC721("Sacrificial Bags", "SBAG") {
        Sac = ISac(sacrificeAddress);
    }

    function mintBag(uint256 bagAmount) external {
        require(
            bagAmount == smallBag || bagAmount == mediumBag || 
            bagAmount == largeBag || bagAmount == jumboBag, 
            "Can only mint bags holding 100, 250, 500 or 1000 SAC");
        Sac.transfer(address(this), bagAmount);
        _mint(msg.sender, tokenIDToMint);
        bagValue[tokenIDToMint] = bagAmount;
        tokenIDToMint++;
    }

    function redeemBag(uint256 bagId) external {
        require(msg.sender == ownerOf(bagId), "User does not own bag being burnt");
        _burn(bagId);
        uint256 owedAmount = bagValue[bagId];
        Sac.transferFromSacBags(msg.sender, owedAmount);
    }
}
