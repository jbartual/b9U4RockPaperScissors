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
    enum Choices {None,Rock,Scissors,Paper}

    struct Player {
        uint enrolFundsReceived; //control that the player has already submitted the enrolAmount
        mapping (bytes32 => Choices) betHashes;
        bytes32 bet;
    }

    mapping (address => Player) private players;

    function getPlayer (address _player) public constant returns(uint _enrolFundsReceived, bytes32 _bet) {
        _enrolFundsReceived = players[_player].enrolFundsReceived;
        _bet = players[_player].bet;
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

    event LogRPSNewRPS (address _who, address _player1, address _player2, uint _enrolAmount);

    function RPS(address _player1, address _player2, uint _enrolAmount) public {
        //require (_player1 != address(0));
        //require (_player2 != address(0));
        //require (_enrolAmount > 0);

        player1 = _player1;
        player2 = _player2;
        enrolAmount = _enrolAmount; //This is the required exact amount to enrol in the game

        LogRPSNewRPS (msg.sender, _player1, _player2, _enrolAmount);
    }

    event LogRPSGetPlayerBets (address _who);

    function getPlayerBets () onlyPlayers isNotPaused public returns (bytes32[] _bets) {
        //
        // When a player enrols, the contract sends back an array with hashed bets for that player only
        // Requires:
        //  - Only players can execute
        //  - Contract is not paused
        //  - The player to have paid the enrol amount
        //  - The player not to have played already
        //
        require(players[msg.sender].enrolFundsReceived == enrolAmount); //require the bet amount has been deposited
        require(players[msg.sender].bet == 0); //require that the player has not submitted his/her bet yet

        bytes32[] memory bets = new bytes32[](3);

        if (msg.sender == player1) {
            bets[0] = keccak256(msg.sender, msg.data, Choices.Rock);
            bets[1] = keccak256(msg.sender, msg.data, Choices.Paper);
            bets[2] = keccak256(msg.sender, msg.data, Choices.Scissors);
        } else if (msg.sender == player2) {
            bets[0] = keccak256(msg.sender, msg.data, Choices.Rock);
            bets[1] = keccak256(msg.sender, msg.data, Choices.Paper);
            bets[2] = keccak256(msg.sender, msg.data, Choices.Scissors);
        }

        players[msg.sender].betHashes[bets[0]] = Choices.Rock;
        players[msg.sender].betHashes[bets[1]] = Choices.Paper;
        players[msg.sender].betHashes[bets[2]] = Choices.Scissors;

        LogRPSGetPlayerBets (msg.sender);
        return bets;
    }

    event LogRPSPlayerEnrol (address _who, uint _enrolAmount);

    function enrol() onlyPlayers isNotPaused public payable returns(bool success) {
        //
        // To enrol, each player needs to deposit the right Ether amount.
        // Requires:
        //  - Only players can execute
        //  - Contract is not paused
        //
        require (msg.value == enrolAmount); //Ensure the sent amount matches the bet amount
        require (players[msg.sender].enrolFundsReceived == 0); //Avoid double enrollment

        players[msg.sender].enrolFundsReceived = enrolAmount;

        LogRPSPlayerEnrol (msg.sender, msg.value);
        return true;
    }

    event LogRPSPlayerPlay (address _who);

    function play(bytes32 _bet) onlyPlayers isNotPaused public returns(bool _success) {
        //
        // Function used by the players to play their bets
        // Requires:
        //  - Only players can execute
        //  - Contract is not paused
        //  - The player to have paid the enrol amount
        //  - The player not to have played already. Prevents re-entry and bet updating
        //  - The sent bet is one of the assigned to the player
        //
        require(players[msg.sender].enrolFundsReceived == enrolAmount); //require the bet amount has been deposited
        require(players[msg.sender].bet == 0); //require that the player has not submitted his/her bet yet
        require(uint(players[msg.sender].betHashes[_bet]) != 0); //require that the sent bet is one of the assigned to the player

        players[msg.sender].bet = _bet;

        LogRPSPlayerPlay(msg.sender);
        return true;
    }

    event LogRPSGetWinner (address _who, address _winner);

    function getWinner() isNotPaused public returns(address _winner) {
        //
        // Check the submitted bets against the rules.
        // Decide on the winner and mark the winner player.
        // If there is no winner, the owner wins :)
        // Requires:
        //  - Both players to have submitted a bet
        //
        require (players[player1].bet.length != 0); //Both players must have played
        require (players[player2].bet.length != 0);

        bytes32 betPlayer1 = players[player1].bet;
        bytes32 betPlayer2 = players[player2].bet;

        if ((players[player1].betHashes[betPlayer1] == Choices.Rock && players[player2].betHashes[betPlayer2] == Choices.Scissors) || (players[player1].betHashes[betPlayer1] == Choices.Scissors && players[player2].betHashes[betPlayer2] == Choices.Paper) || (players[player1].betHashes[betPlayer1] == Choices.Paper && players[player2].betHashes[betPlayer2] == Choices.Rock)) {
            _winner = player1;
        } else if ((players[player2].betHashes[betPlayer2] == Choices.Rock && players[player1].betHashes[betPlayer1] == Choices.Scissors) || (players[player2].betHashes[betPlayer2] == Choices.Scissors && players[player1].betHashes[betPlayer1] == Choices.Paper) || (players[player2].betHashes[betPlayer2] == Choices.Paper && players[player1].betHashes[betPlayer1] == Choices.Rock)) {
            _winner = player2;
        } else {
            _winner = getOwner();
        }

        LogRPSGetWinner(msg.sender, _winner);
    }

    event LogRPSPayWinner (address _who, address _winner, uint amount);

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

        LogRPSPayWinner (msg.sender, winner, transferAmount);
        return (winner, transferAmount);
    }
}