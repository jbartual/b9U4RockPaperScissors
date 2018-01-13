var RPS = artifacts.require("./RPS.sol");

contract('RPS', function(accounts) {
  var instance;

  var player1 = accounts[1];
  var player2 = accounts[2];

  before (function(){
    return RPS.new(player1, player2, {from:accounts[0]}).then(function(i) {
      instance = i;
    })
  });

  /*
  it("Player 1 bets Rock - Player 2 bets Scissors. Player 1 wins", () => {
    console.log ("it: Player 1 bets Rock(0) - Player 2 bets Scissors(1). Player 1 wins");

    console.log ("    Player 1 balance = " + web3.fromWei(web3.eth.getBalance(player1),"ether").toString(10));
    console.log ("    Player 2 balance = " + web3.fromWei(web3.eth.getBalance(player2),"ether").toString(10));

    return instance.getContractBalance.call().then((r) => {
        console.log ("    Funds stored in the contract = " + web3.fromWei(r, "ether"));
        console.log ("    Player 1 bets... ");
        return instance.bet(0, {from:player1, value:web3.toWei(0.1, "ether")})
    }).then(() => {
        console.log ("    Player 2 bets... ");
        return instance.bet(1, {from:player2, value:web3.toWei(0.1, "ether")});
    }).then(() => {
        return instance.getContractBalance.call();
    }).then((r) => {
        console.log ("    Funds stored in the contract = " + web3.fromWei(r, "ether"));
        return instance.getBet.call(player1);
    }).then((r) => {
        console.log ("    Player 1 bet is = " + r.toString());
        return instance.getBet.call(player2);
    }).then((r) => {
        console.log ("    Player 2 bet is = " + r.toString());
        console.log ("    Getting the winner...");
        return instance.getWinner.call({from:accounts[0]});
    }).then ((r) => {
        console.log ("    And the winner is... Player " + r[0].toString());
        console.log ("    Paying the winner...");
        return instance.payWinner(r[1], {from:accounts[0]});
    }).then(() => {
        return instance.getContractBalance.call();
    }).then((r) => {
        console.log ("    Funds stored in the contract = " + web3.fromWei(r, "ether"));
        console.log ("    Player 1 balance = " + web3.fromWei(web3.eth.getBalance(player1),"ether").toString(10));
        console.log ("    Player 2 balance = " + web3.fromWei(web3.eth.getBalance(player2),"ether").toString(10));
    });
  });

  it("Player 1 bets Rock - Player 2 bets Rock. Nobody wins. Funds stored in Contract", () => {
    console.log ("it: Player 1 bets Rock(0) - Player 2 bets Rock(0). Nobody wins. Funds stored in Contract");

    console.log ("    Player 1 balance = " + web3.fromWei(web3.eth.getBalance(player1),"ether").toString(10));
    console.log ("    Player 2 balance = " + web3.fromWei(web3.eth.getBalance(player2),"ether").toString(10));

    return instance.getContractBalance.call().then((r) => {
        console.log ("    Funds stored in the contract = " + web3.fromWei(r, "ether"));
        console.log ("    Player 1 bets... ");
        return instance.bet(0, {from:player1, value:web3.toWei(0.1, "ether")})
    }).then(() => {
        console.log ("    Player 2 bets... ");
        return instance.bet(0, {from:player2, value:web3.toWei(0.1, "ether")});
    }).then(() => {
        return instance.getContractBalance.call();
    }).then((r) => {
        console.log ("    Funds stored in the contract = " + web3.fromWei(r, "ether"));
        return instance.getBet.call(player1);
    }).then((r) => {
        console.log ("    Player 1 bet is = " + r.toString());
        return instance.getBet.call(player2);
    }).then((r) => {
        console.log ("    Player 2 bet is = " + r.toString());
        console.log ("    Getting the winner...");
        return instance.getWinner.call({from:accounts[0]});
    }).then ((r) => {
        console.log ("    And the winner is... Player " + r[0].toString());
        console.log ("    Paying the winner...");
        return instance.payWinner(r[1], {from:accounts[0]});
    }).then(() => {
        return instance.getContractBalance.call();
    }).then((r) => {
        console.log ("    Funds stored in the contract = " + web3.fromWei(r, "ether"));
        console.log ("    Player 1 balance = " + web3.fromWei(web3.eth.getBalance(player1),"ether").toString(10));
        console.log ("    Player 2 balance = " + web3.fromWei(web3.eth.getBalance(player2),"ether").toString(10));
    });
  });

  it("Player 1 bets Rock - Player 2 bets Paper. Player 2 wins. Gets double price", () => {
    console.log ("it: Player 1 bets Rock(0) - Player 2 bets Paper(2). Player 2 wins. Gets double price");

    console.log ("    Player 1 balance = " + web3.fromWei(web3.eth.getBalance(player1),"ether").toString(10));
    console.log ("    Player 2 balance = " + web3.fromWei(web3.eth.getBalance(player2),"ether").toString(10));

    return instance.getContractBalance.call().then((r) => {
        console.log ("    Funds stored in the contract = " + web3.fromWei(r, "ether"));
        console.log ("    Player 1 bets... ");
        return instance.bet(0, {from:player1, value:web3.toWei(0.1, "ether")})
    }).then(() => {
        console.log ("    Player 2 bets... ");
        return instance.bet(2, {from:player2, value:web3.toWei(0.1, "ether")});
    }).then(() => {
        return instance.getContractBalance.call();
    }).then((r) => {
        console.log ("    Funds stored in the contract = " + web3.fromWei(r, "ether"));
        return instance.getBet.call(player1);
    }).then((r) => {
        console.log ("    Player 1 bet is = " + r.toString());
        return instance.getBet.call(player2);
    }).then((r) => {
        console.log ("    Player 2 bet is = " + r.toString());
        console.log ("    Getting the winner...");
        return instance.getWinner.call({from:accounts[0]});
    }).then ((r) => {
        console.log ("    And the winner is... Player " + r[0].toString());
        console.log ("    Paying the winner...");
        return instance.payWinner(r[1], {from:accounts[0]});
    }).then(() => {
        return instance.getContractBalance.call();
    }).then((r) => {
        console.log ("    Funds stored in the contract = " + web3.fromWei(r, "ether"));
        console.log ("    Player 1 balance = " + web3.fromWei(web3.eth.getBalance(player1),"ether").toString(10));
        console.log ("    Player 2 balance = " + web3.fromWei(web3.eth.getBalance(player2),"ether").toString(10));
    });
  });
*/
  it("Send funds to the contract. Soft Kill it. Get the funds back. Send funds again and get them back automatically", () => {
    console.log("Send funds to the contract. Soft Kill it. Get the funds back. Send funds again and get them back automatically");

    return instance.getContractBalance.call().then((r) => {
        console.log ("    Funds stored in the contract = " + web3.fromWei(r, "ether"));
        console.log ("    Owner balance = " + web3.fromWei(web3.eth.getBalance(accounts[0]),"ether").toString(10));
        console.log ("    Player 1 balance = " + web3.fromWei(web3.eth.getBalance(player1),"ether").toString(10));
        console.log ("    Palyer 1 sends 0.1 ether...");
        return instance.sendTransaction({from:accounts[1], value:web3.toWei(0.1,"ether")});
    }).then(() => {
        return instance.getContractBalance.call();
    }).then((r) => {
        console.log ("    Funds stored in the contract = " + web3.fromWei(r, "ether"));
        console.log ("    Owner balance = " + web3.fromWei(web3.eth.getBalance(accounts[0]),"ether").toString(10));
        console.log ("    Player 1 balance = " + web3.fromWei(web3.eth.getBalance(player1),"ether").toString(10));
        console.log ("    Soft Kill the contract...")
        return instance.softKill();
    }).then(() => {
        console.log ("    Owner balance = " + web3.fromWei(web3.eth.getBalance(accounts[0]),"ether").toString(10));
        console.log ("    Player 1 balance = " + web3.fromWei(web3.eth.getBalance(player1),"ether").toString(10));
        console.log ("    Player 1 sends 0.1 ether...");
        return instance.sendTransaction({from:accounts[1], value:web3.toWei(0.1,"ether")});
    }).then(() => {
        return instance.getContractBalance.call();
    }).then((r) => {
        console.log ("    Funds stored in the contract = " + web3.fromWei(r, "ether"));
        console.log ("    Owner balance = " + web3.fromWei(web3.eth.getBalance(accounts[0]),"ether").toString(10));
        console.log ("    Player 1 balance = " + web3.fromWei(web3.eth.getBalance(player1),"ether").toString(10));
    })
  });

});
