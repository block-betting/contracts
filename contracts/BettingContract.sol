// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract BettingContract is Ownable, ReentrancyGuard {
    event NewBet(address addy, uint amount, Team teamBet);

    struct Bet {
        string name;
        uint256 amount;
        uint256 totalWon;
        Team teamBet;
    }

    struct Team {
        string name;
        uint256 totalBetAmount;
    }

    // Bet[] public bets;
    Team[] public teams;

    enum State {
        started,
        closed,
        cancelled,
        executed
    }

    State public state;
    address payable conOwner;
    uint public totalBetMoney = 0;
    uint public winnerId;

    mapping(address => Bet) public bets;
    mapping(address => uint) public numBetsAddress;

    constructor(string[] memory _teams) payable {
        conOwner = payable(msg.sender);
        state = State.started;
        for (uint i = 0; i < _teams.length; i++) {
            createTeam(_teams[i]);
        }
    }

    function createTeam(string memory _name) public {
        require(state == State.started, "BBET: Bets not longer accepted");
        teams.push(Team(_name, 0));
    }

    function getTotalBetAmount(uint _teamId) public view returns (uint) {
        return teams[_teamId].totalBetAmount;
    }

    function createBet(uint _teamId) external payable nonReentrant {
        require(state == State.started, "BBET: Bets not longer accepted");
        require(msg.sender != conOwner, "BBET: Owner can't make a bet");
        require(
            numBetsAddress[msg.sender] == 0,
            "BBET: You have already placed a bet"
        );
        require(msg.value > 0.0001 ether, "BBET: Bet below minimum");

        bets[msg.sender] = Bet(
            teams[_teamId].name,
            msg.value,
            0,
            teams[_teamId]
        );
        teams[_teamId].totalBetAmount += msg.value;
        numBetsAddress[msg.sender]++;
        totalBetMoney += msg.value;

        emit NewBet(msg.sender, msg.value, teams[_teamId]);
    }

    function reportWinner(uint _teamId) public payable onlyOwner {
        require(
            state == State.closed,
            "BBET: Bet already distributed or cancelled"
        );
        winnerId = _teamId;
        state = State.executed;
    }

    function pauseForNewBets() public onlyOwner {
        require(state == State.started, "BBET: Bets not in initial state");
        state = State.closed;
    }

    function withdrawnRemaining() external onlyOwner {
        require(state == State.executed, "BBET: Bet not yet executed");
        payable(msg.sender).transfer(address(this).balance);
    }

    function cancel() external onlyOwner {
        require(
            state == State.started,
            "BBET: Bet already distributed or cancelled"
        );
        state = State.cancelled;
    }

    function recoverFunds() external nonReentrant {
        require(state == State.cancelled, "BBET: Bet not cancelled");
        require(bets[msg.sender].amount > 0, "BBET: No bet placed");
        payable(msg.sender).transfer(bets[msg.sender].amount);
    }

    function claimWinnings() external nonReentrant {
        require(state == State.executed, "BBET: Bet not executed");
        require(bets[msg.sender].amount > 0, "BBET: No bet placed");

        if (
            keccak256(abi.encodePacked((bets[msg.sender].teamBet.name))) ==
            keccak256(abi.encodePacked(teams[winnerId].name))
        ) {
            uint div = (bets[msg.sender].amount *
                (totalBetMoney / getTotalBetAmount(winnerId)));
            bets[msg.sender].totalWon = (div * 970) / 1000;
        }

        require(bets[msg.sender].totalWon > 0, "BBET: No winnings to claim");
        payable(msg.sender).transfer(bets[msg.sender].totalWon);
    }

    function recoverERC20(
        address tokenAddress,
        uint256 tokenAmount
    ) public virtual onlyOwner {
        IERC20(tokenAddress).transfer(owner(), tokenAmount);
    }
}
