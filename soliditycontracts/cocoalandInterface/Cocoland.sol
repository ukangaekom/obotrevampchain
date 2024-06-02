// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";

import {OwnerIsCreator} from "@chainlink/contracts-ccip/src/v0.8/shared/access/OwnerIsCreator.sol";
import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {IERC20} from "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.0/token/ERC20/IERC20.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts@4.6.0/utils/Counters.sol";




interface CocoaLandInfographicNFT{
    function tokenIdCounter() external view returns (Counters.Counter memory);
    function safeMint(address _to) external ;
    function reMint(address _to, uint256 _tokenId) external ;
    function burnNFT(uint256 _tokenId) external ;
}

interface CocoaLandToken{

    function burnToken(address _sender, uint256 _amount) external ;

    function mint(address to, uint256 amount) external  ;

    function decimals() external  pure returns (uint8);

}

interface CocoaLandPool{
    function send(uint256 _nativeToken, address _wallet) external;

    function fund() external;

    function getLiquidtyAmount() external  view returns (uint256);
    


}


contract CrosschainCocoaLand is OwnerIsCreator {
    using Counters for Counters.Counter;
    AggregatorV3Interface internal dataFeed;

    IRouterClient router;
    LinkTokenInterface linkToken;
    
    mapping(uint64 => bool) public whitelistedChains;

    // Share price is 100 per USD
    uint256 private shareStandardPrice = 5;

    // Standared Share amount per dollar
    uint256 private shares = 100;

    // Unit representation of polygon 
    uint256 private immutable Unit = 10 ** 8;

    // Polygon Crosschain indicator 
    uint256 indicator = 200;
    
    error NotEnoughBalance(uint256 currentBalance, uint256 calculatedFees); 
    error DestinationChainNotWhitelisted(uint64 destinationChainSelector);
    error NothingToWithdraw();


    event sharesTransfer(
        bytes32 indexed messageId, // The unique ID of the message.
        uint64 indexed destinationChainSelector, // The chain selector of the destination chain.
        address receiver, // The address of the receiver on the destination chain.
        DematAccount dematAccount, // The token address that was transferred.
        address feeToken, // the token address used to pay CCIP fees.
        uint256 fees // The fees paid for sending the message.
    );

    event CrossChainTokenTransfer (
        bytes32 indexed messageId, // The unique ID of the message.
        uint64 indexed destinationChainSelector, // The chain selector of the destination chain.
        address receiver, // The address of the receiver on the destination chain.
        uint256 amount, //The amount of cocoaland tokens sent crosschain
        address feeToken, // the token address used to pay CCIP fees.
        uint256 fees // The fees paid for sending the message.  
    );


    mapping(address=> DematAccount[]) public sharesAccount;

    mapping(address => bool) public authorize;

    


    struct DematAccount {
        uint256 shares;
        uint256 id;
    }

    struct programmableData{
        uint256 nftId;
        uint256 tokenAmount;
        uint256 shares;
        address sender;
    }

    // Contract address on Polygon Amoy
    address private cocoalandNFTAddress = 0x0f4987C38Ff501eE799C7E96B0b075a6f2770245;
    address private cocoalandTokenAddress = 0x361FE0fF3BD60679a3d970913f96676F8CE461Af;
    address private cocoalandTokenPool = 0x3c7ec0Bde2104C8C55ccEf807eA15aE1c6F70A27;


    // Cocoa Land Contract Interface

    CocoaLandInfographicNFT private dynamicNFT;

    CocoaLandToken private farmtoken;

    CocoaLandPool private pool;


    

    // Variables
    uint256 private gasLimit = 200_000;


    constructor(address _router, address _link) {
        router = IRouterClient(_router);
        linkToken = LinkTokenInterface(_link);
        dynamicNFT = CocoaLandInfographicNFT(cocoalandNFTAddress);
        farmtoken = CocoaLandToken(cocoalandTokenAddress);
        pool = CocoaLandPool(cocoalandTokenPool);
        dataFeed = AggregatorV3Interface(
            0x001382149eBa3441043c1c66972b4772963f5D43
        );
    }

    function getChainlinkDataFeedLatestAnswer() public view returns (int) {
        // prettier-ignore
        (
            /* uint80 roundID */,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = dataFeed.latestRoundData();
        return price ;
    }




    modifier onlyWhitelistedChain(uint64 _destinationChainSelector) {
        if (!whitelistedChains[_destinationChainSelector])
            revert DestinationChainNotWhitelisted(_destinationChainSelector);
        _;
    }

    
   
    function whitelistChain(
        uint64 _destinationChainSelector
    ) external onlyOwner {
        whitelistedChains[_destinationChainSelector] = true;
    }

    function denylistChain(
        uint64 _destinationChainSelector
    ) external onlyOwner {
        whitelistedChains[_destinationChainSelector] = false;
    }
    




    
    function withdrawToken(
        address _beneficiary,
        address _token
    ) public onlyOwner {
        uint256 amount = IERC20(_token).balanceOf(address(this));
        
        if (amount == 0) revert NothingToWithdraw();
        
        IERC20(_token).transfer(_beneficiary, amount);
    }


    function getGasLimit() public view returns(uint256){
        return gasLimit;
    }

    function setGasLImit(uint256 _gasLimit) public onlyOwner{
        gasLimit = _gasLimit;
    }





    // COCOA LAND FUNCTIONS

    // swapping tokens

    function swapToken(uint256 _cocoaland) public {
        uint256 amount = calculateSwapAmount(_cocoaland);
        require(pool.getLiquidtyAmount() > amount,"Liquidity Pool is empty");
        require(IERC20(cocoalandTokenAddress).transferFrom(msg.sender,address(farmtoken),_cocoaland * farmtoken.decimals()),"transaction failed");
        pool.send(amount, msg.sender);
        farmtoken.mint(msg.sender,amount);

    }

    function buyToken(uint256 _nativeToken) public{
        uint256 amount = calculateCocoaLandToken(_nativeToken);
        (bool success,) = address(pool).call{value:amount}("");
        require(success,'transaction failed');
        farmtoken.mint(msg.sender, amount);

    }

    // buying shares

    function buyShares(uint256 _amount) public{
        (bool successful, , uint256 sharesAmount) = calculateCocoaLandNFTPrice(_amount);
        require(successful,"You amount isn't enought to buy shares");
        payable(address(pool)).transfer(_amount);
        pool.fund();
        Counters.Counter memory nftTokenId = dynamicNFT.tokenIdCounter();
        uint256 id = nftTokenId._value;
        
        DematAccount memory account = DematAccount({
            shares: sharesAmount,
            id:id
        });
        pool.fund();
        dynamicNFT.safeMint(msg.sender);
        sharesAccount[msg.sender].push(account);

    }

    function sellShares() public virtual {

    }


    // transfer shares 
    function transferShares(address _receiver,uint256 _id) public {
        uint256 nftid = 0;
        uint256 index;
        DematAccount memory account;
        for (uint256 i=0; i < sharesAccount[msg.sender].length; i++){
            require(sharesAccount[msg.sender][i].id == _id, "This isn't your NFT");

            nftid = sharesAccount[msg.sender][i].id;
            account = sharesAccount[msg.sender][i];
            index = i;

        }
        if(nftid != 0){
            dynamicNFT.burnNFT(nftid);
            dynamicNFT.reMint(_receiver, nftid);
            resetDematAccount(msg.sender,index);
            sharesAccount[_receiver].push(account);
            
            
        }
        
    }

    function transferSharesCrossChain(
        uint64 _destinationChainSelector,
        address _receiver,
        uint256 _index,
        DematAccount memory _sharesAccount,
        address _token

    ) public 
    
    onlyOwner onlyWhitelistedChain(_destinationChainSelector)
    returns (bytes32 messageId) 
    {
        Client.EVMTokenAmount[]
            memory tokenAmounts = new Client.EVMTokenAmount[](1);
        Client.EVMTokenAmount memory tokenAmount = Client.EVMTokenAmount({
            token: _token,
            amount: 0
        });
        tokenAmounts[0] = tokenAmount;


        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver: abi.encode(_receiver),
            data: abi.encodeWithSignature("mintDematAccount(address,uint256,DematAccount)", msg.sender,_index,_sharesAccount),
            tokenAmounts: tokenAmounts,
            extraArgs: Client._argsToBytes(
                Client.EVMExtraArgsV1({gasLimit: gasLimit})
            ),
            feeToken: address(linkToken)
        });

        // CCIP Fees Management
        uint256 fees = router.getFee(_destinationChainSelector, message);

        if (fees > linkToken.balanceOf(address(this))){
            revert NotEnoughBalance(linkToken.balanceOf(address(this)), fees);
        }

        linkToken.approve(address(router), fees);
        
        // Approve Router to spend CCIP-BnM tokens we send
        IERC20(_token).approve(address(router), 0);
        
        // Send CCIP Message
        messageId = router.ccipSend(_destinationChainSelector, message); 

        emit sharesTransfer(
            messageId,
            _destinationChainSelector,
            _receiver,
            _sharesAccount,
            address(linkToken),
            fees
        ); 
        
    }


    // transfer tokens
    function transferToken(address _receiver, uint256 _amount) public {
        uint256 amount = _amount * (10 ** farmtoken.decimals());
        IERC20 cocoalandToken = IERC20(cocoalandTokenAddress);
        require(cocoalandToken.balanceOf(msg.sender) > amount, "You don't have enought tokens");

        farmtoken.burnToken(msg.sender, _amount);
        farmtoken.mint(_receiver, _amount);
        
    }


    function transferTokenCrossChain(
        uint64 _destinationChainSelector,
        address _receiver,
        address _token,
        uint256 _amount
    ) public onlyWhitelistedChain(_destinationChainSelector)
    returns (bytes32 messageId) {
        uint256 amount = _amount * (10 *farmtoken.decimals());
        IERC20 cocoaland = IERC20(cocoalandTokenAddress);
        require(cocoaland.balanceOf(msg.sender) > amount, "You are permitted to send Token");

        farmtoken.burnToken(msg.sender, _amount);

        Client.EVMTokenAmount[]
            memory tokenAmounts = new Client.EVMTokenAmount[](1);
        Client.EVMTokenAmount memory tokenAmount = Client.EVMTokenAmount({
            token: _token,
            amount: 0
        });
        tokenAmounts[0] = tokenAmount;
    

    Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver: abi.encode(_receiver),
            data: abi.encodeWithSignature("farmtoken.mint(address,uint256)", msg.sender,_amount),
            tokenAmounts: tokenAmounts,
            extraArgs: Client._argsToBytes(
                Client.EVMExtraArgsV1({gasLimit: gasLimit})
            ),
            feeToken: address(linkToken)
        });

    // CCIP Fees Management
        uint256 fees = router.getFee(_destinationChainSelector, message);

        if (fees > linkToken.balanceOf(address(this)))
            revert NotEnoughBalance(linkToken.balanceOf(address(this)), fees);

        linkToken.approve(address(router), fees);
        
        // Approve Router to spend CCIP-BnM tokens we send
        IERC20(_token).approve(address(router), _amount);
        
        // Send CCIP Message
        messageId = router.ccipSend(_destinationChainSelector, message); 
        
         emit CrossChainTokenTransfer(
            messageId,
            _destinationChainSelector,
            _receiver,
            _amount,
            address(linkToken),
            fees
        );  

    
}

     




    // PRICE CALCUATIONS

    function calculateCocoaLandNFTPrice(uint256 _nativeToken) internal view returns (bool, uint256, uint256 ){
        uint256 boughtShares;
        uint256 nativeToken = _nativeToken / Unit;
        uint256 usdPrice = uint256(uint256(getChainlinkDataFeedLatestAnswer()) / Unit);
        uint256 dollarAmount = (nativeToken * usdPrice);
        bool success = false;
       
        require(dollarAmount > shareStandardPrice,"You can't buy a share");
        
        boughtShares = dollarAmount * shares;
        success = true;


    

        return (success,dollarAmount, boughtShares);



    }
    function calculateCocoaLandToken(uint256 _nativeToken) internal view returns (uint256 ){
        uint256 nativeToken = _nativeToken / Unit;
        uint256 usdPrice = uint256(uint256(getChainlinkDataFeedLatestAnswer()) / Unit);
        uint256 dollarAmount = (nativeToken * usdPrice);
        uint256 cocoaLandAmount = dollarAmount * 10;

    

        return cocoaLandAmount;



    }

    function calculateSwapAmount(uint256 _cocoalandToken) internal view returns (uint256) {
        uint cocoaland = (_cocoalandToken * (10 *farmtoken.decimals())) / 12;
        uint256 nativeToken = cocoaland * Unit;
        
        return nativeToken;

        

    }




    //reseting Account
    function resetDematAccount(address _owner, uint256 _index) private{
        DematAccount memory dematAccount = DematAccount({
            shares:0,
            id:0});
        sharesAccount[_owner][_index] = dematAccount;
    }

    function mintDematAccount(address _owner, uint256 _index, DematAccount memory _dematAccount) private{
        uint256 registeredPosition = indicator + _index;
        sharesAccount[_owner][registeredPosition] = _dematAccount;
    }


    //function to update token price 
    function updateTokenPrice(uint256 _newPrice) public authorized{

    }


    function authorizeContract(address _contract) public onlyOwner{
        authorize[_contract] = true;
    }

    function unauthorizeContract(address _contract) public onlyOwner{
        authorize[_contract] = false;
    }



    modifier authorized{
        require(authorize[msg.sender],"You are not authorize to use this function");
        _;
    }

}


    

