contract Word {

    uint public clock;                                      /* Keeps track of current time. */
    address scamionContractAddress;                         /* Address of the scamion contract. */
    Economy wordMarket;                                     /* A representation of the market. */
    
    struct Order {
        bytes uniqueLetters;
        uint8[] amounts;
    }
    
    uint[] public orderTimestamps;                          /* Stack of times an order was placed. */
    mapping (byte => uint8) public lettersInStock;          /* Current letters in stock ready to sell. */
	mapping (byte => Letter) public letterContracts;        /* Reference list of all 26 letter contracts. */
	mapping (uint => Order) public orders;                  /* Mapping of timestamps to the word ordered at that time. */
	
	function Word(address _scamionContractAddress) {
	    clock = 0;
	    scamionContractAddress = _scamionContractAddress;
	    wordMarket = new Economy(scamionContractAddress);
	    /* Initialize all letter contracts */
	    for (uint8 l = 65; l <= 122; l++) {
	        letterContracts[byte(l)] = new Letter(byte(l), scamionContractAddress, 10, 25);
	        lettersInStock[byte(l)] = 0;
	    }
	}
	
	function shipWord(bytes _uniqueLetters, uint8[] _amounts) {
	    for (uint8 t = 0; t < _uniqueLetters.length; t++) {
	        Letter _letter = letterContracts[_uniqueLetters[t]];
	        lettersInStock[_letter.getSymbol()] -= _amounts[t];
	    }
	}
	
	/* requests letters of certain amount */
	function order(Letter _letter, uint8 _orderSize) {
	    var cost_ = _letter.takeOrder(clock, _orderSize);
	    Scamions s = Scamions(scamionContractAddress);
	    s.transfer(_letter, cost_);
	}
	
	/* tickTime is run at each time step, places new order and checks if previous
	orders have been fulfilled before incrementing time. Inputs are a list of unique
	letters in the current word, along with their number of instances in the same order */
	function tickTime(bytes _uniqueLetters, uint8[] _amounts) {
	    
	    /* First check if any previous letter orders are ready to be shipped to the word contract. */
	    for (uint8 l = 65; l <= 122; l++) {
	        letterContracts[byte(l)].queryShip(clock);
	    }
	    
	    /* Then take care of current order. */
	    uint _valueOfWord = 0;                                                      /* Price of the incoming order to be payed at order time. */
	    var _readyToShip = true;                                                    /* Check to see if incoming word is already in stack. */
	    for (uint8 t = 0; t < _uniqueLetters.length; t++) {
	        _valueOfWord += letterContracts[byte(t)].getDemand() * _amounts[t];     /* Increment price according to current demand of letter. */
	        var _amountToOrder = _amounts[t] - lettersInStock[_uniqueLetters[t]];   /* See how many additional letters must be ordered. */
	        if (_amountToOrder > 0) {                                               /* Place order if needed. */
	            _readyToShip = false;                                               /* In which case order is not ready for shipment. */
	            Letter _letter = letterContracts[_uniqueLetters[t]];
	            order(_letter, _amountToOrder);
	            _letter.incrementDemand(uint(_amountToOrder));                      /* Increment the demand. */
	            
	        }
	    }
	    wordMarket.payForWord(msg.sender, _valueOfWord);                            /* The word is paid for. */
	    if (_readyToShip) {
	        shipWord(_uniqueLetters, _amounts);                                     /* And shipped if possible. */
	    }
	    else {                                                                      /* Otherwise order is stored to be checked again later. */
	        Order memory newOrder = Order({uniqueLetters: _uniqueLetters, amounts: _amounts});
	        orders[clock] = newOrder;
	        orderTimestamps.push(clock);
	    }
	    
	    /* Now see if any previous orders can be shipped. */
	    uint[] memory tempOrderTimestamps = new uint[](orderTimestamps.length);     /* Maintain the orders that still aren't met. */
	    uint8 k = 0;
	    for (uint8 i = 0; i < orderTimestamps.length; i++) {                        /* Iterate through all the timestamps of remaining orders. */
	        _readyToShip = true;                                                    /* Use  a flag to see if all the needed letters are present. */
	        Order order_ = orders[orderTimestamps[i]];                              /* Get one of the orders. */
	        for (uint8 j = 0; j < order_.amounts.length; j++) {                     /* Loop through the letters needed for this order. */
	            if (lettersInStock[order_.uniqueLetters[j]] < order_.amounts[j]) {  /* Check and see if we have enough letters in stock. */
	                _readyToShip = false;                                           /* If not, then cancel shipping. */
	                break;
	            }
	        }
	        if (_readyToShip) {
	            shipWord(order_.uniqueLetters, order_.amounts);                     /* Ship word if it passed the test. */
	            delete orders[orderTimestamps[i]];                                  /* Delete its corresponding order. */
	        }
	        else {
	            tempOrderTimestamps[k] = orderTimestamps[i];                        /* Otherwise, copy order time into new list for future indexing. */
	            k++;
	        }
	    }
	    orderTimestamps = tempOrderTimestamps;
	    
	    /* Send some money back into the economy. */
	    for (l = 65; l <= 122; l++) {
	        letterContracts[byte(l)].payBackToEconomy(wordMarket);
	    }
	    
	    clock++;
}

}

