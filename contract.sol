import "usingOracalize.it/api.sol";

contract Word is usingOracalize {
    uint public clock;
    address scamionContractAddress;
    mapping (utf8 => uint) public lettersInStock;
	mapping (utf8 => Letter) public letterContracts;
	mapping (utf8 => address) public letterAddresses;
	mapping (uint => string) public orders;
	
	function Word(address _scamionContractAddress) {
	    clock = 0;
	    scamionContractAddress = _scamionContractAddress;
	    for (utf8 letter = 'a'; letter <= 'z'; letter++) {
	        letterContracts[letter] = new Letter(letter, 10, 25, 0.2);
	        lettersInStock[letter] = 0;
	    }
	}
	
	function setLetterAddresses(address[] _letterAddresses) {
	    uint8 c = 0;
	    for (utf8 letter = 'a'; letter <= 'z'; letter++) {
	        letterAddresses[letter] = _letterAddresses[c];
	    }
	}
	
	function __callback() {
	    if (msg.sender != oracalize_cbAddress()) throw;
	}
	
	function tickTime(string _currentWord) {
	    
	    bytes _word = bytes(_currentWord);
	    uint8 t = 0;
	    for (uint8 t = 0; t < _word.length; t++) {
	        _letter = letterContracts[_word[t]];
	        _letter.demand++;
	        order(_letter, 1);
	    }
	    
	    for (utf8 letter = 'a'; letter <= 'z'; letter++) {
	        Letter currentLetter = letterContracts[letter];
	        
	        uint amount_ = letterContracts[letter].querySell(clock);
	        if (amount_ > 0) {
	            Scamions s = Scamions(scamionContractAddress);
	            s.transfer(letter.self, Math.round(amount_ * letter.price));
	        }
	    }
	    
	    clock += 1;
	}
	
	function order(Letter _letter, uint8 _orderSize) {
		if (letter.lettersInProduction + _orderSize < letter.capacity) letter.takeOrder();
	}
}

contract Letter {
    string public symbol;
	uint public productionTime
    uint public demand;
    uint public capacity;
    uint public lettersInProduction;
	ufixed public price;
	uint[] public orderTimestamps;
	mapping (uint => uint8) public numberOfProductsOrdered;
    
    function Letter(string _symbol, uint _productionTime, uint _capacity, ufixed _price) {
        demand = 0;
        lettersInProduction = 0;
        symbol = _symbol;
        productionTime = _productionTime;
        capacity = _capacity;
        price = _price;
    }
    
    function setSpecs(uint _productionTime, uint _capacity, ufixed _price) {
        productionTime = _productionTime;
        capacity = _capacity;
        price = _price;
    }
	
	function takeOrder(uint _currentTime, uint _orderSize) {
	    orderTimestamps.pushback(_currentTime);
	    numberOfProductsOrdered[_currentTime] = _orderSize;
	}
	
	function querySell(uint _time) returns(uint amount_) {
	    if (_time - orderTimestamps[0] > productionTime) {
	        amount_ = numberOfProductsOrdered[orderTimestamps[0]];
	        delete orderTimestamps[0];
	        demand -= amount_;
	    }
	    else {
	        amount_ = 0;
	    }
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
        balanceOf[msg.sender] = initialSupply;              // Give the creator all initial tokens
        totalSupply = initialSupply;                        // Update total supply
        name = tokenName;                                   // Set the name for display purposes
        symbol = tokenSymbol;                               // Set the symbol for display purposes
        decimals = decimalUnits;                            // Amount of decimals for display purposes
    }

    /* Send coins */
    function transfer(address _to, uint256 _value) {
        if (balanceOf[msg.sender] < _value) throw;           // Check if the sender has enough
        if (balanceOf[_to] + _value < balanceOf[_to]) throw; // Check for overflows
        balanceOf[msg.sender] -= _value;                     // Subtract from the sender
        balanceOf[_to] += _value;                            // Add the same to the recipient
        Transfer(msg.sender, _to, _value);                   // Notify anyone listening that this transfer took place
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
        if (balanceOf[_from] < _value) throw;                 // Check if the sender has enough
        if (balanceOf[_to] + _value < balanceOf[_to]) throw;  // Check for overflows
        if (_value > allowance[_from][msg.sender]) throw;   // Check allowance
        balanceOf[_from] -= _value;                          // Subtract from the sender
        balanceOf[_to] += _value;                            // Add the same to the recipient
        allowance[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
    }

    /* This unnamed function is called whenever someone tries to send ether to it */
    function () {
        throw;     // Prevents accidental sending of ether
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
        if(centralMinter != 0 ) owner = msg.sender;         // Sets the minter
        balanceOf[msg.sender] = initialSupply;              // Give the creator all initial tokens
        name = tokenName;                                   // Set the name for display purposes
        symbol = tokenSymbol;                               // Set the symbol for display purposes
        decimals = decimalUnits;                            // Amount of decimals for display purposes
        totalSupply = initialSupply;
    }

    /* Send coins */
    function transfer(address _to, uint256 _value) {
        if (balanceOf[msg.sender] < _value) throw;           // Check if the sender has enough
        if (balanceOf[_to] + _value < balanceOf[_to]) throw; // Check for overflows
        if (frozenAccount[msg.sender]) throw;                // Check if frozen
        balanceOf[msg.sender] -= _value;                     // Subtract from the sender
        balanceOf[_to] += _value;                            // Add the same to the recipient
        Transfer(msg.sender, _to, _value);                   // Notify anyone listening that this transfer took place
    }


    /* A contract attempts to get the coins */
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (frozenAccount[_from]) throw;                        // Check if frozen            
        if (balanceOf[_from] < _value) throw;                 // Check if the sender has enough
        if (balanceOf[_to] + _value < balanceOf[_to]) throw;  // Check for overflows
        if (_value > allowance[_from][msg.sender]) throw;   // Check allowance
        balanceOf[_from] -= _value;                          // Subtract from the sender
        balanceOf[_to] += _value;                            // Add the same to the recipient
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
        uint amount = msg.value / buyPrice;                // calculates the amount
        if (balanceOf[this] < amount) throw;               // checks if it has enough to sell
        balanceOf[msg.sender] += amount;                   // adds the amount to buyer's balance
        balanceOf[this] -= amount;                         // subtracts amount from seller's balance
        Transfer(this, msg.sender, amount);                // execute an event reflecting the change
    }

    function sell(uint256 amount) {
        if (balanceOf[msg.sender] < amount ) throw;        // checks if the sender has enough to sell
        balanceOf[this] += amount;                         // adds the amount to owner's balance
        balanceOf[msg.sender] -= amount;                   // subtracts the amount from seller's balance
        msg.sender.send(amount * sellPrice);               // sends ether to the seller
        Transfer(msg.sender, this, amount);                // executes an event reflecting on the change
    }
}

