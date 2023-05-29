// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Raffle {
    // Define variables for storing raffle information
    mapping(address => uint256) public entries;
    address[] public participants;
    bool public isClosed;
    address public winner;

    // Define event for when the raffle is drawn
    event RaffleDrawn(address winner);

    // Function for entering the raffle
    function enter() public payable {
        require(!isClosed, "Raffle is closed");
        require(msg.value > 0, "Entry fee must be greater than 0");
        entries[msg.sender] += msg.value;
        participants.push(msg.sender);
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