contract Letter {
    byte public symbol;
    address scamionContractAddress;
	uint public productionTime;                                 /* Time it takes to produce an order */
    uint public demand;                                         /* Current demand of product */
    uint public capacity;                                       /* The production capacity, how many products can be produced at once */
    uint public lettersInProduction;                            /* How many letters are currently in production */
    
	uint[] public orderTimestamps;                              /* Stack of times an order was placed */
	
	mapping (uint => uint8) public numberOfProductsOrdered;     /* Mapping from order timestamps to number of products requested */
    
    function Letter(
        byte _symbol,
        address _scamionContractAddress,
        uint _productionTime,
        uint _capacity
        ) {
        demand = 0;
        lettersInProduction = 0;
        scamionContractAddress = _scamionContractAddress;
        symbol = _symbol;
        productionTime = _productionTime;
        capacity = _capacity;
    }
    
    function getDemand() returns(uint a) {
        return demand;
    }
    
    function getSymbol() returns(byte s) {
        return symbol;
    }
   
    function setSpecs(uint _productionTime, uint _capacity) {
        productionTime = _productionTime;
        capacity = _capacity;
    }
	
    /* insert an order of specific ammount to the production queue if possible 	*/                                                                   
	function takeOrder(uint _currentTime, uint8 _orderSize) returns(uint8 amountOrdered) {                    
	    if (lettersInProduction != capacity) {                                    /* check if production 'slots' are full */
	        orderTimestamps.push(_currentTime);  
	        if (lettersInProduction + _orderSize < capacity) {                    /* order all requested */
	            numberOfProductsOrdered[_currentTime] = _orderSize;             /* associate order with timestamp */
	            return _orderSize;
	        }
	        else {                                                            /* order as much as the remaining space allows */
	            numberOfProductsOrdered[_currentTime] = uint8(capacity - lettersInProduction); /* associate order with timestamp */
	            return uint8(capacity - lettersInProduction);
	        }
	    }
	    return 0;
	}
	
	function queryShip(uint _time) {
	    if (_time - orderTimestamps[0] > productionTime) {
	        uint[] memory _tempOrderTimestamps = new uint[](orderTimestamps.length - 1);
	        for (uint i = 1; i < orderTimestamps.length; i++) {
	            _tempOrderTimestamps[i - 1] = orderTimestamps[i];
	        }
	        delete orderTimestamps;
	        orderTimestamps = _tempOrderTimestamps;
	        demand -= numberOfProductsOrdered[orderTimestamps[0]];
	    }
	}
	
	function payBackToEconomy(address _economy) {
	    Scamions s = Scamions(scamionContractAddress);
	    s.transfer(_economy, demand);
	}
	
	function incrementDemand(uint amount) {
	    demand += amount;
	}
	
}

/* This contract plays the economy buy paying for words and getting paid by letter companies because that's how it works. */
contract Economy {
    address scamionContractAddress; /* Address of the scamion contract */
    
    function Economy(address _scamionContractAddress) {
        scamionContractAddress = _scamionContractAddress;
    }
    
    function payForWord(address seller, uint _cost) {
        Scamions s = Scamions(scamionContractAddress);
        s.transfer(seller, _cost);
    }
}

contract owned {
    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _
    }

    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
}

contract tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData); }

