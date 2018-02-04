pragma solidity ^0.4.4;

/*
Rock Paper Scissors
You will create a smart contract named RockPaperScissors whereby:

Alice and Bob can play the classic rock paper scissors game.
- to enrol, each player needs to deposit the right Ether amount.
- to play, each player submits their unique move.
- the contract decides and rewards the winner with all Ether.

Stretch goals:
- make it a utility whereby any 2 people can decide to play against each other.
- reduce gas costs as much as you can.

Rules:
    Rock > Scissors > Paper > Rock
    1       2           3       1
 */

 /*

Workflow:
- Player1 requests a newGame with Player2. Obtains hashGameID
- Player1 and Player2 off-chain obtain their hashSecretHand bets
- Player1 plays their SecretHand. Sets expiration times to play and reveal
- Player2 plays in the clear (before expiration time)
- Player1 ends the game by revealing their SecretHand (before reveal expiration time)
    - Contract rewards the winner and refunds any leftover bet amount to the players
- At any time any player can request to refund an expired game. The contract will evaluate if the game is expired and refund accordingly

CORE functions:
- newGameID
- newSecretHand
- startGame
- player2Hand
- endGame
- payWinner
- refundGame
- refundExpiredGame

ADMIN functions
- cancelGame

SUPPORT functions
- getInfoGame
- getInfoHand
- isGameExpired

 */

import "./MyShared/Stoppable.sol"; //inherit the Base contract

