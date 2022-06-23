// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./WarlockzVRF.sol";

interface iRedeem {
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
}

contract tickets is WarlockzVRF {
    uint64 private subscriptionId = 6947;
    uint256 requiredTickets = 1;
    uint64 bTicket;
    uint64 mTicket;
    uint64 sTicket;
    iRedeem public tRedeem;

    constructor() WarlockzVRF(subscriptionId) {}

    function bRedeem() public enoughTickets {
        addressToTicket[msg.sender] -= bTicket;
        //tRedeem.transferFrom("contract that holds the nft that the user is redeeming", msg.sender, "token id of nft");
    }

    function mRedeem() public enoughTickets {
        addressToTicket[msg.sender] -= mTicket;
        //tRedeem.transferFrom("contract that holds the nft that the user is redeeming", msg.sender, "token id of nft");
    }

    function sRedeem() public enoughTickets {
        addressToTicket[msg.sender] -= sTicket;
        //tRedeem.transferFrom("contract that holds the nft that the user is redeeming", msg.sender, "token id of nft");
    }

    modifier enoughTickets() {
        require(addressToTicket[msg.sender] >= requiredTickets);
        _;
    }
}
