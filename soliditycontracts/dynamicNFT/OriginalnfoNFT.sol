// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


// Openzeppelin Contracts
import "@openzeppelin/contracts@4.6.0/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts@4.6.0/utils/Counters.sol";

// Chainlink Automation 
import "@chainlink/contracts/src/v0.8/AutomationCompatible.sol";


contract CocoaPlantation is ERC721, ERC721URIStorage, AutomationCompatibleInterface{
    using Counters for Counters.Counter;

    Counters.Counter public tokenIdCounter;


    uint256[] private tokenIds;
    mapping(uint256=> bool) private Exist;
    mapping(uint256 => bool) private availableTokenId;
    mapping(uint8 => uint8[]) internal conditons;
    mapping(string => uint8) private farmstate;

    // Authorization related mappings
    mapping(address => bool) private authorize;



    string[] IpfsUri = [
        "https://peach-defeated-sawfish-855.mypinata.cloud/ipfs/QmbYuVsy7iYHqw4nyhToDdrHhN3CDtXnSHYv7GmL1fhFMy/seedlingstage1_cloudy.json",
        "https://peach-defeated-sawfish-855.mypinata.cloud/ipfs/QmbYuVsy7iYHqw4nyhToDdrHhN3CDtXnSHYv7GmL1fhFMy/seedlingstage1_fire.json",
        "https://peach-defeated-sawfish-855.mypinata.cloud/ipfs/QmbYuVsy7iYHqw4nyhToDdrHhN3CDtXnSHYv7GmL1fhFMy/seedlingstage1_pestrodent.json",
        "https://peach-defeated-sawfish-855.mypinata.cloud/ipfs/QmbYuVsy7iYHqw4nyhToDdrHhN3CDtXnSHYv7GmL1fhFMy/seedlingstage1_rain.json",
        "https://peach-defeated-sawfish-855.mypinata.cloud/ipfs/QmbYuVsy7iYHqw4nyhToDdrHhN3CDtXnSHYv7GmL1fhFMy/seedlingstage1_stormy.json",
        "https://peach-defeated-sawfish-855.mypinata.cloud/ipfs/QmbYuVsy7iYHqw4nyhToDdrHhN3CDtXnSHYv7GmL1fhFMy/seedlingstage1_sunny.json",
        "https://peach-defeated-sawfish-855.mypinata.cloud/ipfs/QmbYuVsy7iYHqw4nyhToDdrHhN3CDtXnSHYv7GmL1fhFMy/seedlingstage1_windy.json",
        "https://peach-defeated-sawfish-855.mypinata.cloud/ipfs/QmSPdvRg58U8chige1TgFpX1cJC6wPD7o96ktZspA9sTz9/growingstage_cloudy.json",
        "https://peach-defeated-sawfish-855.mypinata.cloud/ipfs/QmSPdvRg58U8chige1TgFpX1cJC6wPD7o96ktZspA9sTz9/growingstage_fire.json",
        "https://peach-defeated-sawfish-855.mypinata.cloud/ipfs/QmSPdvRg58U8chige1TgFpX1cJC6wPD7o96ktZspA9sTz9/growingstage_pest.json",
        "https://peach-defeated-sawfish-855.mypinata.cloud/ipfs/QmSPdvRg58U8chige1TgFpX1cJC6wPD7o96ktZspA9sTz9/growingstage_rainy.json",
        "https://peach-defeated-sawfish-855.mypinata.cloud/ipfs/QmSPdvRg58U8chige1TgFpX1cJC6wPD7o96ktZspA9sTz9/growingstage_stormy.json",
        "https://peach-defeated-sawfish-855.mypinata.cloud/ipfs/QmSPdvRg58U8chige1TgFpX1cJC6wPD7o96ktZspA9sTz9/growingstage_sunny.json",
        "https://peach-defeated-sawfish-855.mypinata.cloud/ipfs/QmSPdvRg58U8chige1TgFpX1cJC6wPD7o96ktZspA9sTz9/growingstage_windy.json",
        "https://peach-defeated-sawfish-855.mypinata.cloud/ipfs/Qmc4zTHu6St3g3nQRRFHAdNdwNHdJmEJPojzAVsCJTzpYy/maturedcocoa_cloudy.json",
        "https://peach-defeated-sawfish-855.mypinata.cloud/ipfs/Qmc4zTHu6St3g3nQRRFHAdNdwNHdJmEJPojzAVsCJTzpYy/maturedcocoa_fire.json",
        "https://peach-defeated-sawfish-855.mypinata.cloud/ipfs/Qmc4zTHu6St3g3nQRRFHAdNdwNHdJmEJPojzAVsCJTzpYy/maturedcocoa_pest.json",
        "https://peach-defeated-sawfish-855.mypinata.cloud/ipfs/Qmc4zTHu6St3g3nQRRFHAdNdwNHdJmEJPojzAVsCJTzpYy/maturedcocoa_rain.json",
        "https://peach-defeated-sawfish-855.mypinata.cloud/ipfs/Qmc4zTHu6St3g3nQRRFHAdNdwNHdJmEJPojzAVsCJTzpYy/maturedcocoa_stormy.json",
        "https://peach-defeated-sawfish-855.mypinata.cloud/ipfs/Qmc4zTHu6St3g3nQRRFHAdNdwNHdJmEJPojzAVsCJTzpYy/maturedcocoa_sunny.json",
        "https://peach-defeated-sawfish-855.mypinata.cloud/ipfs/Qmc4zTHu6St3g3nQRRFHAdNdwNHdJmEJPojzAVsCJTzpYy/maturedcocoa_windy.json",
        "https://peach-defeated-sawfish-855.mypinata.cloud/ipfs/QmemzFFHNbwNQGGvJrDP5nvTjwSeh3Tspd5xqLwtXjEcSd/lowestyield.json",
        "https://peach-defeated-sawfish-855.mypinata.cloud/ipfs/QmemzFFHNbwNQGGvJrDP5nvTjwSeh3Tspd5xqLwtXjEcSd/mediumyield.json",
        "https://peach-defeated-sawfish-855.mypinata.cloud/ipfs/QmemzFFHNbwNQGGvJrDP5nvTjwSeh3Tspd5xqLwtXjEcSd/highestyield.json"
        ];


    uint public interval;
    uint public lastTimeStamp;
    uint8 public condition;
    address private immutable owner;

    constructor(uint256 updateInterval) ERC721("Cocoa Land Cross-Chain Infographic NFT", "COL") {
        interval = updateInterval;
        lastTimeStamp = block.timestamp;
        owner = msg.sender;
        farmstate["season"] = 0;
        farmstate["state"] = 0;
        authorize[msg.sender]= true;
        safeMint(msg.sender);
    }


    function safeMint(address _to) public authorized{
        uint256 tokenId = tokenIdCounter.current();
        tokenIdCounter.increment();
        availableTokenId[tokenId] = false;
        tokenIds.push(tokenId);
        Exist[tokenId] = true;
        _safeMint(_to, tokenId);
        _setTokenURI(tokenId, IpfsUri[farmstate["state"]]);
    }


    function reMint(address _to, uint256 _tokenId) public authorized{
        require(availableTokenId[_tokenId],"This NFT already exist");
        if(!Exist[_tokenId]){
            tokenIds.push(_tokenId);
        }
        _safeMint(_to, _tokenId);
        _setTokenURI(_tokenId, IpfsUri[farmstate["state"]]);

        
    } 

    function broadcast() public onlyOwner authorized{

         string memory newUri = IpfsUri[farmstate["state"]];
        for(uint i=0; i < tokenIds.length; i++){
                _setTokenURI(tokenIds[i], newUri);
            }
    }


    function resetSeason() public onlyOwner authorized{

        farmstate["season"] = 0;


    }

    function changeInterval(uint256 _interval) public onlyOwner{
        interval = _interval;

    }

    function updateCondition(uint8 _condition) public authorized{
        require(_condition < 7,"Changing Season is for Chainlink Automation Function");
        condition = _condition;
        uint8 season = farmstate["season"];
        farmstate["state"] = (season * 7) + _condition;
        _setTokenURI(tokenIds[0], IpfsUri[farmstate["state"]]);
        broadcast();
    }

    function updateReport(uint8 _yield) public authorized{
        require( _yield < 4, "There are only 3 types of yield reports");
        farmstate["state"] = (3 * 7) + _yield - 1; 
         _setTokenURI(tokenIds[0], IpfsUri[farmstate["state"]]);
         broadcast();
    }



    function plantationStage() public view returns(uint256){
        string memory _uri = tokenURI(tokenIds[0]);
        if(compareStrings(_uri, IpfsUri[0])){
            return 0;
        }else if(compareStrings(_uri, IpfsUri[1])){
            return 1;
        }else if(compareStrings(_uri, IpfsUri[2])){
            return 2;
        }else if(compareStrings(_uri, IpfsUri[3])){
            return 3;
        }else if(compareStrings(_uri, IpfsUri[4])){
            return 4;
        }else if(compareStrings(_uri, IpfsUri[5])){
            return 5;
        }else if(compareStrings(_uri, IpfsUri[6])){
            return 6;
        }else if(compareStrings(_uri, IpfsUri[7])){
            return 7;
        }else if(compareStrings(_uri, IpfsUri[8])){
            return 8;
        }else if(compareStrings(_uri, IpfsUri[9])){
            return 9;
        }else if(compareStrings(_uri, IpfsUri[10])){
            return 10;
        }else if(compareStrings(_uri, IpfsUri[11])){
            return 11;
        }else if(compareStrings(_uri, IpfsUri[12])){
            return 12;
        }else if(compareStrings(_uri, IpfsUri[13])){
            return 13;
        }else if(compareStrings(_uri, IpfsUri[14])){
            return 14;
        }else if(compareStrings(_uri, IpfsUri[15])){
            return 15;
        }else if(compareStrings(_uri, IpfsUri[16])){
            return 16;
        }else if(compareStrings(_uri, IpfsUri[17])){
            return 17;
        }else if(compareStrings(_uri, IpfsUri[18])){
            return 19;
        }else if(compareStrings(_uri, IpfsUri[20])){
            return 20;
        }else if(compareStrings(_uri, IpfsUri[21])){
            return 21;
        }

        return 22;
    
    }

    function growCocoaPlantation() public {
        uint256 newValue = plantationStage();
        if(newValue <= 6){
        // Get the current plantation growth stage and add 7
            newValue  +=  7;

        // Store the new Uri
            string memory newUri = IpfsUri[newValue];

        // Update the URI of all NFTs
            for(uint i=0; i < tokenIds.length; i++){
                _setTokenURI(tokenIds[i], newUri);
            }
            

        }else if(newValue > 6 && newValue <=13){
        // Get the current plantation growth stage and add 7
            newValue += 7;

        // Store the new Uri
            string memory newUri = IpfsUri[newValue];

        // Update the URI of all NFTs
            for(uint i=0; i < tokenIds.length; i++){
                _setTokenURI(tokenIds[i], newUri);
            }

        } else if( newValue > 13 && newValue <= 20){
            newValue += 7;

            if(newValue > 23){
                newValue = 23;

            // Store the new Uri
                string memory newUri = IpfsUri[newValue];

             // Update the URI of all NFTs
                for(uint i=0; i < tokenIds.length; i++){
                    _setTokenURI(tokenIds[i], newUri);
                }
            } else {

                string memory newUri = IpfsUri[newValue];

             // Update the URI of all NFTs
                for(uint i=0; i < tokenIds.length; i++){
                    _setTokenURI(tokenIds[i], newUri);
                }

            }

        }

    }



        function checkUpkeep(bytes calldata /*checkData*/) external view override returns(bool upkeepNeeded, bytes memory 
        /*Perform Data*/){
            if((block.timestamp - lastTimeStamp) > interval){
                upkeepNeeded = true;
            }

        }


        function performUpkeep(bytes calldata /*perform Data*/) external override {
            if((block.timestamp -lastTimeStamp) > interval){
                lastTimeStamp = block.timestamp;
                growCocoaPlantation();
            }

        }   


    // helper function to compare strings
        function compareStrings(string memory _a, string memory _b) public pure returns (bool){
            return (keccak256(abi.encodePacked((_a))) ==
                keccak256(abi.encodePacked((_b))));
        }

        // We don't use the performData in this example. The performData is generated by the Automation's call to your checkUpkeep function

        function tokenURI(uint256 _tokenId)
            public view override(ERC721, ERC721URIStorage) returns (string memory)
        {
            return super.tokenURI(_tokenId);
        }

        // 
        function burnNFT(uint256 _tokenId) public authorized{
            _burn(_tokenId);
            availableTokenId[_tokenId] = true;

            
        }

    // The following function is an override required by Solidity.
        function _burn(uint256 _tokenId) internal  override(ERC721, ERC721URIStorage){
            super._burn(_tokenId);
            
        }

    //  Modifier 
        modifier onlyOwner{
            require(msg.sender == owner,"You are not authorized to reset season");
            _;
        }

        modifier authorized{
            require(authorize[msg.sender],"You are not authorize to use this function");
            _;
    }

        function giveAuthority (address _contract) public onlyOwner{
            authorize[_contract] = true;
    }

        function revokeAuthority(address _contract) public onlyOwner{
            authorize[_contract] = false;
    }

}
