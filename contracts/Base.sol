pragma solidity ^0.4.4;

/*
    This is the base contract to inherit in all contracts
*/

contract Base {
    address private owner;
    bool private isPaused;

    event LogBasePause();
    event LogBaseResume();
    event LogBaseRefund(address _address, uint _amount);

    function getOwner() public constant returns (address _owner) {
        return owner;
    }

    function getIsPaused() public constant returns (bool _isPaused) {
        return isPaused;
    }

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
        LogBasePause();
    }

    function resume() onlyOwner public {
        isPaused = false;
        LogBaseResume();
    }

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

        LogBaseRefund(_address,_amount);
        return true;
    }
}