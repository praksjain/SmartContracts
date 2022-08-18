// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract CrowdFunding {
    address payable public owner;
    mapping(address => uint256) public funders;
    uint256 public goal;
    uint256 public minAmt;
    uint256 public timePeriod;
    uint256 public noOfFunders;
    uint256 public fundsRaised;

    constructor(uint256 _goal, uint256 _timePeriod) {
        owner = payable(msg.sender);
        timePeriod = block.timestamp + _timePeriod;
        goal = _goal;
        minAmt = 1000 wei;
    }

    // Fund
    function fund() public payable {
        require(msg.sender != owner, "Owner cannot fund");
        require(msg.value >= minAmt, "Minimum amount is 1000 wei");
        require(block.timestamp < timePeriod, "CrowdFunding is OVER");

        if (funders[msg.sender] == 0) {
            noOfFunders++;
        }
        funders[msg.sender] += msg.value;
        fundsRaised += msg.value;
    }

    receive() external payable {
        fund();
    }

    // Refund
    function refund() public {
        require(block.timestamp > timePeriod, "Funding is still in progress");
        require(funders[msg.sender] > 0, "You have not funded anything");
        require(
            fundsRaised < goal,
            "Funding was successful, cannot refund amount"
        );

        payable(msg.sender).transfer(funders[msg.sender]);
        fundsRaised -= funders[msg.sender];
        noOfFunders--;
        funders[msg.sender] = 0;
    }

    // Request for Payment -> description, amount, receiver, no of votes, voter address, request complete or not
    struct Request {
        string description;
        uint256 amount;
        address payable receiver;
        uint256 noOfVoters;
        mapping(address => bool) votes;
        bool completed;
    }

    mapping(uint256 => Request) public AllRequests;
    uint256 numReq;

    function requestFundForPayment(
        string memory _description,
        uint256 _amount,
        address payable _receiver
    ) public {
        require(msg.sender == owner, "Only owner has this privilege");
        Request storage newRequest = AllRequests[numReq];
        numReq++;

        newRequest.description = _description;
        newRequest.amount = _amount;
        newRequest.receiver = _receiver;
        newRequest.completed = false;
        newRequest.noOfVoters = 0;
    }

    function votingForRequest(uint256 _reqNum) public {
        require(funders[msg.sender] > 0, "Not a funder");
        Request storage thisRequest = AllRequests[_reqNum];
        require(thisRequest.votes[msg.sender] == false, "Already Voted");
        thisRequest.noOfVoters++;
        thisRequest.votes[msg.sender] = true;
    }

    function makePayment(uint256 _reqNum) public {
        require(msg.sender == owner, "Only Owner can do this");
        Request storage thisRequest = AllRequests[_reqNum];
        require(thisRequest.completed == false, "Already COMPLETED");
        require(
            thisRequest.noOfVoters >= noOfFunders / 2,
            "Voting not in favor"
        );
        thisRequest.receiver.transfer(thisRequest.amount);
        thisRequest.completed = true;
    }
}
