// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./IERC20.sol"; // IERC20 contract import edildi.

contract Raffle {
    // Define variables for storing raffle information
    mapping(address => uint256) public entries;
    mapping(address => uint256) public stakes;  // New mapping to store PLY stakes
    address[] public participants;
    bool public isClosed;
    address public winner;
    uint256 public totalStaked;   // New variable to track total stake amount

    // Add PLY token contract
    IERC20 public plyToken;

    // Define event for when the raffle is drawn
    event RaffleDrawn(address winner);

    // Define event for when user stakes PLY tokens
    event Staked(address indexed user, uint256 amount);  // New event

    // Function for entering the raffle
    function enter() public payable {
        require(!isClosed, "Raffle is closed");
        require(msg.value > 0, "Entry fee must be greater than 0");
        entries[msg.sender] += msg.value;
        participants.push(msg.sender);
    }

    // Function for staking PLY tokens
    function stake(uint256 amount) public {
        require(amount > 0, "Staking amount must be greater than 0");
        require(plyToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        stakes[msg.sender] += amount;
        totalStaked += amount;
        emit Staked(msg.sender, amount);  // Emit Staked event
    }

    // Function for unstaking PLY tokens
    function unstake(uint256 amount) public {
        require(amount > 0, "Unstaking amount must be greater than 0");
        require(stakes[msg.sender] >= amount, "Insufficient staked amount");
        stakes[msg.sender] -= amount;
        totalStaked -= amount;
        require(plyToken.transfer(msg.sender, amount), "Transfer failed");
    }

    // Function to get all stakers
    function getStakers() public view returns (address[] memory) {
        address[] memory stakers = new address[](totalStaked);
        uint256 idx = 0;
        for (uint256 i = 0; i < participants.length; i++) {
            if (stakes[participants[i]] > 0) {
                stakers[idx] = participants[i];
                idx++;
            }
        }
        return stakers;
    }

    // Function for drawing the winner of the raffle
    function drawWinner() public {
        require(!isClosed, "Raffle is closed");
        require(participants.length > 0, "No participants in raffle");
        uint256 totalEntries = 0;
        for (uint256 i = 0; i < participants.length; i++) {
            totalEntries += entries[participants[i]];
        }
        uint256 randomIndex = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % totalEntries;
        uint256 currentIndex = 0;
        for (uint256 i = 0; i < participants.length; i++) {
            currentIndex += entries[participants[i]];
            if (currentIndex >= randomIndex) {
                winner = participants[i];
                break;
            }
        }
        isClosed = true;
        emit RaffleDrawn(winner);
    }

    // Function for claiming the prize
    function claimPrize() public {
        require(msg.sender == winner, "Only the winner can claim the prize");
        payable(winner).transfer(address(this).balance);
    }
}