contract token {
    /* Public variables of the token */
    string public standard = 'Scamion';
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    /* This generates a public event on the blockchain that will notify clients */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function token(
        uint256 initialSupply,
        string tokenName,
        uint8 decimalUnits,
        string tokenSymbol
        ) {
        balanceOf[msg.sender] = initialSupply;              /* Give the creator all initial tokens */
        totalSupply = initialSupply;                        /* Update total supply */
        name = tokenName;                                   /* Set the name for display purposes */
        symbol = tokenSymbol;                               /* Set the symbol for display purposes */
        decimals = decimalUnits;                            /* Amount of decimals for display purposes */
    }

    /* Send coins */
    function transfer(address _to, uint256 _value) {
        if (balanceOf[msg.sender] < _value) throw;           /* Check if the sender has enough */
        if (balanceOf[_to] + _value < balanceOf[_to]) throw; /* Check for overflows */
        balanceOf[msg.sender] -= _value;                     /* Subtract from the sender */
        balanceOf[_to] += _value;                            /* Add the same to the recipient */
        Transfer(msg.sender, _to, _value);                   /* Notify anyone listening that this transfer took place */
    }

    /* Allow another contract to spend some tokens in your behalf */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData)
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        tokenRecipient spender = tokenRecipient(_spender);
        spender.receiveApproval(msg.sender, _value, this, _extraData);
        return true;
    }

    /* A contract attempts to get the coins */
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (balanceOf[_from] < _value) throw;                 /* Check if the sender has enough */
        if (balanceOf[_to] + _value < balanceOf[_to]) throw;  /* Check for overflows */
        if (_value > allowance[_from][msg.sender]) throw;     /* Check allowance */
        balanceOf[_from] -= _value;                           /* Subtract from the sender */
        balanceOf[_to] += _value;                             /* Add the same to the recipient */
        allowance[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
    }

    /* This unnamed function is called whenever someone tries to send ether to it */
    function () {
        throw;     /* Prevents accidental sending of ether */
    }
}

contract Scamions is owned, token {

    uint256 public sellPrice;
    uint256 public buyPrice;
    uint256 public totalSupply;

    mapping (address => bool) public frozenAccount;

    /* This generates a public event on the blockchain that will notify clients */
    event FrozenFunds(address target, bool frozen);

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function Scamions(
        uint256 initialSupply,
        string tokenName,
        uint8 decimalUnits,
        string tokenSymbol,
        address centralMinter
    ) {
        if(centralMinter != 0 ) owner = msg.sender;         /* Sets the minter */
        balanceOf[msg.sender] = initialSupply;              /* Give the creator all initial tokens */
        name = tokenName;                                   /* Set the name for display purposes */
        symbol = tokenSymbol;                               /* Set the symbol for display purposes */
        decimals = decimalUnits;                            /* Amount of decimals for display purposes */
        totalSupply = initialSupply;
    }

    /* Send coins */
    function transfer(address _to, uint256 _value) {
        if (balanceOf[msg.sender] < _value) throw;           /* Check if the sender has enough */
        if (balanceOf[_to] + _value < balanceOf[_to]) throw; /* Check for overflows */
        if (frozenAccount[msg.sender]) throw;                /* Check if frozen */
        balanceOf[msg.sender] -= _value;                     /* Subtract from the sender */
        balanceOf[_to] += _value;                            /* Add the same to the recipient */
        Transfer(msg.sender, _to, _value);                   /* Notify anyone listening that this transfer took place */
    }


    /* A contract attempts to get the coins */
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (frozenAccount[_from]) throw;                        /* Check if frozen */         
        if (balanceOf[_from] < _value) throw;                 /* Check if the sender has enough */
        if (balanceOf[_to] + _value < balanceOf[_to]) throw;  /* Check for overflows */
        if (_value > allowance[_from][msg.sender]) throw;   /* Check allowance */
        balanceOf[_from] -= _value;                          /* Subtract from the sender */
        balanceOf[_to] += _value;                            /* Add the same to the recipient */
        allowance[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
    }

    function mintToken(address target, uint256 mintedAmount) onlyOwner {
        balanceOf[target] += mintedAmount;
        totalSupply += mintedAmount;
        Transfer(0, owner, mintedAmount);
        Transfer(owner, target, mintedAmount);
    }

    function freezeAccount(address target, bool freeze) onlyOwner {
        frozenAccount[target] = freeze;
        FrozenFunds(target, freeze);
    }

    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner {
        sellPrice = newSellPrice;
        buyPrice = newBuyPrice;
    }

    function buy() {
        uint amount = msg.value / buyPrice;                /* calculates the amount */
        if (balanceOf[this] < amount) throw;               /* checks if it has enough to sell */
        balanceOf[msg.sender] += amount;                   /* adds the amount to buyer's balance */
        balanceOf[this] -= amount;                         /* subtracts amount from seller's balance */
        Transfer(this, msg.sender, amount);                /* execute an event reflecting the change */
    }

    function sell(uint256 amount) {
        if (balanceOf[msg.sender] < amount ) throw;        /* checks if the sender has enough to sell */
        balanceOf[this] += amount;                         /* adds the amount to owner's balance */
        balanceOf[msg.sender] -= amount;                   /* subtracts the amount from seller's balance */
        msg.sender.send(amount * sellPrice);               /* sends ether to the seller */
        Transfer(msg.sender, this, amount);                /* executes an event reflecting on the change */
    }
}

