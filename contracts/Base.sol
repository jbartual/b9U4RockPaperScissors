pragma solidity ^0.4.4;

//
// This is the base contract to inherit in all contracts
//

contract Base {
    address private owner;
    bool private isPaused;

    function getOwner() public constant returns (address _owner) {
        return owner;
    }

    function getIsPaused() public constant returns (bool _isPaused) {
        return isPaused;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier isNotPaused() {
        require(!isPaused);
        _;
    }

    event LogBaseNew (address _who);

    function Base() public {
        owner = msg.sender;
        LogBaseNew(msg.sender);
    }

    event LogBaseKill (address _who);

    function kill() onlyOwner public {
        require (isPaused); //First pause the contract if you want to kill it forever

        LogBaseKill (msg.sender);
        selfdestruct(owner);
    }

    event LogBasePause(address _who);

    function pause() onlyOwner public {
        isPaused = true;
        LogBasePause(msg.sender);
    }

    event LogBaseResume(address _who);

    function resume() onlyOwner public {
        isPaused = false;
        LogBaseResume(msg.sender);
    }

    event LogBaseRefund(address _who, address _toWho, uint _amount);

    function refund(address _address, uint _amount) onlyOwner public returns(bool success) {
        //
        // Function that allows the owner to refund any available amount to any address
        // To be used in case that the contract is paused with funds inside that need to be refunded
        // Requires:
        //   - The contract to be paused
        //   - _amount to be <= this.balance
        //   - _address not to be 0
        //
        require(isPaused);
        require(_amount <= this.balance);
        require(_address != address(0));

        _address.transfer(_amount);

        LogBaseRefund(msg.sender, _address,_amount);
        return true;
    }
}