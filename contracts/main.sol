// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleSpinGame {
    address public owner;
    uint256 public spinPrice = 0.01 ether;

    event Spin(address indexed player, uint256 randomNumber, uint256 prize);

    constructor() {
        owner = msg.sender;
    }

    // Player spins the wheel
    function spin() external payable {
        require(msg.value >= spinPrice, "Not enough ETH to spin");

        // Generate a pseudo-random number (not secure)
        uint256 randomNumber = uint256(
            keccak256(abi.encodePacked(block.timestamp, msg.sender, block.prevrandao))
        ) % 100;

        uint256 prize = calculatePrize(randomNumber);

        // Pay prize if any
        if (prize > 0 && address(this).balance >= prize) {
            payable(msg.sender).transfer(prize);
        }

        emit Spin(msg.sender, randomNumber, prize);
    }

    // Simple prize logic
    function calculatePrize(uint256 randomNumber) internal pure returns (uint256) {
        if (randomNumber < 5) return 1 ether;        // 5% chance
        if (randomNumber < 20) return 0.1 ether;     // 15% chance
        if (randomNumber < 50) return 0.01 ether;    // 30% chance
        return 0;                                   // 50% no prize
    }

    // Owner can withdraw funds
    function withdraw() external {
        require(msg.sender == owner, "Only owner");
        payable(owner).transfer(address(this).balance);
    }

    // Allow deposits to fund prizes
    receive() external payable {}
}