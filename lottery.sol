// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Lottery {
    address public immutable manager;
    address payable[] public players;

    constructor() {
        manager = msg.sender;
    }

    function startLottery() public {}

    function alreadyEntered() private view returns (bool) {
        for (uint256 i = 0; i < players.length; i++) {
            if (players[i] == msg.sender) {
                return true;
            }
        }
        return false;
    }

    function enterLottery() public payable {
        require(msg.sender != manager, "Manager is not allowed");
        require(alreadyEntered() == false, "Player entry is already present");
        require(msg.value >= 1 ether, "Less than minimum amount i.e; 1 Ether");
        players.push(payable(msg.sender));
    }

    function random() private view returns (uint256) {
        return
            uint256(
                sha256(
                    abi.encodePacked(block.difficulty, block.number, players)
                )
            );
    }

    function pickWinner() public {
        require(msg.sender == manager, "Only Manager can pick the winner");
        uint256 index = random() % players.length;
        address contractAddress = address(this);
        players[index].transfer(contractAddress.balance);
        players = new address payable[](0);
    }

    function getPlayers() public view returns (address payable[] memory) {
        return players;
    }
}
