// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract Allowances {
    receive() external payable {}

    // address payable public owner;

    // constructor() {
    //     owner = payable(msg.sender);
    // }

    // modifier onlyOwner() {
    //     require(msg.sender == owner, "You are not the owner");
    //     _;
    // }

    function checkBal() public view returns (uint256) {
        return address(this).balance;
    }

    mapping(address => uint256) public allowances;

    function addAllowances(address _from, uint256 _amt) public {
        allowances[_from] += _amt;
    }

    function isOwner() internal view returns (bool) {
        return owner() == msg.sender;
    }

    modifier ownerOrAllowed(uint256 _amt) {
        require(
            isOwner() || allowances[msg.sender] >= _amt,
            "Not an Owner or Not Allowed"
        );
        _;
    }

    event MoneySent(string description, address to, uint256 amt);

    function withdrawMoney(
        string memory _description,
        address payable _to,
        uint256 _amt
    ) public ownerOrAllowed(_amt) {
        require(address(this).balance >= _amt, "Not enough amount");
        if (isOwner() == false) {
            allowances[msg.sender] -= _amt;
        }
        emit MoneySent(_description, _to, _amt);
        _to.transfer(_amt);
    }

    function renounceOwnership() public view override onlyOwner {
        revert("Can't renounce ownership");
    }
}
