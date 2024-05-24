pragma solidity ^0.8.12;

contract Product {
    uint256 sellerCount;
    uint256 productCount;

    struct Seller {
        uint256 sellerId;
        bytes32 sellerName;
        bytes32 sellerBrand;
        bytes32 sellerCode;
        uint256 sellerNum;
        bytes32 sellerManager;
        bytes32 sellerAddress;
    }

    mapping(uint => Seller) public sellers;

    struct ProductItem {
        uint256 productId;
        bytes32 productSN;
        bytes32 productName;
        bytes32 productBrand;
        uint256 productPrice;
        uint256 manufacturingDate; // New field
        bytes32 lotBatchNo; // New field
        bytes32 productStatus;
    }

    mapping(uint256 => ProductItem) public productItems;
    mapping(bytes32 => uint256) public productMap;
    mapping(bytes32 => bytes32) public productsManufactured;
    mapping(bytes32 => bytes32) public productsForSale;
    mapping(bytes32 => bytes32) public productsSold;
    mapping(bytes32 => bytes32[]) public productsWithSeller;
    mapping(bytes32 => bytes32[]) public productsWithConsumer;
    mapping(bytes32 => bytes32[]) public sellersWithManufacturer;

    //SELLER SECTION

    function addSeller(bytes32 _manufacturerId, bytes32 _sellerName, bytes32 _sellerBrand, bytes32 _sellerCode,
        uint256 _sellerNum, bytes32 _sellerManager, bytes32 _sellerAddress) public {
        sellers[sellerCount] = Seller(sellerCount, _sellerName, _sellerBrand, _sellerCode,
        _sellerNum, _sellerManager, _sellerAddress);
        sellerCount++;

        sellersWithManufacturer[_manufacturerId].push(_sellerCode);
    }

    function viewSellers() public view returns(uint256[] memory, bytes32[] memory, bytes32[] memory, bytes32[] memory, uint256[] memory, bytes32[] memory, bytes32[] memory) {
        uint256[] memory ids = new uint256[](sellerCount);
        bytes32[] memory snames = new bytes32[](sellerCount);
        bytes32[] memory sbrands = new bytes32[](sellerCount);
        bytes32[] memory scodes = new bytes32[](sellerCount);
        uint256[] memory snums = new uint256[](sellerCount);
        bytes32[] memory smanagers = new bytes32[](sellerCount);
        bytes32[] memory saddress = new bytes32[](sellerCount);
        
        for(uint i = 0; i < sellerCount; i++) {
            ids[i] = sellers[i].sellerId;
            snames[i] = sellers[i].sellerName;
            sbrands[i] = sellers[i].sellerBrand;
            scodes[i] = sellers[i].sellerCode;
            snums[i] = sellers[i].sellerNum;
            smanagers[i] = sellers[i].sellerManager;
            saddress[i] = sellers[i].sellerAddress;
        }
        return (ids, snames, sbrands, scodes, snums, smanagers, saddress);
    }

    //PRODUCT SECTION

    function addProduct(bytes32 _manufacturerID, bytes32 _productName, bytes32 _productSN, bytes32 _productBrand,
        uint256 _productPrice, uint256 _manufacturingDate, bytes32 _lotBatchNo) public {
        productItems[productCount] = ProductItem(productCount, _productSN, _productName, _productBrand,
        _productPrice, _manufacturingDate, _lotBatchNo, "Available");
        productMap[_productSN] = productCount;
        productCount++;
        productsManufactured[_productSN] = _manufacturerID;
    }

    function viewProductItems () public view returns(ProductItem[] memory) {
        ProductItem[] memory products = new ProductItem[](productCount);
        
        for(uint i = 0; i < productCount; i++){
            products[i] = ProductItem(
                productItems[i].productId,
                productItems[i].productSN,
                productItems[i].productName,
                productItems[i].productBrand,
                productItems[i].productPrice,
                productItems[i].manufacturingDate,
                productItems[i].lotBatchNo,
                productItems[i].productStatus
            );
        }
        return products;
    }

    //SELL Product

    function manufacturerSellProduct(bytes32 _productSN, bytes32 _sellerCode) public {
        productsWithSeller[_sellerCode].push(_productSN);
        productsForSale[_productSN] = _sellerCode;
    }

    function sellerSellProduct(bytes32 _productSN, bytes32 _consumerCode) public {   
        bytes32 pStatus;
        uint256 j;

        for(uint256 i = 0; i < productCount; i++) {
            if(productItems[i].productSN == _productSN) {
                j = i;
                break;
            }
        }

        pStatus = productItems[j].productStatus;
        if(pStatus == "Available") {
            productItems[j].productStatus = "NA";
            productsWithConsumer[_consumerCode].push(_productSN);
            productsSold[_productSN] = _consumerCode;
        }
    }

    function queryProductsList(bytes32 _sellerCode) public view returns(uint256[] memory, bytes32[] memory, bytes32[] memory, bytes32[] memory, uint256[] memory, bytes32[] memory){
        bytes32[] memory productSNs = productsWithSeller[_sellerCode];
        uint256 k=0;

        uint256[] memory pids = new uint256[](productCount);
        bytes32[] memory pSNs = new bytes32[](productCount);
        bytes32[] memory pnames = new bytes32[](productCount);
        bytes32[] memory pbrands = new bytes32[](productCount);
        uint256[] memory pprices = new uint256[](productCount);
        bytes32[] memory pstatus = new bytes32[](productCount);

        
        for(uint i=0; i<productCount; i++){
            for(uint j=0; j<productSNs.length; j++){
                if(productItems[i].productSN==productSNs[j]){
                    pids[k] = productItems[i].productId;
                    pSNs[k] = productItems[i].productSN;
                    pnames[k] = productItems[i].productName;
                    pbrands[k] = productItems[i].productBrand;
                    pprices[k] = productItems[i].productPrice;
                    pstatus[k] = productItems[i].productStatus;
                    k++;
                }
            }
        }
        return(pids, pSNs, pnames, pbrands, pprices, pstatus);
    }

    function querySellersList(bytes32 _manufacturerCode) public view returns(uint256[] memory, bytes32[] memory, bytes32[] memory, bytes32[] memory, uint256[] memory, bytes32[] memory, bytes32[] memory) {
        bytes32[] memory sellerCodes = sellersWithManufacturer[_manufacturerCode];
        uint256 k = 0;
        uint256[] memory ids = new uint256[](sellerCount);
        bytes32[] memory snames = new bytes32[](sellerCount);
        bytes32[] memory sbrands = new bytes32[](sellerCount);
        bytes32[] memory scodes = new bytes32[](sellerCount);
        uint256[] memory snums = new uint256[](sellerCount);
        bytes32[] memory smanagers = new bytes32[](sellerCount);
        bytes32[] memory saddress = new bytes32[](sellerCount);
        
        for(uint i = 0; i < sellerCount; i++) {
            for(uint j = 0; j < sellerCodes.length; j++) {
                if(sellers[i].sellerCode == sellerCodes[j]) {
                    ids[k] = sellers[i].sellerId;
                    snames[k] = sellers[i].sellerName;
                    sbrands[k] = sellers[i].sellerBrand;
                    scodes[k] = sellers[i].sellerCode;
                    snums[k] = sellers[i].sellerNum;
                    smanagers[k] = sellers[i].sellerManager;
                    saddress[k] = sellers[i].sellerAddress;
                    k++;
                    break;
                }
            }
        }

        return (ids, snames, sbrands, scodes, snums, smanagers, saddress);
    }

    function getPurchaseHistory(bytes32 _consumerCode) public view returns (bytes32[] memory, bytes32[] memory, bytes32[] memory, uint256[] memory, bytes32[] memory) {
        bytes32[] memory productSNs = productsWithConsumer[_consumerCode];
        bytes32[] memory sellerCodes = new bytes32[](productSNs.length);
        bytes32[] memory manufacturerCodes = new bytes32[](productSNs.length);
        uint256[] memory manufacturingDates = new uint256[](productSNs.length);
        bytes32[] memory lotBatchNos = new bytes32[](productSNs.length);
        
        for(uint i = 0; i < productSNs.length; i++) {
            sellerCodes[i] = productsForSale[productSNs[i]];
            manufacturerCodes[i] = productsManufactured[productSNs[i]];
            uint256 productId = productMap[productSNs[i]];
            manufacturingDates[i] = productItems[productId].manufacturingDate;
            lotBatchNos[i] = productItems[productId].lotBatchNo;
        }
        return (productSNs, sellerCodes, manufacturerCodes, manufacturingDates, lotBatchNos);
    }

    // Verify

    function verifyProduct(bytes32 _productSN, bytes32 _consumerCode) public view returns(bool) {
        return (productsSold[_productSN] == _consumerCode);
    }
}
