pragma solidity ^0.4.4;

//
// Base contract to inherit in all contracts
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

    event LogBaseOwnershipTransfer (address _who, address _newOwner);
    // Function to transfer ownership to a different owner
    // Requires:
    //  - Only owner can execute
    //  - Contract not paused
    //  - New Owner is not 0x0
    function transferOwnership(address _newOwner) onlyOwner isNotPaused public returns(bool success) {
        require (_newOwner != address(0));

        owner = _newOwner;

        LogBaseOwnershipTransfer(msg.sender, _newOwner);
        return true;
    }

    event LogBaseKill (address _who);
    // Destruct the contract and sends any stored value to owner
    // Requires:
    //  - Only owner can execute
    //  - Contract is paused
    function kill() onlyOwner public {
        require (isPaused);

        LogBaseKill (msg.sender);

        selfdestruct(owner);
    }

    event LogBasePause(address _who);
    // Pause the contract. This modifier will prevent calling functions to execute if the contract is paused
    // Requires:
    //  - Only owner can execute
    function pause() onlyOwner public {
        isPaused = true;
        LogBasePause(msg.sender);
    }

    event LogBaseResume(address _who);
    // Resume contract from Pause
    // Requires:
    //  - Contract to be paused
    function resume() onlyOwner public {
        require (isPaused);

        isPaused = false;
        LogBaseResume(msg.sender);
    }

    event LogBaseRefund(address _who, address _beneficiary, uint _amount);
    // Function that allows the owner to refund any available amount to any address
    // To be used in case that the contract is paused with funds inside that need to be refunded
    // Requires:
    //  - The contract to be paused
    //  - _amount to be <= this.balance
    //  - _address not to be 0x0
    function refund(address _address, uint _amount) onlyOwner public returns(bool success) {
        require(isPaused);
        require(_amount <= this.balance);
        require(_address != address(0));

        _address.transfer(_amount);

        LogBaseRefund(msg.sender, _address,_amount);
        return true;
    }
}