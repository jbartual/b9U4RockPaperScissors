var RockPaperScissors = artifacts.require("./RockPaperScissors.sol");

contract('RockPaperScissors', function(accounts) {
  var i;

  var owner = accounts[0];
  var player1 = accounts[1];
  var player2 = accounts[2];

  var Rock = 1;
  var Scissors = 2;
  var Paper = 3;
  var p1Nonce = 1234;
  var p1Bet = web3.toWei(2, "ether");
  var p2Bet = web3.toWei(1.5, "ether");

  beforeEach (function(){
    return RockPaperScissors.new(0, 0, {from:owner}).then((instance) => {
      i = instance;
    })
  });

  it("Player 1 bets Rock - Player 2 bets Scissors. Player 1 wins", () => {
    let gameID;
    console.log ("it: Player 1 bets Rock - Player 2 bets Scissors. Player 1 wins");

    console.log ("    Player 1 requests new gameID...");
    return i.newGameID.call (player2, {from:player1}).then((r) => {
        gameID = r;
        console.log ("    New gameID = " + gameID);
        console.log ("    Player 1 will get their secret hand...");
        return i.newSecretHand.call (gameID, +Rock, +p1Nonce, {from:player1});
    }).then((r) => {
        console.log ("    Player 1 secret hand = " + r);
        console.log ("      Player 1 balance = " + web3.fromWei(web3.eth.getBalance(player1),"ether").toString());
        console.log ("      Player 2 balance = " + web3.fromWei(web3.eth.getBalance(player2),"ether").toString());
        console.log ("      Contract balance = " + web3.fromWei(web3.eth.getBalance(i.address),"ether").toString());
        console.log ("    Player 1 starts the game...");
        return i.startGame (gameID, r, {from:player1, value:p1Bet});
    }).then(() => {
        console.log ("      Player 1 balance = " + web3.fromWei(web3.eth.getBalance(player1),"ether").toString());
        console.log ("      Player 2 balance = " + web3.fromWei(web3.eth.getBalance(player2),"ether").toString());
        console.log ("      Contract balance = " + web3.fromWei(web3.eth.getBalance(i.address),"ether").toString());
        console.log ("    Player 2 plays their hand in the clear...");
        return i.player2Hand (gameID, +Scissors, {from:player2, value:p2Bet});
    }).then(() => {
        console.log ("      Player 1 balance = " + web3.fromWei(web3.eth.getBalance(player1),"ether").toString());
        console.log ("      Player 2 balance = " + web3.fromWei(web3.eth.getBalance(player2),"ether").toString());
        console.log ("      Contract balance = " + web3.fromWei(web3.eth.getBalance(i.address),"ether").toString());
        return i.getInfoGame.call (gameID, {from:player2});
    }).then((r) => {
        console.log ("      Game Info...");
        console.log ("        Global play deadline: " + r[0]);
        console.log ("        Global reveal deadline: " + r[1]);
        console.log ("        Game player2 play deadline: " + r[2]);
        console.log ("        Game player1 reveal deadline: " + r[3]);
        console.log ("        Game player1 address: " + r[4]);
        console.log ("        Game player1 secret hand: " + r[5]);
        console.log ("        Game player1 bet amount: " + web3.fromWei(r[6],"ether"));
        console.log ("        Game player2 address: " + r[7]);
        console.log ("        Game player2 hand: " + r[8]);
        console.log ("        Game player2 bet amount: " + web3.fromWei(r[9],"ether"));
        console.log ("    Player 1 ends the game by revealing their hand...");
        return i.endGame (gameID, +Rock, +p1Nonce, {from:player1});
    }).then(() => {
        console.log ("      Player 1 balance = " + web3.fromWei(web3.eth.getBalance(player1),"ether").toString());
        console.log ("      Player 2 balance = " + web3.fromWei(web3.eth.getBalance(player2),"ether").toString());
        console.log ("      Contract balance = " + web3.fromWei(web3.eth.getBalance(i.address),"ether").toString());
        assert.equal (web3.eth.getBalance(i.address), 0, "ERROR: Contract balance shall be 0 at the end of the game");
    });
  });

  it("Player 1 bets Rock - Player 2 bets Rock. Tie game...", () => {
    let gameID;
    console.log ("it: Player 1 bets Rock - Player 2 bets Rock. Tie game...");

    console.log ("    Player 1 requests new gameID...");
    return i.newGameID.call (player2, {from:player1}).then((r) => {
        gameID = r;
        console.log ("    New gameID = " + gameID);
        console.log ("    Player 1 will get their secret hand...");
        return i.newSecretHand.call (gameID, +Rock, +p1Nonce, {from:player1});
    }).then((r) => {
        console.log ("    Player 1 secret hand = " + r);
        console.log ("      Player 1 balance = " + web3.fromWei(web3.eth.getBalance(player1),"ether").toString());
        console.log ("      Player 2 balance = " + web3.fromWei(web3.eth.getBalance(player2),"ether").toString());
        console.log ("      Contract balance = " + web3.fromWei(web3.eth.getBalance(i.address),"ether").toString());
        console.log ("    Player 1 starts the game...");
        return i.startGame (gameID, r, {from:player1, value:p1Bet});
    }).then(() => {
        console.log ("      Player 1 balance = " + web3.fromWei(web3.eth.getBalance(player1),"ether").toString());
        console.log ("      Player 2 balance = " + web3.fromWei(web3.eth.getBalance(player2),"ether").toString());
        console.log ("      Contract balance = " + web3.fromWei(web3.eth.getBalance(i.address),"ether").toString());
        console.log ("    Player 2 plays their hand in the clear...");
        return i.player2Hand (gameID, +Rock, {from:player2, value:p2Bet});
    }).then(() => {
        console.log ("      Player 1 balance = " + web3.fromWei(web3.eth.getBalance(player1),"ether").toString());
        console.log ("      Player 2 balance = " + web3.fromWei(web3.eth.getBalance(player2),"ether").toString());
        console.log ("      Contract balance = " + web3.fromWei(web3.eth.getBalance(i.address),"ether").toString());
        return i.getInfoGame.call (gameID, {from:player2});
    }).then((r) => {
        console.log ("      Game Info...");
        console.log ("        Global play deadline: " + r[0]);
        console.log ("        Global reveal deadline: " + r[1]);
        console.log ("        Game player2 play deadline: " + r[2]);
        console.log ("        Game player1 reveal deadline: " + r[3]);
        console.log ("        Game player1 address: " + r[4]);
        console.log ("        Game player1 secret hand: " + r[5]);
        console.log ("        Game player1 bet amount: " + web3.fromWei(r[6],"ether"));
        console.log ("        Game player2 address: " + r[7]);
        console.log ("        Game player2 hand: " + r[8]);
        console.log ("        Game player2 bet amount: " + web3.fromWei(r[9],"ether"));
        console.log ("    Player 1 ends the game by revealing their hand...");
        return i.endGame (gameID, +Rock, +p1Nonce, {from:player1});
    }).then(() => {
        console.log ("      Player 1 balance = " + web3.fromWei(web3.eth.getBalance(player1),"ether").toString());
        console.log ("      Player 2 balance = " + web3.fromWei(web3.eth.getBalance(player2),"ether").toString());
        console.log ("      Contract balance = " + web3.fromWei(web3.eth.getBalance(i.address),"ether").toString());
        assert.equal (web3.eth.getBalance(i.address), 0, "ERROR: Contract balance shall be 0 at the end of the game");
    });
  });

  it("Player 1 bets Rock - Player 2 bets Rock. Player 2 wins.", () => {
    let gameID;
    console.log ("it: Player 1 bets Rock - Player 2 bets Paper. Player 2 wins.");

    console.log ("    Player 1 requests new gameID...");
    return i.newGameID.call (player2, {from:player1}).then((r) => {
        gameID = r;
        console.log ("    New gameID = " + gameID);
        console.log ("    Player 1 will get their secret hand...");
        return i.newSecretHand.call (gameID, +Rock, +p1Nonce, {from:player1});
    }).then((r) => {
        console.log ("    Player 1 secret hand = " + r);
        console.log ("      Player 1 balance = " + web3.fromWei(web3.eth.getBalance(player1),"ether").toString());
        console.log ("      Player 2 balance = " + web3.fromWei(web3.eth.getBalance(player2),"ether").toString());
        console.log ("      Contract balance = " + web3.fromWei(web3.eth.getBalance(i.address),"ether").toString());
        console.log ("    Player 1 starts the game...");
        return i.startGame (gameID, r, {from:player1, value:p1Bet});
    }).then(() => {
        console.log ("      Player 1 balance = " + web3.fromWei(web3.eth.getBalance(player1),"ether").toString());
        console.log ("      Player 2 balance = " + web3.fromWei(web3.eth.getBalance(player2),"ether").toString());
        console.log ("      Contract balance = " + web3.fromWei(web3.eth.getBalance(i.address),"ether").toString());
        console.log ("    Player 2 plays their hand in the clear...");
        return i.player2Hand (gameID, +Paper, {from:player2, value:p2Bet});
    }).then(() => {
        console.log ("      Player 1 balance = " + web3.fromWei(web3.eth.getBalance(player1),"ether").toString());
        console.log ("      Player 2 balance = " + web3.fromWei(web3.eth.getBalance(player2),"ether").toString());
        console.log ("      Contract balance = " + web3.fromWei(web3.eth.getBalance(i.address),"ether").toString());
        return i.getInfoGame.call (gameID, {from:player2});
    }).then((r) => {
        console.log ("      Game Info...");
        console.log ("        Global play deadline: " + r[0]);
        console.log ("        Global reveal deadline: " + r[1]);
        console.log ("        Game player2 play deadline: " + r[2]);
        console.log ("        Game player1 reveal deadline: " + r[3]);
        console.log ("        Game player1 address: " + r[4]);
        console.log ("        Game player1 secret hand: " + r[5]);
        console.log ("        Game player1 bet amount: " + web3.fromWei(r[6],"ether"));
        console.log ("        Game player2 address: " + r[7]);
        console.log ("        Game player2 hand: " + r[8]);
        console.log ("        Game player2 bet amount: " + web3.fromWei(r[9],"ether"));
        console.log ("    Player 1 ends the game by revealing their hand...");
        return i.endGame (gameID, +Rock, +p1Nonce, {from:player1});
    }).then(() => {
        console.log ("      Player 1 balance = " + web3.fromWei(web3.eth.getBalance(player1),"ether").toString());
        console.log ("      Player 2 balance = " + web3.fromWei(web3.eth.getBalance(player2),"ether").toString());
        console.log ("      Contract balance = " + web3.fromWei(web3.eth.getBalance(i.address),"ether").toString());
        assert.equal (web3.eth.getBalance(i.address), 0, "ERROR: Contract balance shall be 0 at the end of the game");
    });
  });
  
  it("Player 1 bets Rock - Owner cancels game.", () => {
    let gameID;
    console.log ("it: Player 1 bets Rock - Owner cancels game.");

    console.log ("    Player 1 requests new gameID...");
    return i.newGameID.call (player2, {from:player1}).then((r) => {
        gameID = r;
        console.log ("    New gameID = " + gameID);
        console.log ("    Player 1 will get their secret hand...");
        return i.newSecretHand.call (gameID, +Rock, +p1Nonce, {from:player1});
    }).then((r) => {
        console.log ("    Player 1 secret hand = " + r);
        console.log ("      Player 1 balance = " + web3.fromWei(web3.eth.getBalance(player1),"ether").toString());
        console.log ("      Player 2 balance = " + web3.fromWei(web3.eth.getBalance(player2),"ether").toString());
        console.log ("      Contract balance = " + web3.fromWei(web3.eth.getBalance(i.address),"ether").toString());
        console.log ("    Player 1 starts the game...");
        return i.startGame (gameID, r, {from:player1, value:p1Bet});
    }).then(() => {
        console.log ("      Player 1 balance = " + web3.fromWei(web3.eth.getBalance(player1),"ether").toString());
        console.log ("      Player 2 balance = " + web3.fromWei(web3.eth.getBalance(player2),"ether").toString());
        console.log ("      Contract balance = " + web3.fromWei(web3.eth.getBalance(i.address),"ether").toString());
        console.log ("    Owner cancels the game");
        return i.cancelGame (gameID, {from:owner});
    }).then(() => {
        console.log ("      Player 1 balance = " + web3.fromWei(web3.eth.getBalance(player1),"ether").toString());
        console.log ("      Player 2 balance = " + web3.fromWei(web3.eth.getBalance(player2),"ether").toString());
        console.log ("      Contract balance = " + web3.fromWei(web3.eth.getBalance(i.address),"ether").toString());
        return i.getInfoGame.call (gameID, {from:owner});
    }).then((r) => {
        console.log ("      Game Info...");
        console.log ("        Global play deadline: " + r[0]);
        console.log ("        Global reveal deadline: " + r[1]);
        console.log ("        Game player2 play deadline: " + r[2]);
        console.log ("        Game player1 reveal deadline: " + r[3]);
        console.log ("        Game player1 address: " + r[4]);
        console.log ("        Game player1 secret hand: " + r[5]);
        console.log ("        Game player1 bet amount: " + web3.fromWei(r[6],"ether"));
        console.log ("        Game player2 address: " + r[7]);
        console.log ("        Game player2 hand: " + r[8]);
        console.log ("        Game player2 bet amount: " + web3.fromWei(r[9],"ether"));
        console.log ("    Player 1 ends the game by revealing their hand...");
        assert.equal (web3.eth.getBalance(i.address), 0, "ERROR: Contract balance shall be 0 at the end of the game");
    });
  });  
});