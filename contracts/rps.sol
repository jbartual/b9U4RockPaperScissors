pragma solidity ^0.4.4;

/*
Rock, Paper, Scissors Contract

Rules:
    Rock > Scissors > Paper > Rock
    0       1           2       0
 */

contract RPS {
    address public owner;
    address private player1;
    address private player2;

    enum choices {Rock,Scissors,Paper}
    mapping (address => choices) private playerBets;

    bool private isKilled;

    function RPS(address _player1, address _player2) public {
        owner = msg.sender;
        player1 = _player1;
        player2 = _player2;
        isKilled = false;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyPlayers() {
        require (msg.sender == player1 || msg.sender == player2);
        _;
    }

    function kill() onlyOwner public {
        selfdestruct(owner);
    }

    function softKill() onlyOwner public {
        isKilled = true;
        owner.transfer(this.balance);
    }

    function softResurrect() onlyOwner public {
        isKilled = false;
    }

    function getIsKilled() public returns(bool) {
        return isKilled;
    }

    function () payable public {
        if (isKilled == true) {
            msg.sender.transfer(this.balance); //in case the contract is soft killed return the funds to the sender
        }
    }

    function bet(uint _bet) onlyPlayers public payable returns(bool) {
        if (isKilled) {
            msg.sender.transfer(this.balance); //in case the contract is soft killed return the funds to the sender
            return false;
        } else {
            require(msg.value == 0.1 ether); //require the best to be of 0.1 ether

            playerBets[msg.sender] = choices(_bet);
            return true;
        }
    }

    function getWinner() onlyOwner public returns(uint, address) {
        uint player;
        address winner;

        require(!isKilled);

        choices p1bet = playerBets[player1];
        choices p2bet = playerBets[player2];

        if ((p1bet == choices.Rock && p2bet == choices.Scissors) || (p1bet == choices.Scissors && p2bet == choices.Paper) || (p1bet == choices.Paper && p2bet == choices.Rock)) {
            //Player1 wins
            winner = player1;
            player = 1;
        } else if ((p2bet == choices.Rock && p1bet == choices.Scissors) || (p2bet == choices.Scissors && p1bet == choices.Paper) || (p2bet == choices.Paper && p1bet == choices.Rock)) {
            //Player2 wins
            winner = player2;
            player = 2;
        }
        //Else: Tie. The bets are kept in the contract and accumulated for the next round

        return (player, winner); //returns which player won
    }

    function payWinner (address _winner) onlyOwner public {
        require(!isKilled);
        require(_winner == player1 || _winner == player2); //only one of the players can be paid
        require(this.balance > 0);
        _winner.transfer(this.balance);
    }

    function getContractBalance () public returns(uint) {
        return this.balance;
    }

    function getBet (address _player) public returns(choices) {
        return playerBets[_player];
    }
}