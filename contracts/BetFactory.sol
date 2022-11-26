// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import "./BettingContract.sol";

contract BetFactory {
    uint256 public counter;
    event LaunchedBet(address indexed betAddress, address indexed owner, uint256 betId, string betName);

    constructor() {
        counter = 0;
    }

    struct BetList {
        address betAddress;
        address owner;
        uint256 betId;
        string betName;
        uint timestamp;
    }

    mapping (uint256 => BetList) public betLists;

    function launchBet(string[] memory _teams, string memory _betName) external {
        BettingContract bet = new BettingContract(_teams);
        counter++;
        bet.transferOwnership(msg.sender);

        betLists[counter] = BetList(
            address(bet), 
            msg.sender, 
            counter, 
            _betName, 
            block.timestamp);

        emit LaunchedBet(address(bet), msg.sender, counter, _betName);
    }
}