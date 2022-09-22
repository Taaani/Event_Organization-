// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.16 <0.9.0;

contract mycrowdFundingPro{
   mapping (address => uint) public contributers;
     address public manger;
     uint public deadline;
     uint public target;
     uint public minmumAmount;
     uint public raisedAmount;
     uint public noOfContributers;

     struct Request{
         string description;
         address payable recipient;
         uint value;
         bool completed;
         uint noOfVoters;
         mapping(address=>bool) voters;

     }

     mapping(uint => Request) requests;
     uint public incrRequest;
    //  mak constructor
    constructor(uint _target , uint _deadline){
        target = _target;
        deadline = block.timestamp + _deadline;
        minmumAmount = 100 wei;
        manger = msg.sender;

    }
    // sendEther to the contract
    function sendEther() public payable{
        require(block.timestamp < deadline,"your time is passed" );
        require(msg.value >= minmumAmount, "your amount is less then our critaria");
        if(contributers[msg.sender]==0){
            noOfContributers++;
        }
        contributers[msg.sender] += msg.value;
        raisedAmount += msg.value;
    }

    // check your send menoy of contract
    function getBlance() public view returns(uint){
        return address(this).balance;
    }

    // refund function..........
    function refundMthod() public{
        require(block.timestamp > deadline && raisedAmount < target , "you cannot fil the conditions");
        require(contributers[msg.sender]>0, "you have no kind of contribution at this time");
        address payable user = payable(msg.sender);
        user.transfer(contributers[msg.sender]);
        contributers[msg.sender] = 0;
    }

    //create modifirer for manger
    modifier onlyManger(){
        require(msg.sender == manger , "you are not manger");
       _;
    }
    //  create Request for any purpose like charity or other
    // first make a struct datatype and then make a function
    function createRequest(string memory _description , address payable _recipient , uint _value) public onlyManger {
        // when we use mapp funtion in the struct then we use it in the funtion we cannot use memory keyword
        Request storage newRequest = requests[incrRequest];
        incrRequest++;
        newRequest.description = _description;
        newRequest.recipient = _recipient;
        newRequest.value  = _value;
        newRequest.completed = false;
        newRequest.noOfVoters = 0;
    }

    //  collection of votes from contributers........
    function voteRequest(uint RequestNo) public{
        require(contributers[msg.sender] > 0);
        Request storage thisRequest = requests[RequestNo];
        require(thisRequest.voters[msg.sender] == false, "you are already cast vote");
        thisRequest.voters[msg.sender] = true;
        thisRequest.noOfVoters++;
    }

    // payment for those request who have maximum votes
    function makpayment(uint requestno) public onlyManger{
        require(raisedAmount >= target);
        Request storage thisRequest = requests[requestno];
        require(thisRequest.completed == false, "your request is already completed");
        thisRequest.completed = true;
        require(thisRequest.noOfVoters > noOfContributers/2 , "you have no magerity");
        thisRequest.recipient.transfer(thisRequest.value);
    }



}