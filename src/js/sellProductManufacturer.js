App = {

    web3Provider: null,
    contracts: {},

    init: async function() {
        return await App.initWeb3();
    },

    initWeb3: function() {
        if(window.web3) {
            App.web3Provider = window.web3.currentProvider;
        } else {
            App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
        }

        web3 = new Web3(App.web3Provider);
        return App.initContract();
    },

    initContract: function() {
        $.getJSON('product.json', function(data){
            var productArtifact = data;
            App.contracts.product = TruffleContract(productArtifact);
            App.contracts.product.setProvider(App.web3Provider);
        });

        return App.bindEvents();
    },

    bindEvents: function() {
        $(document).on('click', '.btn-register', App.registerProduct);
    },

    registerProduct: function(event) {
        event.preventDefault();
        var productInstance;
        var productSN = document.getElementById('productSN').value;
        var sellerCode = document.getElementById('sellerCode').value;
        var sellingDate = document.getElementById('sellingDate').value;
        var verifiedSeller = document.getElementById('verifiedSeller').value;

        web3.eth.getAccounts(function(error, accounts){
            if(error) {
                console.log(error);
            }
            var account = accounts[0];
            console.log(account);
            App.contracts.product.deployed().then(function(instance){
                productInstance = instance;
                return productInstance.manufacturerSellProduct(
                    web3.utils.asciiToHex(productSN),
                    web3.utils.asciiToHex(sellerCode),
                    { from: account }
                );
            }).then(function(result){
                // Reset form fields
                document.getElementById('productSN').value = '';
                document.getElementById('sellerCode').value = '';
                window.location.reload(); // Refresh page
            }).catch(function(err){
                console.log(err.message);
            });
            
        });
    }
};

$(function() {
    $(window).load(function() {
        App.init();
    })
});
