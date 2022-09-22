// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.16 <0.9.0;

contract crowdfunding{
    mapping(address => uint) public contributers;
    address public manger;
    uint public deadline;
    uint public target;
    uint public minmumAmount;
    uint public raisedAmount;
    uint public noOfContributers;

    // struct  in this struct we learn about voting technic
    struct Request{
        string description;
        address payable recipient;
        uint value;
        bool completed;
        uint noOfVoters;
        mapping(address => bool) voters;

    }
    mapping(uint => Request) public requests;
    uint public numRequest;
    // constructor
    constructor(uint _target , uint _deadline){
       target = _target;
       deadline = block.timestamp + _deadline;
       minmumAmount = 100 wei;
       manger =  msg.sender;

    }

    function sendEther() public payable {
        require(block.timestamp < deadline , "your time is passed");
        // payable function call only msg.value beacause 
        require(msg.value >= minmumAmount , "please dunate atleast 100 wei");
        // (contributer[key] == value)
        if(contributers[msg.sender] == 0){
            noOfContributers++;
        }
         contributers[msg.sender] += msg.value;
         raisedAmount += msg.value;
        

    }
    //  get balence of current address which check their address
     function getContractBlance() public view returns(uint){
             return address(this).balance;
         }
    //   refund function
    function refund() public{
        require(block.timestamp > deadline  && raisedAmount < target , "your not eligible");
        require(contributers[msg.sender] > 0);
        address payable user = payable(msg.sender);
        user.transfer(contributers[msg.sender]);
        contributers[msg.sender] = 0;

    }
    // we use modifier means only manger have athurty to change the in different funtion
    modifier onlyManger(){
        require(msg.sender == manger , " only manger have authority");
        _;
    }

    //  now we create request which is create by the manger and on the this reqestion particpant will vote
     function createRequest( string memory _description, address payable _recipient, uint _value) public onlyManger{
         Request storage newRequest = requests[numRequest];
         numRequest++;
         newRequest.description = _description;
         newRequest.recipient  = _recipient;
         newRequest.value = _value;
         newRequest.completed = false;
         newRequest.noOfVoters = 0;


     }

    //  now we request for vote for the  contributers.........
    function voteRequest( uint requestNo) public{
        require(contributers[msg.sender]>0, "you must be contributer first") ;
        Request storage thisRequest = requests[requestNo];
        require(thisRequest.voters[msg.sender]  == false , "you are already voted");
        thisRequest.voters[msg.sender] = true;
        thisRequest.noOfVoters++;
    } 

function makePayment( uint requestNO) public onlyManger{
    require(raisedAmount >= target);
    Request storage thisRequest = requests[requestNO];
    require(thisRequest.completed == false , "your request is completed");
    require(thisRequest.noOfVoters > noOfContributers/2 , "you have no magirty");
    thisRequest.recipient.transfer(thisRequest.value);


}


    
    
}