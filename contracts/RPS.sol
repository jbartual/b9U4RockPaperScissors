pragma solidity ^0.4.4;
import "./Base.sol"; //inherit the Base contract

/*
Rock Paper Scissors
You will create a smart contract named RockPaperScissors whereby:

Alice and Bob can play the classic rock paper scissors game.
to enrol, each player needs to deposit the right Ether amount.
to play, each player submits their unique move.
the contract decides and rewards the winner with all Ether.

Stretch goals:

make it a utility whereby any 2 people can decide to play against each other.
reduce gas costs as much as you can.

Rules:
    Rock > Scissors > Paper > Rock
    0       1           2       0

 */

contract RPS is Base {
    address private player1;
    address private player2;
    bool private hasWinner;

    uint public enrolAmount;
    enum Choices {Rock,Scissors,Paper}

    struct Player {
        uint enrolAmountReceived; //control that the player has already submitted the enrolAmount
        Choices bet;
        bool isBetReceived; //control that the player's bet has been already received
        uint amountPaidBack; //keep how much has been paid back to the player
    }

    mapping (address => Player) private players;

    event LogNewRPS (address player1, address player2, uint enrolAmount);
    event LogPlayerEnrol (address player, uint enrolAmount);
    event LogPlayerPlay (address player);
    event LogTheWinnerIs (address player);
    event LogPayTheWinner (address player, uint amount);
    event LogReset(bool success);

    function RPS(address _player1, address _player2, uint _enrolAmount) public {
        //require (_player1 != address(0));
        //require (_player2 != address(0));
        //require (_enrolAmount > 0);

        player1 = _player1;
        player2 = _player2;
        enrolAmount = _enrolAmount; //This is the required exact amount to enrol in the game

        LogNewRPS (_player1, _player2, _enrolAmount);
    }

    modifier onlyPlayers() {
        //
        //    Only registered players can execute these functions
        //
        require (msg.sender == player1 || msg.sender == player2);
        _;
    }

    function enrol() onlyPlayers isNotPaused public payable returns(bool success) {
        //
        // To enrol, each player needs to deposit the right Ether amount.
        //
        require (msg.value == enrolAmount); //Ensure the sent amount matches the bet amount
        require (players[msg.sender].enrolAmountReceived == 0); //Avoid double enrollment

        players[msg.sender].enrolAmountReceived = enrolAmount;

        LogPlayerEnrol (msg.sender, msg.value);
        return true;
    }


    function play(uint _bet) onlyPlayers isNotPaused public returns(bool success) {
            require(players[msg.sender].enrolAmountReceived == enrolAmount); //require the bet amount has been deposited
            require(!players[msg.sender].isBetReceived); //require that the player has not submitted his/her bet yet

            players[msg.sender].bet = Choices(_bet);
            players[msg.sender].isBetReceived = true;

            LogPlayerPlay(msg.sender);
            return true;
    }

    function getWinner() onlyOwner isNotPaused private returns(address winner) {
        //
        // Check the submitted bets against the rules.
        // Decide on the winner and mark the winner player.
        // If there is no winner, the owner wins :)
        //
        require (players[player1].isBetReceived && players[player2].isBetReceived); //Both players must have played

        if ((players[player1].bet == Choices.Rock && players[player2].bet == Choices.Scissors) || (players[player1].bet == Choices.Scissors && players[player2].bet == Choices.Paper) || (players[player1].bet == Choices.Paper && players[player2].bet == Choices.Rock)) {
            winner = player1;
        } else if ((players[player2].bet == Choices.Rock && players[player1].bet == Choices.Scissors) || (players[player2].bet == Choices.Scissors && players[player1].bet == Choices.Paper) || (players[player2].bet == Choices.Paper && players[player1].bet == Choices.Rock)) {
            winner = player2;
        } else {
            winner = owner;
        }

        LogTheWinnerIs (winner);
    }

    function payWinner () onlyOwner isNotPaused public returns(address winner, uint amount) {
        //
        // Pay the Winner all the accumulated balance.
        // If there is no winner then the owner gets the balance :)
        // Finally it calls the reset() function to reset all positions
        //

        require(!hasWinner);

        winner = getWinner(); //get winner's address
        amount = this.balance;

        hasWinner = true; //prevent re-entry
        players[winner].amountPaidBack = amount; //optimistic accounting

        winner.transfer(amount);

        LogPayTheWinner (winner, amount);
        assert(reset()); //assert uses up all the remaining gas and reverts all changes, while require doesn't exhaust all the remaining gas
    }

    function reset() onlyOwner isNotPaused private returns (bool success) {
        //
        // Resets all positions to prepare for a new turn
        //

        players[player1].enrolAmountReceived = 0;
        players[player1].bet = Choices(0);
        players[player1].isBetReceived = false;
        players[player1].amountPaidBack = 0;

        players[player2].enrolAmountReceived = 0;
        players[player2].bet = Choices(0);
        players[player2].isBetReceived = false;
        players[player2].amountPaidBack = 0;

        hasWinner = false;

        LogReset (true);
        return true;
    }

}