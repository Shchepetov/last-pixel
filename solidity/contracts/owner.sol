// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Owned {

    address payable internal owner;
    
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    
    modifier isOwner() {

        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    
    constructor() {
        owner = payable(msg.sender);
        emit OwnerSet(address(0), owner);
    }

    function changeOwner(address payable newOwner) public isOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    function getOwner() external view returns (address) {
        return owner;
    }
}