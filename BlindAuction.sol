// SPDX-License-Identifier: MIT
pragma solidity >=0.4.23 <0.7.0;

contract BlindAuction{
    
    struct Bid{
        
        bytes32 blindBid;
        uint deposit;
        
    }
    
    address payable public benficiary;
    
    uint public biddingEnd;
    
    uint public revealEnd;
    
    bool public ended;
    
    mapping(address => uint) public bids;
    
    addrerss public highestBidder;
    
    uint public highestBid;
    
    mapping(addrerss => uint) pendingreturns;
    
    event auctionEnded(addrerss winner, uint highestBid);
    
    modifier onlyBefore(uint _time) { require(now < _time); _; }
    
    modifier onlyAfter(uint _time) { require(now > _time); _; }

    
    constructor(
         uint _biddingTime,
         
         uint _revealTime,
         
         address payable _beneficiary;
        
        ) public {
            
            beneficiary = _beneficiary;
            biddingEnd = now + _biddingTime;
            revealEnd = biddingEnd + _revealTime;
        }
        
    
    function bid(bytes32 _blindedBid)
       
        public
        
        payable 
        
        onlyBefore(biddingEnd)
        
        {
            bids[msg.sender].push(Bid({
                blindBid: _blindedBid;
                deposit: msg.value
            }));
        }
        
        
    function reveal(
        uint[] memory _values,
        
        uint[] memory _fake,
        
        bytes32[] memory _secret
        
        )
        
        public
        
        onlyAfter(biddingEnd)
        
        onlyBefore(revealEnd)
        
        {
            uint length = bids[msg.sender].length;
            
            require (_values.length == length);
            
            require(_fake.length == length);
            
            require(secret.length == length);
            
            uint refund;
            
            for(uint i=0; i< length; i++){
                
                Bid storage bidToCheck = bids[msg.Sender][i];
                (uint value, bool fake, bytes32 secret) = (_values[i], _fake[i], _secret[i]);
            
                if(bidToCheck.blindBid != keccak256(abi.encodePacked(value, fake, secret))){
                    continue;
                }
                
                refund += bidToCheck.deposit;
                
                if(!fake && bidToCheck.deposit >=value){
                    
                    if(placeBid(msg.Sender, value))
                        refund -= value;
                }
                
                bidToCheck.blindBid = bytes32(0);
            }
            
            msg.Sender.transfer(refund);
        }
        
        function placeBid(address bidder, uint value) internal returns (bool success){
            
            if(value <= highestBid){
                return false;
            }
            
            if(highestBidder != address(0)){
                
                pendingReturns[highestBidder] += highestBid;
            
            }
            
            highestBid = value;
            
            highestBidder = bidder;
            
            return true;
            
        }
        
        function withdraw() public {
            
            uint amount = pendingReturns[msg.sender];
            
            if(amount > 0){
                
                pendingReturns[msg.sender] = 0;
                
                msg.sender.transfer(amount);
            }
        }

	 function auctionEnd() 
            public 
            onlyAfter(revealEnd) 
        {
        
            require(!ended);
            
            emit AuctionEnded(highestBidder, highestBid);
            
            ended = true;
            
            beneficiary.transfer(highestBid);
            
        }

}
