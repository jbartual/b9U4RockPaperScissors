pragma solidity ^0.4.4;

/*
    This is the base contract to inherit in all contracts
*/

contract Base {
    address public owner;
    bool public isPaused;

    function Base() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier isNotPaused() {
        require(!isPaused);
        _;
    }

    function kill() onlyOwner public {
        require (isPaused); //First pause the contract if you want to kill it forever
        selfdestruct(owner);
    }

    function pause() onlyOwner public {
        isPaused = true;
    }

    function resume() onlyOwner public {
        isPaused = false;
    }

    function refund(address _address, uint _amount) onlyOwner public returns(bool success) {
        //
        // Function that allows the owner to refund any available amount to any address
        // To be used in case that the contract is paused with funds inside that need to be refunded
        //

        require(_amount <= this.balance);
        _address.transfer(_amount);
        return true;
    }
}