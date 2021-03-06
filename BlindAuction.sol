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
    
    mapping(address => Bid[]) public bids;
    
    address public highestBidder;
    
    uint public highestBid;
    
    mapping(address => uint) pendingReturns;
    
    event auctionEnded(address winner, uint highestBid);
    
    modifier onlyBefore(uint _time) { require(now < _time); _; }
    
    modifier onlyAfter(uint _time) { require(now > _time); _; }

    
    constructor(
         uint _biddingTime,
         
         uint _revealTime,
         
         address payable _beneficiary;
        
        ) public {
            
            benficiary = _beneficiary;
            biddingEnd = now + _biddingTime;
            revealEnd = biddingEnd + _revealTime;
        }
        
  function generateBlindedBidBytes32(uint value, bool fake) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(value, fake));
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
        
        bool[] memory _fake,
              
        )
        
        public
        
        onlyAfter(biddingEnd)
        
        onlyBefore(revealEnd)
        
        {
            uint length = bids[msg.sender].length;
            
            require (_values.length == length);
            
            require(_fake.length == length);
                               
            for(uint i=0; i< length; i++){
                
                Bid storage bidToCheck = bids[msg.sender][i];
                (uint value, bool fake) = (_values[i], _fake[i]);
            
                if(bidToCheck.blindBid != keccak256(abi.encodePacked(value, fake))){
                    continue;
                }
                     
                if(!fake && bidToCheck.deposit >=value){
                    
                    if!(placeBid(msg.Sender, value)){
                        msg.sender.transfer(bidToCheck.deposit);
			}
                }
                
                bidToCheck.blindBid = bytes32(0);
            }
            
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
            
            emit auctionEnded(highestBidder, highestBid);
            
            ended = true;
            
            benficiary.transfer(highestBid);
            
        }

}
