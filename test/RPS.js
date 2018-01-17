var RPS = artifacts.require("./RPS.sol");

contract('RPS', function(accounts) {
  var instance;

  var owner = accounts[3];
  var player1 = accounts[1];
  var player2 = accounts[2];
  var enrolAmount = web3.toWei(0.1,"ether");

  beforeEach (function(){
    return RPS.new(player1, player2, enrolAmount, {from:owner}).then((i) => {
      instance = i;
    })
  });

  it("Player 1 bets Rock - Player 2 bets Scissors. Player 1 wins", () => {
    console.log ("it: Player 1 bets Rock(r[0]) - Player 2 bets Scissors(r[2]). Player 1 wins");

    console.log ("    Owner ("+ owner.toString() +") balance = " + web3.fromWei(web3.eth.getBalance(owner),"ether").toString(10));
    console.log ("    Player 1 ("+ player1.toString() +") balance = " + web3.fromWei(web3.eth.getBalance(player1),"ether").toString(10));
    console.log ("    Player 2 ("+ player2.toString() +") balance = " + web3.fromWei(web3.eth.getBalance(player2),"ether").toString(10));
    console.log ("    Funds stored in the contract = " + web3.fromWei(web3.eth.getBalance(instance.address),"ether").toString(10));

    console.log ("    Player 1 enrols...");
    return instance.enrol({from:player1, value:enrolAmount}).then(()=> {
        return instance.getPlayerBets.call({from:player1});
    }).then((r) => {
        console.log ("    Player 1 plays... " + r[0].toString());
        return instance.play(r[0], {from:player1});
    }).then(() => {
        console.log ("    Player 1 balance = " + web3.fromWei(web3.eth.getBalance(player1),"ether").toString(10));
        console.log ("    Player 2 enrols...");
        return instance.enrol({from:player2, value:enrolAmount});
    }).then(()=>{
        return instance.getPlayerBets.call({from:player2});
    }).then((r) => {
        console.log ("    Player 2 plays... " + r[2].toString());
        return instance.play(r[2], {from:player2});
    }).then(() => {
        console.log ("    Player 2 balance = " + web3.fromWei(web3.eth.getBalance(player2),"ether").toString(10));
        console.log ("    Funds stored in the contract = " + web3.fromWei(web3.eth.getBalance(instance.address),"ether").toString(10));
        console.log ("    Getting and Paying the Winner...");
        return instance.payWinner();
    }).then(() => {
        console.log ("    Funds stored in the contract = " + web3.fromWei(web3.eth.getBalance(instance.address),"ether").toString(10));
        console.log ("    Owner balance = " + web3.fromWei(web3.eth.getBalance(owner),"ether").toString(10));
        console.log ("    Player 1 balance = " + web3.fromWei(web3.eth.getBalance(player1),"ether").toString(10));
        console.log ("    Player 2 balance = " + web3.fromWei(web3.eth.getBalance(player2),"ether").toString(10));
        return web3.eth.getBalance(instance.address);
    }).then((r) => {
        assert.equal(+r, 0, "ERROR: Contract balance shall be 0");
    });
  });

  it("Player 1 bets Rock - Player 2 bets Rock. Tie. Owner wins", () => {
    console.log ("it: Player 1 bets Rock(r[0]) - Player 2 bets Rock(r[0]). Tie. Owner wins");

    console.log ("    Owner ("+ owner.toString() +") balance = " + web3.fromWei(web3.eth.getBalance(owner),"ether").toString(10));
    console.log ("    Player 1 ("+ player1.toString() +") balance = " + web3.fromWei(web3.eth.getBalance(player1),"ether").toString(10));
    console.log ("    Player 2 ("+ player2.toString() +") balance = " + web3.fromWei(web3.eth.getBalance(player2),"ether").toString(10));
    console.log ("    Funds stored in the contract = " + web3.fromWei(web3.eth.getBalance(instance.address),"ether").toString(10));

    console.log ("    Player 1 enrols...");
    return instance.enrol({from:player1, value:enrolAmount}).then(()=> {
        return instance.getPlayerBets.call({from:player1});
    }).then((r) => {
        console.log ("    Player 1 plays... " + r[0].toString());
        return instance.play(r[0], {from:player1});
    }).then(() => {
        console.log ("    Player 1 balance = " + web3.fromWei(web3.eth.getBalance(player1),"ether").toString(10));
        console.log ("    Player 2 enrols...");
        return instance.enrol({from:player2, value:enrolAmount});
    }).then(()=>{
        return instance.getPlayerBets.call({from:player2});
    }).then((r) => {
        console.log ("    Player 2 plays... " + r[0].toString());
        return instance.play(r[0], {from:player2});
    }).then(() => {
        console.log ("    Player 2 balance = " + web3.fromWei(web3.eth.getBalance(player2),"ether").toString(10));
        console.log ("    Funds stored in the contract = " + web3.fromWei(web3.eth.getBalance(instance.address),"ether").toString(10));
        console.log ("    Getting and Paying the Winner...");
        return instance.payWinner();
    }).then(() => {
        console.log ("    Funds stored in the contract = " + web3.fromWei(web3.eth.getBalance(instance.address),"ether").toString(10));
        console.log ("    Owner balance = " + web3.fromWei(web3.eth.getBalance(owner),"ether").toString(10));
        console.log ("    Player 1 balance = " + web3.fromWei(web3.eth.getBalance(player1),"ether").toString(10));
        console.log ("    Player 2 balance = " + web3.fromWei(web3.eth.getBalance(player2),"ether").toString(10));
        return web3.eth.getBalance(instance.address);
    }).then((r) => {
        assert.equal(+r, 0, "ERROR: Contract balance shall be 0");
    });
  });

  it("Player 1 enrols. Owner pauses the contract. Owner refunds Player 1. Player 2 tries to enrol but cannot", () => {
    console.log("it: Player 1 enrols. Owner pauses the contract. Owner refunds Player 1. Player 2 tries to enrol but cannot");

    console.log ("    Owner ("+ owner.toString() +") balance = " + web3.fromWei(web3.eth.getBalance(owner),"ether").toString(10));
    console.log ("    Player 1 ("+ player1.toString() +") balance = " + web3.fromWei(web3.eth.getBalance(player1),"ether").toString(10));
    console.log ("    Funds stored in the contract = " + web3.fromWei(web3.eth.getBalance(instance.address),"ether").toString(10));

    console.log ("    Player 1 enrols...");
    return instance.enrol({from:player1, value:enrolAmount}).then(()=> {
        console.log ("    Player 1 balance = " + web3.fromWei(web3.eth.getBalance(player1),"ether").toString(10));
        console.log ("    Funds stored in the contract = " + web3.fromWei(web3.eth.getBalance(instance.address),"ether").toString(10));
        console.log ("    Owner pauses contract...");
        return instance.pause({from:owner});
    }).then(() => {
        console.log ("    Funds stored in the contract = " + web3.fromWei(web3.eth.getBalance(instance.address),"ether").toString(10));
        console.log ("    Owner instruct contract to refund Player 1 for " + web3.fromWei(enrolAmount,"ether"));
        return instance.refund(player1, enrolAmount, {from:owner});
    }).then(() => {
        console.log ("    Player 1 balance = " + web3.fromWei(web3.eth.getBalance(player1),"ether").toString(10));
        console.log ("    Funds stored in the contract = " + web3.fromWei(web3.eth.getBalance(instance.address),"ether").toString(10));
        console.log ("    Player 2 ("+ player2.toString() +") balance = " + web3.fromWei(web3.eth.getBalance(player2),"ether").toString(10));
        console.log ("    Player 2 tries to enrol...");
        return instance.enrol({from:player2, value:enrolAmount});
    }).then(()=>{
        console.log ("    Player 2 balance = " + web3.fromWei(web3.eth.getBalance(player2),"ether").toString(10));
        console.log ("    Funds stored in the contract = " + web3.fromWei(web3.eth.getBalance(instance.address),"ether").toString(10));
        return web3.eth.getBalance(instance.address);
    }).then((r) => {
        assert.equal(+r, 0, "ERROR: Contract balance shall be 0");
    });
  });
});