contract RockPaperScissors is Stoppable {

    enum Hand {NONE, Rock, Scissors, Paper}

    uint constant PLAYDEADLINE = 86400/15; //24 hours
    uint constant REVEALDEADLINE = 86400/15; //24 hours
    uint public globalPlayDeadline;
    uint public globalRevealDeadline;

    struct Game {
        uint p2PlayDeadline;
        uint p1RevealDeadline;
        
        address p1Address;
        bytes32 p1SecretHand;
        uint p1BetAmount;

        address p2Address;
        Hand p2Hand;
        uint p2BetAmount;
    }
    mapping (bytes32 => Game) games; //hashGameID => Game

// CORE functions

        event LogRockPaperScissorsNew (address _sender); 
    function RockPaperScissors (uint _playDeadline, uint _revealDeadline)
        public
    {
        if (_playDeadline == 0)
            globalPlayDeadline = PLAYDEADLINE;
        else
            globalPlayDeadline = _playDeadline;
        
        if (_revealDeadline == 0)
            globalRevealDeadline = REVEALDEADLINE;
        else
            globalRevealDeadline = _revealDeadline;

        LogRockPaperScissorsNew(msg.sender);
    }

        // Having player2 address prevents player 1 and player2 to play more than one game among them simultaneously
    function newGameID (address _player2)
        onlyIfRunning
        constant
        public
        returns (bytes32 _hashGameID)
    {
        return keccak256(msg.sender, _player2);
    }

    function newSecretHand (bytes32 _hashGameID, uint _hand, uint _nonce)
        onlyIfRunning
        constant
        public
        returns (bytes32 _secretHand)
    {
        return keccak256(msg.sender, _hashGameID, _hand, _nonce);
    }

        event LogRockPaperScissorsStartGame (address _sender, bytes32 _hashGameID, bytes32 _secretHand);
        // Player 1 starts a new game with Player 2 by sending first their secret hand and the bet amount
    function startGame (bytes32 _hashGameID, bytes32 _secretHand)
        onlyIfRunning
        payable
        public
        returns (bool _success)
    {
        require (_hashGameID != 0);
        require (_secretHand != 0);
        require (games[_hashGameID].p1SecretHand == 0); //require new game

        games[_hashGameID].p2PlayDeadline = globalPlayDeadline + now;

        Game storage game = games[_hashGameID]; //get a pointer to the game in storage
        
        game.p1RevealDeadline = globalRevealDeadline + now;

        game.p1Address = msg.sender;
        game.p1SecretHand = _secretHand;
        game.p1BetAmount = msg.value;

        LogRockPaperScissorsStartGame (msg.sender, _hashGameID, _secretHand);
        return true;
    }

        event LogRockPaperScissorsPlayer2Hand (address _sender, bytes32 _hashGameID, uint _hand);
        // Only player 2 can execute this function AFTER player 1 started the gmae with their secret hand
        // Player 2 plays their hand in the clear as player 1 shall have already played
    function player2Hand (bytes32 _hashGameID, uint _hand)
        onlyIfRunning
        payable
        public
        returns (bool _success)
    {
        require (_hashGameID != 0);
        require (_hand != 0);

        Game storage game = games[_hashGameID]; //get a pointer to the game in storage
        require (game.p1Address != msg.sender); //player 1 cannot execute this function
        require (game.p1SecretHand != 0); //require existing game
        require (game.p2Hand == Hand.NONE); //prevent player2 to play more than once

        if (now > game.p2PlayDeadline) //game expired
        {
            refundGame (_hashGameID);
            return false;
        }

        game.p2Address = msg.sender;
        game.p2Hand = Hand(_hand);
        game.p2BetAmount = msg.value;

        LogRockPaperScissorsPlayer2Hand (msg.sender, _hashGameID, _hand);
        return true;
    }

        event LogRockPaperScissorsEndGame (address _sender, bytes32 _hashGameID, uint _p1Hand, uint _nonce);
        // Any player can call this function if all the parameters are known
        // Finishes the game by revealing player 1 secret hand
        // Pays the winner
    function endGame (bytes32 _hashGameID, uint _p1Hand, uint _nonce)
        onlyIfRunning
        public
        returns (bool _success)
    {
        require (_hashGameID != 0);
        require (_p1Hand != 0);
        require (games[_hashGameID].p1Address != 0); //prevent re-entry

        Game storage game = games[_hashGameID];
        require (game.p1SecretHand == newSecretHand(_hashGameID, _p1Hand, _nonce)); //require that the revealed hand is the same as the secret hand

        if (now > game.p1RevealDeadline) //game expired
        {
            refundGame (_hashGameID);
            return false;
        }
        
        Hand p1Hand = Hand(_p1Hand);
        Hand p2Hand = game.p2Hand;

        if ((p1Hand == Hand.Rock && p2Hand == Hand.Scissors) || (p1Hand == Hand.Scissors && p2Hand == Hand.Paper) || (p1Hand == Hand.Paper && p2Hand == Hand.Rock)) 
        {
            payWinner (_hashGameID, game.p1Address);
        } 
        else if ((p2Hand == Hand.Rock && p1Hand == Hand.Scissors) || (p2Hand == Hand.Scissors && p1Hand == Hand.Paper) || (p2Hand == Hand.Paper && p1Hand == Hand.Rock)) 
        {
            payWinner (_hashGameID, game.p2Address);
        }
        else
        {
            refundGame (_hashGameID); //both players played the same hand. Refund them
        }

        LogRockPaperScissorsEndGame (msg.sender, _hashGameID, _p1Hand, _nonce);
        return true;
    }

        event LogRockPaperScissorsPayWinner (address _sender, bytes32 _hashGameID, address _winner);
        // PRIVATE
        // Pays the winner the smallest bet and refunds the player with the biggest bet any unused amount
    function payWinner (bytes32 _hashGameID, address _winner)
        onlyIfRunning
        private
        returns (bool _success)
    {
        require (_hashGameID != 0);
        require (_winner != 0);

        Game storage game = games[_hashGameID];

        uint p1BetAmount = game.p1BetAmount;
        uint p2BetAmount = game.p2BetAmount;

        address player1 = game.p1Address;
        address player2 = game.p2Address;

        delete games[_hashGameID]; //optimistic accounting

        if (_winner == player1) //if the winner is player 1
        {
            if ((p1BetAmount > p2BetAmount) || (game.p1BetAmount == game.p2BetAmount)) //and player 1 bet is higher than player 2 or equal
            {
                player1.transfer (p1BetAmount + p2BetAmount);
            }
            else if (p1BetAmount < p2BetAmount) //and player 2 bet is higher than player 1
            {
                player1.transfer (p1BetAmount*2);
                player2.transfer (p2BetAmount - p1BetAmount); //refund player2 the leftover bet amount
            }
        }
        else if  (_winner == player2) //the winner is player 2
        {
            if ((p2BetAmount > p1BetAmount) || (game.p1BetAmount == game.p2BetAmount)) //and player 1 bet is higher than player 2 or equal
            {
                player2.transfer (p1BetAmount + p2BetAmount);
            }
            else if (p2BetAmount < p1BetAmount) //and player 1 bet is higher than player 2
            {
                player2.transfer (p2BetAmount*2);
                player1.transfer (p1BetAmount - p2BetAmount); //refund player1 the leftover bet amount
            }
        }

        LogRockPaperScissorsPayWinner (msg.sender, _hashGameID, _winner);
        return true;
    }

        event LogRockPaperScissorsRefundGame (address _sender, bytes32 _hashGameID);
        // PRIVATE
        // Refunds each player thier bets
        // To be executed in case of a tie or expired game
    function refundGame (bytes32 _hashGameID)
        onlyIfRunning
        private
        returns (bool _success)
    {
        Game storage game = games[_hashGameID];

        uint p1BetAmount = game.p1BetAmount;
        uint p2BetAmount = game.p2BetAmount;

        address player1 = game.p1Address;
        address player2 = game.p2Address;

        delete games[_hashGameID]; //optimistic accounting

        if (player1 != 0) player1.transfer (p1BetAmount);
        if (player2 != 0) player2.transfer (p2BetAmount);

        LogRockPaperScissorsRefundGame (msg.sender, _hashGameID);
        return true;
    }

        event LogRockPaperScissorsRefunExpiredGame (address _sender, bytes32 _hashGameID);
        // Any player can call this function and if the game is expired
        // the contract will refund the bets to each player
    function refundExpiredGame (bytes32 _hashGameID)
        onlyIfRunning
        public
        returns (bool _success)
    {
        require (_hashGameID != 0);
        require (now > games[_hashGameID].p2PlayDeadline || now > games[_hashGameID].p1RevealDeadline); //the game shall be expired in either condition

        refundGame (_hashGameID); //this function refunds each player with their bet amount

        LogRockPaperScissorsRefunExpiredGame (msg.sender, _hashGameID);
        return true;
    }

// ADMIN functions

        event LogRockPaperScissorsCancelGame (address _sender, bytes32 _hashGameID);
        // Owner can cancel the game at any time
    function cancelGame (bytes32 _hashGameID)
        onlyOwner
        public 
        returns (bool _success)
    {
        require (_hashGameID != 0);

        refundGame (_hashGameID);

        LogRockPaperScissorsCancelGame (msg.sender, _hashGameID);
        return true;
    }

// SUPPORT functions

    function getInfoGame (bytes32 _hashGameID)
        view
        public
        returns(uint _globalPlayDeadline, 
                uint _globalRevealDeadline, 
                uint _p2PlayDeadline,
                uint _p1RevealDeadline, 
                address _p1Address, 
                bytes32 _p1SecretHand, 
                uint _p1BetAmount, 
                address _p2Address, 
                Hand _p2Hand, 
                uint _p2BetAmount)
    {
        Game storage game = games[_hashGameID];
        
        return (
            globalPlayDeadline,
            globalRevealDeadline,
            game.p2PlayDeadline,
            game.p1RevealDeadline,
            game.p1Address,
            game.p1SecretHand,
            game.p1BetAmount,
            game.p2Address,
            game.p2Hand,
            game.p2BetAmount
        );
    }

    function getInfoHand ()
        pure
        public
        returns (uint _rock, uint _paper, uint _scissors)
    {
        return (1, 3, 2);
    }

    function isGameExpired (bytes32 _hashGameID)
        constant
        public
        returns (bool _isExpired)
    {
        require (_hashGameID != 0);

        if (now > games[_hashGameID].p2PlayDeadline || now > games[_hashGameID].p1RevealDeadline)
            return true;
        else
            return false;
    }
}