App = {
    web3Provider: null,
    contracts: {},

    init: async function() {
        await App.initWeb3();
        return App.initContract();
    },

    initWeb3: function() {
        return new Promise(function(resolve, reject) {
            // Check if Web3 has been injected by the browser (Mist/MetaMask)
            if (typeof web3 !== 'undefined') {
                // Use Mist/MetaMask's provider
                App.web3Provider = web3.currentProvider;
                web3 = new Web3(web3.currentProvider);
                resolve();
            } else {
                // Fallback to localhost if no web3 injection
                App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
                web3 = new Web3(App.web3Provider);
                resolve();
            }
        });
    },

    initContract: function() {
        return new Promise(function(resolve, reject) {
            $.getJSON('product.json', function(data) {
                var productArtifact = data;
                App.contracts.product = TruffleContract(productArtifact);
                App.contracts.product.setProvider(App.web3Provider);
                resolve();
            });
        });
    },

    bindEvents: function() {
        $(document).on('click', '.btn-register', App.registerProduct);
    },

    registerProduct: function(event) {
        event.preventDefault();
        var productInstance;
        var productSN = document.getElementById('productSN').value;
        var consumerCode = document.getElementById('consumerCode').value;
    
        web3.eth.getAccounts(function(error, accounts){
            if(error) {
                console.log(error);
            }
            var account = accounts[0];
    
            App.contracts.product.deployed().then(function(instance){
                productInstance = instance;
                console.log("Input string:", productSN);
                var hexString = web3.utils.asciiToHex(productSN);
                console.log("Input string:", hexString);
                console.log("Input string:", consumerCode);
                var hexStringc = web3.utils.asciiToHex(consumerCode);
                console.log("Input string:", hexStringc);
                return productInstance.sellerSellProduct(
                    
                    web3.utils.asciiToHex(productSN),
                    web3.utils.asciiToHex(consumerCode),
                    {from: account}
                );
             }).then(function(result){
                // Reset form fields
                document.getElementById('productSN').value = '';
                document.getElementById('consumerCode').value = '';
                // Optionally, update UI to reflect registration success
            }).catch(function(err){
                console.log(err.message);
            });
        });
    }
}; // Closing brace for App object

$(function() {
    $(window).load(function() {
        App.init().then(function() {
            App.bindEvents();
        }).catch(function(err) {
            console.log(err);
        });
    });
});
