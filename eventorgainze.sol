// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.16 <0.9.0;

// contract start
contract eventOrgaized{
    struct Event{
        address orgaizer;
        string name;
        uint date;
        uint price;
        uint ticketCount;
        uint ticketRemain;
    }
    mapping (uint => Event) public  events;
    // nested mapping
    mapping(address => mapping(uint => uint)) public tickets;
    uint public nextId;
    // create a event
    function createEvent(string memory _name, uint _date , uint _price ,uint _ticketCount) public {
          require(_date > block.timestamp ,"date must be greater then timestamp");
          require(_ticketCount > 0 , "ticket count must be start from the 1 not 0");

          events[nextId] = Event(msg.sender,_name, _date , _price, _ticketCount , _ticketCount);
          nextId++;
          
    }

    // buy teckets
    function buyTeckets(uint id , uint quantitiy) public payable{
        require(events[id].date != 0 , "must be start an event");
        require(events[id].date > block.timestamp ," buy ticket in the given time");
        Event storage newEvent = events[id];
        require(msg.value == (newEvent.price*quantitiy ) , "price is not enough");
        require(newEvent.ticketRemain >= quantitiy, "not enough tickets");
        newEvent.ticketRemain -= quantitiy;
        tickets[msg.sender][id] += quantitiy;
    }
    // transfer tickets to our family or friends
    function trasferteckts(uint id , uint quantitiy , address to) public {
       require(events[id].date != 0 , "must be start an event");
        require(events[id].date > block.timestamp ," buy ticket in the given time");
        require(tickets[msg.sender][id] >= quantitiy ," you have less tickets");
        tickets[msg.sender][id] -= quantitiy;
        tickets[to][id] += quantitiy;
    }
}