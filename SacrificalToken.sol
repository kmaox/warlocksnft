// SPDX-License-Identifier: MIT LICENSE

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

interface ISac {
    function balance(address _user) external view returns(uint256);
}

contract SacrificalToken is ERC20("SACRIFICE", "SAC") {
    using SafeMath for uint256;
    address[] internal stakeholders;
    address  payable private owner;
    uint256 public totalTokensBurned = 0;

    // Token Generation for Genesis per day TODO
    uint256 constant public GENESIS_GEN = 10 ether;

    // Token issued when minting a genesis TODO
    uint256 constant public GEN_GRANT = 50 ether;

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
        if(_tokenId <= 2222)
        {
            _mint(_minter,GEN_GRANT);
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
