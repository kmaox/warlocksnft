// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SAC.sol";
import "hardhat/console.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

//import "openzeppelin-contracts/token/ERC20/ERC20.sol";

interface IBurn {
    function burn(address user, uint256 amount) external;
}

contract WarlockzVRF is VRFConsumerBaseV2 {
    VRFCoordinatorV2Interface COORDINATOR;
    IBurn public Sac;
    // Your subscription ID.
    uint64 s_subscriptionId;
    address vrfCoordinator = 0x6168499c0cFfCaCD319c818142124B7A15E857ab;
    bytes32 keyHash =
        0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc;
    uint32 callbackGasLimit = 100000;
    uint16 requestConfirmations = 3;
    uint32 numWords = 1;
    uint256 public newRandNum;
    uint256[] public s_randomWords;
    uint256 public s_requestId;
    address s_owner;
    string public prize;
    uint256 private _totalSupply;
    event Transfer(address indexed from, address indexed to, uint256 value);
    mapping(address => uint256) public _balances;
    uint256 public totalTicketCount;
    mapping(address => uint256) public addressToTicket;
    address[] public ticketOwners;
    uint256 public rewardPrice;

    modifier onlyOwner() {
        require(msg.sender == s_owner);
        _;
    }

    constructor(uint64 subscriptionId) VRFConsumerBaseV2(vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        s_owner = msg.sender;
        s_subscriptionId = subscriptionId;
    }

    function mintReward() public {
        Sac.burn(msg.sender, rewardPrice);

        if (newRandNum <= 100) {
            console.log("You won a Ticket!!!!");
            prize = "Ticket";
            totalTicketCount = totalTicketCount + 1;
            addressToTicket[msg.sender] += 1;
            ticketOwners.push(msg.sender);
        }
        if (newRandNum > 100 && newRandNum <= 300) {
            console.log("You won a Core!!!!");
            prize = "Core";
        }
        if (newRandNum > 300 && newRandNum <= 400) {
            console.log("You won a Whitelist!!!!");
            prize = "Whitelist";
        }
        if (newRandNum > 400 && newRandNum <= 700) {
            console.log("You won $crypto!!!!");
            prize = "$crypto";
        }
        if (newRandNum > 700 && newRandNum <= 1000) {
            console.log("You won Nothing!!!!");
            prize = "Nothing";
        }
    }

    function requestRandomWords() external onlyOwner {
        // Will revert if subscription is not set and funded.
        s_requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
    }

    function fulfillRandomWords(
        uint256, /* requestId */
        uint256[] memory randomWords
    ) internal override {
        s_randomWords = randomWords;
    }

    function threeDigitNum() public returns (uint256) {
        uint256 divider = 100000000000000000000000000000000000000000000000000000000000000000000000000;
        newRandNum = (s_randomWords[0] / divider);
        return newRandNum;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}
