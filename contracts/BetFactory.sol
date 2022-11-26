// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import "./BettingContract.sol";

contract BetFactory {
    uint256 public counter;
    event LaunchedBet(address indexed betAddress, address indexed owner, uint256 betId);

    constructor() {
        counter = 0;
    }

    function launchBet(string[] memory _teams) external {
        BettingContract bet = new BettingContract(_teams);
        counter++;
        bet.transferOwnership(msg.sender);
        emit LaunchedBet(address(bet), msg.sender, counter);
    }
}