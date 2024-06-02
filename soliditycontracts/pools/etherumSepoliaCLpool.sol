// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


import "@openzeppelin/contracts/access/Ownable.sol";


contract EthereumCocoaLandPool is Ownable {

    uint256 public Balance;

    address[] public  funders;
    
    mapping(address => bool) public Authorize;
    mapping(address => uint256) public LiquidtyProviders;

    constructor(address initialOwner) Ownable(initialOwner){
        
    }

    // Modifiers

    modifier isAuthorized {
        require(Authorize[msg.sender], "You are not authorized to use this function");
        _;

    }


    // A function to give contracts authorization to use to the pool 

    function addAuthorization(address _contract) public onlyOwner {
        Authorize[_contract] = true;
        

    }


    // A function to check if a contract or address is authorized


    function getAuthorization(address _address) public view returns(bool){
        return Authorize[_address];
    }

    // A fundMe function

    function fund() public payable{
        require(msg.value > 0, "Amount not enough");
        LiquidtyProviders[msg.sender] += msg.value;
        funders.push(msg.sender);



    }

    // A function that enables authorized contracts to swap tokens

    function send(uint256 _nativeToken, address _wallet) external isAuthorized{

        (bool callSuccess,) = payable(_wallet).call{value: _nativeToken}("");
        require(callSuccess, "Transaction failed");


        

    }

    // A function to get the amount of Native Token the contract holds

    function getLiquidtyAmount() public view returns (uint256) {
        return address(this).balance;

    }

    // A function to remove authorization for a contract to use the pool

    function removeAuthorization(address _contract) public onlyOwner {
        Authorize[_contract] = false;
    }


}