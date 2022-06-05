// SPDX-License-Identifier: MIT
// base code is forked off RWASTE, some changes made for clarity

pragma solidity >=0.6.12 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IWarlockz {
    function balanceGenesis(address owner) external view returns (uint256);
}

contract Sacrifice is ERC20, Ownable {
    IWarlockz public Warlockz;
    address SACBags;

    // generation rate of the genesis nfts
    uint256 constant GEN_RATE = 5 ether; //TODO
    // the time this contract is deployed
    uint256 public START_TIME;
    // whether token rewards are live, @dev flip this once reveal is done
    bool public rewardsLive = false;

    mapping(address => uint256) public rewards;
    mapping(address => uint256) public lastUpdate;

    mapping(address => bool) public allowedAddresses;

    modifier onlyWarlockzContract() {
        require(
            address(Warlockz) == msg.sender,
            "Only the Warlockz contract can interact with this contract"
        );
        _;
    }

    constructor(address warlockzAddress) ERC20("Sacrifice Utility Token", "SAC") {
        Warlockz = IWarlockz(warlockzAddress);
        START_TIME = block.timestamp;
        allowedAddresses[address(Warlockz)] = true;
    }

    // updates pending rewards that the NFTs have generated and maps them to the from and to address
    // called on tokentransfers to correctly link rewards to addresses, not NFTs
    function updateReward(address from, address to) external onlyWarlockzContract {
        if (from != address(0)) {
            rewards[from] += getPendingReward(from);
            lastUpdate[from] = block.timestamp;
        }
        if (to != address(0)) {
            rewards[to] += getPendingReward(to);
            lastUpdate[to] = block.timestamp;
        }
    }

    // user claims rewards
    function claimReward() external {
        require(rewardsLive == true, "Rewards are currently not live");
        _mint(msg.sender, rewards[msg.sender] + getPendingReward(msg.sender));
        rewards[msg.sender] = 0;
        lastUpdate[msg.sender] = block.timestamp;
    }

    // burn function used within Warlockz.sol, whenever a user mints a baby, their $ORCA is burnt
    // we use a mapping here because owners/other addresses may need to burn in the future,
    // eg, the auction contract will need to burn utilised pod
    function burn(address user, uint256 amount) external {
        require(
            allowedAddresses[msg.sender] == true ||
                msg.sender == address(Warlockz),
            "Address does not have permission to burn"
        );
        _burn(user, amount);
    }

    function transferFromSacBags(address to, uint256 amount) external {
        require(
            msg.sender == SACBags, 
            "Only the SACBags address can call this function"
        );
        _transfer(SACBags, to, amount);
    }

    // returns the total claimable for owner
    function getTotalClaimable(address user) external view returns (uint256) {
        return rewards[user] + getPendingReward(user);
    }

    // calculates pending rewards
    function getPendingReward(address user) internal view returns (uint256) {
        return
            (Warlockz.balanceGenesis(user) *
                GEN_RATE *
                (block.timestamp -
                    (
                        lastUpdate[user] >= START_TIME
                            ? lastUpdate[user]
                            : START_TIME
                    ))) / 86400;
    }

    // add allowed address to the mapping
    // to remove allowed addresses, simply update their _access to false
    function setAllowedAddresses(address _address, bool _access)
        public
        onlyOwner
    {
        allowedAddresses[_address] = _access;
    }

    function setSACbags(address _address) public onlyOwner {
        SACBags = _address;
    }

    function toggleReward() public onlyOwner {
        rewardsLive = !rewardsLive;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal override virtual {
        require(allowedAddresses[spender] == true, "Can only approve whitelisted contracts");
        super._approve(owner, spender, amount);
    }
}