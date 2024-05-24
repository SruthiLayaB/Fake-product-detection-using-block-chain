App = {
    web3Provider: null,
    contracts: {},

    init: async function() {
        await App.initWeb3(); // Using await here
        App.initContract(); // Removing return statement
        App.bindEvents();
    },

    initWeb3: async function() { // Making initWeb3 async
        if(window.ethereum) { // Using window.ethereum
            App.web3Provider = window.ethereum;
            try {
                // Request account access
                await window.ethereum.enable();
            } catch (error) {
                // User denied account access...
                console.error("User denied account access");
            }
        } else if (window.web3) {
            App.web3Provider = window.web3.currentProvider;
        } else {
            App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
        }

        web3 = new Web3(App.web3Provider);
    },

    initContract: function() {
        $.getJSON('product.json', function(data){
            var productArtifact = data;
            App.contracts.product = TruffleContract(productArtifact);
            App.contracts.product.setProvider(App.web3Provider);
        });
    },

    bindEvents: function() {
        $(document).on('click', '.btn-register', App.registerProduct);
    },

    registerProduct: function(event) {
        event.preventDefault();
        var productInstance;
        var manufacturerID = document.getElementById('manufacturerID').value;
        var productName = document.getElementById('productName').value;
        var productSN = document.getElementById('productSN').value;
        var productBrand = document.getElementById('productBrand').value;
        var productPrice = document.getElementById('productPrice').value;
        var manufacturingDate = document.getElementById('manufacturingDate').value;
        var lotBatchNo = document.getElementById('lotBatchNo').value;
        var qualityCheckCompleted = document.getElementById('qualityCheckCompleted').checked ? 1 : 0; // Convert to appropriate type

        web3.eth.getAccounts(function(error, accounts){
            if(error) {
                console.log(error);
            }
            var account = accounts[0];

            App.contracts.product.deployed().then(function(instance){
                productInstance = instance;
                return productInstance.addProduct(
                    web3.utils.asciiToHex(manufacturerID),
                    web3.utils.asciiToHex(productName),
                    web3.utils.asciiToHex(productSN),
                    web3.utils.asciiToHex(productBrand),
                    web3.utils.asciiToHex(productPrice),
                    web3.utils.asciiToHex(manufacturingDate),
                    web3.utils.asciiToHex(lotBatchNo),
                    
                    {from: account}
                );
             }).then(function(result){
                // Reset form fields
                document.getElementById('manufacturerID').value = '';
                document.getElementById('productName').value = '';
                document.getElementById('productSN').value = '';
                document.getElementById('productBrand').value = '';
                document.getElementById('productPrice').value = '';
                document.getElementById('manufacturingDate').value = '';
                document.getElementById('lotBatchNo').value = '';
                document.getElementById('qualityCheckCompleted').checked = false;
            }).catch(function(err){
                console.log(err.message);
            });
        });
    }
};

$(function() {
    $(window).on('load', function() { // Using .on('load') instead of .load()
        App.init();
    })
});
