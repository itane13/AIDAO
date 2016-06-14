var initialSupply = 1000 /* var of type uint256 here */ ;
var tokenName = "Scamion" /* var of type string here */ ;
var decimalUnits = 0 /* var of type uint8 here */ ;
var tokenSymbol = '$' /* var of type string here */ ;
var scamionsContract = web3.eth.contract([{"constant":true,"inputs":[],"name":"name","outputs":[{"name":"","type":"string"}],"type":"function"},{"constant":true,"inputs":[],"name":"totalSupply","outputs":[{"name":"","type":"uint256"}],"type":"function"},{"constant":false,"inputs":[{"name":"_from","type":"address"},{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transferFrom","outputs":[{"name":"success","type":"bool"}],"type":"function"},{"constant":true,"inputs":[],"name":"decimals","outputs":[{"name":"","type":"uint8"}],"type":"function"},{"constant":true,"inputs":[],"name":"standard","outputs":[{"name":"","type":"string"}],"type":"function"},{"constant":true,"inputs":[{"name":"","type":"address"}],"name":"balanceOf","outputs":[{"name":"","type":"uint256"}],"type":"function"},{"constant":true,"inputs":[],"name":"symbol","outputs":[{"name":"","type":"string"}],"type":"function"},{"constant":false,"inputs":[{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transfer","outputs":[],"type":"function"},{"constant":false,"inputs":[{"name":"_spender","type":"address"},{"name":"_value","type":"uint256"},{"name":"_extraData","type":"bytes"}],"name":"approveAndCall","outputs":[{"name":"success","type":"bool"}],"type":"function"},{"constant":true,"inputs":[{"name":"","type":"address"},{"name":"","type":"address"}],"name":"allowance","outputs":[{"name":"","type":"uint256"}],"type":"function"},{"inputs":[{"name":"initialSupply","type":"uint256"},{"name":"tokenName","type":"string"},{"name":"decimalUnits","type":"uint8"},{"name":"tokenSymbol","type":"string"}],"type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"name":"from","type":"address"},{"indexed":true,"name":"to","type":"address"},{"indexed":false,"name":"value","type":"uint256"}],"name":"Transfer","type":"event"}]);
var scamions = scamionsContract.new(
   initialSupply,
   tokenName,
   decimalUnits,
   tokenSymbol,
   {
     from: web3.eth.accounts[0], 
     data: '6060604052604060405190810160405280600981526020017f546f6b656e20302e31000000000000000000000000000000000000000000000081526020015060006000509080519060200190828054600181600116156101000203166002900490600052602060002090601f016020900481019282601f1061008c57805160ff19168380011785556100bd565b828001600101855582156100bd579182015b828111156100bc57825182600050559160200191906001019061009e565b5b5090506100e891906100ca565b808211156100e457600081815060009055506001016100ca565b5090565b5050604051610e3e380380610e3e833981016040528080519060200190919080518201919060200180519060200190919080518201919060200150505b83600560005060003373ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060005081905550836004600050819055508260016000509080519060200190828054600181600116156101000203166002900490600052602060002090601f016020900481019282601f106101b257805160ff19168380011785556101e3565b828001600101855582156101e3579182015b828111156101e25782518260005055916020019190600101906101c4565b5b50905061020e91906101f0565b8082111561020a57600081815060009055506001016101f0565b5090565b50508060026000509080519060200190828054600181600116156101000203166002900490600052602060002090601f016020900481019282601f1061025f57805160ff1916838001178555610290565b82800160010185558215610290579182015b8281111561028f578251826000505591602001919060010190610271565b5b5090506102bb919061029d565b808211156102b7576000818150600090555060010161029d565b5090565b505081600360006101000a81548160ff021916908302179055505b50505050610b56806102e86000396000f3606060405236156100a0576000357c01000000000000000000000000000000000000000000000000000000009004806306fdde03146100ad57806318160ddd1461012857806323b872dd1461014b578063313ce5671461018b5780635a3b7e42146101b157806370a082311461022c57806395d89b4114610258578063a9059cbb146102d3578063cae9ca51146102f4578063dd62ed3e14610372576100a0565b6100ab5b610002565b565b005b6100ba60048050506103a7565b60405180806020018281038252838181518152602001915080519060200190808383829060006004602084601f0104600f02600301f150905090810190601f16801561011a5780820380516001836020036101000a031916815260200191505b509250505060405180910390f35b6101356004805050610448565b6040518082815260200191505060405180910390f35b6101736004808035906020019091908035906020019091908035906020019091905050610451565b60405180821515815260200191505060405180910390f35b61019860048050506106b5565b604051808260ff16815260200191505060405180910390f35b6101be60048050506106c8565b60405180806020018281038252838181518152602001915080519060200190808383829060006004602084601f0104600f02600301f150905090810190601f16801561021e5780820380516001836020036101000a031916815260200191505b509250505060405180910390f35b6102426004808035906020019091905050610769565b6040518082815260200191505060405180910390f35b6102656004805050610784565b60405180806020018281038252838181518152602001915080519060200190808383829060006004602084601f0104600f02600301f150905090810190601f1680156102c55780820380516001836020036101000a031916815260200191505b509250505060405180910390f35b6102f26004808035906020019091908035906020019091905050610825565b005b61035a6004808035906020019091908035906020019091908035906020019082018035906020019191908080601f0160208091040260200160405190810160405280939291908181526020018383808284378201915050505050509090919050506109b0565b60405180821515815260200191505060405180910390f35b6103916004808035906020019091908035906020019091905050610b2b565b6040518082815260200191505060405180910390f35b60016000508054600181600116156101000203166002900480601f0160208091040260200160405190810160405280929190818152602001828054600181600116156101000203166002900480156104405780601f1061041557610100808354040283529160200191610440565b820191906000526020600020905b81548152906001019060200180831161042357829003601f168201915b505050505081565b60046000505481565b600081600560005060008673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060005054101561048f57610002565b600560005060008473ffffffffffffffffffffffffffffffffffffffff1681526020019081526020016000206000505482600560005060008673ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020600050540110156104fc57610002565b600660005060008573ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060005060003373ffffffffffffffffffffffffffffffffffffffff1681526020019081526020016000206000505482111561056257610002565b81600560005060008673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008282825054039250508190555081600560005060008573ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008282825054019250508190555081600660005060008673ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060005060003373ffffffffffffffffffffffffffffffffffffffff1681526020019081526020016000206000828282505403925050819055508273ffffffffffffffffffffffffffffffffffffffff168473ffffffffffffffffffffffffffffffffffffffff167fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef846040518082815260200191505060405180910390a3600190506106ae565b9392505050565b600360009054906101000a900460ff1681565b60006000508054600181600116156101000203166002900480601f0160208091040260200160405190810160405280929190818152602001828054600181600116156101000203166002900480156107615780601f1061073657610100808354040283529160200191610761565b820191906000526020600020905b81548152906001019060200180831161074457829003601f168201915b505050505081565b60056000506020528060005260406000206000915090505481565b60026000508054600181600116156101000203166002900480601f01602080910402602001604051908101604052809291908181526020018280546001816001161561010002031660029004801561081d5780601f106107f25761010080835404028352916020019161081d565b820191906000526020600020905b81548152906001019060200180831161080057829003601f168201915b505050505081565b80600560005060003373ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060005054101561086157610002565b600560005060008373ffffffffffffffffffffffffffffffffffffffff1681526020019081526020016000206000505481600560005060008573ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020600050540110156108ce57610002565b80600560005060003373ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060008282825054039250508190555080600560005060008473ffffffffffffffffffffffffffffffffffffffff1681526020019081526020016000206000828282505401925050819055508173ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff167fddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef836040518082815260200191505060405180910390a35b5050565b6000600083600660005060003373ffffffffffffffffffffffffffffffffffffffff16815260200190815260200160002060005060008773ffffffffffffffffffffffffffffffffffffffff168152602001908152602001600020600050819055508490508073ffffffffffffffffffffffffffffffffffffffff16638f4ffcb133863087604051857c0100000000000000000000000000000000000000000000000000000000028152600401808573ffffffffffffffffffffffffffffffffffffffff1681526020018481526020018373ffffffffffffffffffffffffffffffffffffffff168152602001806020018281038252838181518152602001915080519060200190808383829060006004602084601f0104600f02600301f150905090810190601f168015610af85780820380516001836020036101000a031916815260200191505b50955050505050506000604051808303816000876161da5a03f1156100025750505060019150610b23565b509392505050565b600660005060205281600052604060002060005060205280600052604060002060009150915050548156', 
     gas: 3000000
   }, function (e, contract){
    console.log(e, contract);
    if (typeof contract.address !== 'undefined') {
         console.log('Contract mined! address: ' + contract.address + ' transactionHash: ' + contract.transactionHash);
    }
 })
