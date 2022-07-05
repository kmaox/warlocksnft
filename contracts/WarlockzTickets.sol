// SPDX-License-Identifier: MIT
pragma solidity >=0.6.12 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract WarlockzTickets is ERC721, Ownable, ReentrancyGuard {

    event BronzeTicketMinted (uint256 tokenID);
    event SliverTicketMinted (uint256 tokenID);
    event GoldTicketMinted (uint256 tokenID);

    uint256 tokenIDToMint = 1;
    mapping(uint256 => uint256) ticketRarity;

    constructor() ERC721("Warlockz Tickets", "WTICK"){}

    function mintTicket(uint256 _amount) external {
        if (_amount == 1) {
            ticketRarity[tokenIDToMint] = _amount; 
            _mint(msg.sender, tokenIDToMint);
            tokenIDToMint++;
            emit BronzeTicketMinted(tokenIDToMint);
        }
        if (_amount == 2) {
            ticketRarity[tokenIDToMint] = _amount; 
            _mint(msg.sender, tokenIDToMint);
            tokenIDToMint++;
            emit SliverTicketMinted(tokenIDToMint);
        }
        if (_amount == 3) {
            ticketRarity[tokenIDToMint] = _amount; 
            _mint(msg.sender, tokenIDToMint);
            tokenIDToMint++;
            emit GoldTicketMinted(tokenIDToMint);
        }
    }
}



