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
    1       2           3       1

 */

contract RPS is Base {
    address private player1;
    address private player2;
    address private winner;

    uint private enrolAmount;
    enum Choices {None, Rock,Scissors,Paper}

    struct Player {
        uint enrolFundsReceived; //control that the player has already submitted the enrolAmount
        Choices bet;
    }

    mapping (address => Player) private players;

    function getPlayer (address _player) public constant returns(uint _enrolFundsReceived, uint _bet) {
        _enrolFundsReceived = players[_player].enrolFundsReceived;
        _bet = uint(players[_player].bet);
    }

    function getEnrolAmount() public constant returns(uint _enrolAmount) {
        return enrolAmount;
    }

    modifier onlyPlayers() {
        //
        // Only registered players can execute these functions
        //
        require (msg.sender == player1 || msg.sender == player2);
        _;
    }

    event LogRPSNewRPS (address player1, address player2, uint enrolAmount);
    function RPS(address _player1, address _player2, uint _enrolAmount) public {
        //require (_player1 != address(0));
        //require (_player2 != address(0));
        //require (_enrolAmount > 0);

        player1 = _player1;
        player2 = _player2;
        enrolAmount = _enrolAmount; //This is the required exact amount to enrol in the game

        LogRPSNewRPS (_player1, _player2, _enrolAmount);
    }

    event LogRPSPlayerEnrol (address player, uint enrolAmount);
    function enrol() onlyPlayers isNotPaused public payable returns(bool _success) {
        //
        // To enrol, each player needs to deposit the right Ether amount.
        // Requires:
        //  - Only players can enrol
        //  - The contract is not paused
        //
        require (msg.value == enrolAmount); //Ensure the sent amount matches the bet amount
        require (players[msg.sender].enrolFundsReceived == 0); //Avoid double enrollment

        players[msg.sender].enrolFundsReceived = enrolAmount;

        LogRPSPlayerEnrol (msg.sender, msg.value);
        return true;
    }

    event LogRPSPlayerPlay (address player);
    function play(uint _bet) onlyPlayers isNotPaused public returns(bool _success) {
        //
        // Function used by the players to play their bets
        // Requires:
        //  - Only players can execute
        //  - Contract is not paused
        //  - The player to have paid the enrol amount
        //  - The player not to have played already. Prevents re-entry and bet updating
        //
        require(players[msg.sender].enrolFundsReceived == enrolAmount); //require the bet amount has been deposited
        require(players[msg.sender].bet == Choices.None); //require that the player has not submitted his/her bet yet

        players[msg.sender].bet = Choices(_bet);

        LogRPSPlayerPlay(msg.sender);
        return true;
    }

    event LogRPSGetWinner (address player);
    function getWinner() isNotPaused private returns(address _winner) {
        //
        // PRIVATE
        // Check the submitted bets against the rules.
        // Decide on the winner and mark the winner player.
        // If there is no winner, the owner wins :)
        // Requires:
        //  - Both players to have submitted a bet
        //
        require (players[player1].bet != Choices.None); //Both players must have played
        require (players[player2].bet != Choices.None);

        if ((players[player1].bet == Choices.Rock && players[player2].bet == Choices.Scissors) || (players[player1].bet == Choices.Scissors && players[player2].bet == Choices.Paper) || (players[player1].bet == Choices.Paper && players[player2].bet == Choices.Rock)) {
            _winner = player1;
        } else if ((players[player2].bet == Choices.Rock && players[player1].bet == Choices.Scissors) || (players[player2].bet == Choices.Scissors && players[player1].bet == Choices.Paper) || (players[player2].bet == Choices.Paper && players[player1].bet == Choices.Rock)) {
            _winner = player2;
        } else {
            _winner = getOwner();
        }

        LogRPSGetWinner(_winner);
    }

    event LogRPSPayWinner (address player, uint amount);
    function payWinner () isNotPaused public returns(address _winner, uint _amount) {
        //
        // Pay the Winner all the accumulated balance.
        // If there is no winner then the owner gets the balance :)
        // Requires:
        //  - Contract is not paused
        //  - That a winner has not been declared already
        //
        require(winner == address(0)); //prevent re-entry

        winner = getWinner(); //get winner's address and prevent re-entry

        uint transferAmount = this.balance;
        winner.transfer(transferAmount);

        LogRPSPayWinner (winner, transferAmount);
        return (winner, transferAmount);
    }
}