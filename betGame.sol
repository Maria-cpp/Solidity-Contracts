pragma solidity ^0.4.2;
pragma experimental ABIEncoderV2; // enables ABI encoder ABEncoderV2


// ----------------------------------------------------------------------------
// 'Guess' token contract
//
// Deployed to  : 0x905c83B33C45ad8663eBD5922AcD47D5E4fdC75F
// Symbol       : "GUESS"
// Name         : "GUESS"
// CashPrize : 100,000
// Decimals     : 
// ----------------------------------------------------------------------------


contract GAME {
    string internal symbol;
    string internal name;
    uint internal _totalSupply;
    uint count1=0;
    uint count2=0;
    address owner;
    
    string[] wordsArr=["alpha", "bravo"];

    string[] names;

    struct Player {
        string name;
        address _address;
        string choice;
    }
   
   // Address of the player and => the user info   
    mapping(uint => Player) team1; 
    mapping(uint => Player) team2; 

    
    
    event Transfer(address indexed from, address indexed to, uint _amount);
    
    constructor() public {
        symbol = "GUESS";
        name = "GUESS";
        _totalSupply = 0;
        owner= 0x4d22cCA90Af1af1663eF404e7BcEfEf4E61d0B95;
    }

    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }

    function transferBetAmount(uint _amount) public  {
        emit Transfer(msg.sender, owner , _amount);
        _totalSupply +=_amount;
    }
    
    
    // each player will provide details to participate in game [name, address, choice]
    function playerData(Player _player) public {
        //strings can't be compared directly so comparing using hash function
        if (keccak256(abi.encodePacked(_player.choice)) == keccak256(abi.encodePacked("alpha"))) {
            count1+=1;
            team1[count1]= _player;
        }
        else{
            count2+=1;
            team2[count2]=_player;
        }
        names.push(_player.name);

    }
    
    //to get the name of all players
    
    function getAllPlayersNames() public view returns (string[]){
        return names;
    }
    
    
    // wordlists for user to choose for bet
    function wordslist() public view returns (string[]){
            return wordsArr;
    }
    
    
    // this function will calculate the owners part and
    // returns the amount share for each player

    function cashPrize(uint count) internal returns(uint) {
        uint fee = _totalSupply*10/100;
        emit Transfer(address(0), owner, fee);
        _totalSupply-=fee;
        uint individualCashPrize = _totalSupply/count;
        return individualCashPrize;
    }
    
    // Intializing the state variable
    uint randNonce = 0;
      
    //function to generate
    // a random number
    function randMod() internal returns(uint) 
    {
       // increase nonce
       randNonce++;  
       return uint(keccak256(abi.encodePacked(now, msg.sender, randNonce))) % 100;
    }
    
    
    
    //this function will use to get word randomly from word list 
    //and then the cash amount will be transferred to all the players of the wining team 
    
    function Get_Result() external returns (string memory result){
        uint rand = randMod();// hardcoded for now i will change it from random number
        rand = rand % 2;
        uint prize;
        uint i;
        Player storage player;
        if (rand==0) {
            prize = cashPrize(count1);
            for( i =0; i< count1; i++)
            {
                player = team1[i]; 
                emit Transfer(owner, player._address, prize);
                _totalSupply-=prize;
            }
            //word bravo and team2
        return "Congratulations alpha team you won the GAME your cash Prize is transferred";
        }
        else{
             prize = cashPrize(count2);
            for( i =0; i< count2; i++)
            {
                player = team2[i]; 
                emit Transfer(owner, player._address, prize);
                _totalSupply-=prize;
            }
            //word b
            //word alpha and team1
        return "Congratulations bravo team you won the GAME your cash Prize is transferred";
        }
    }
    
}
