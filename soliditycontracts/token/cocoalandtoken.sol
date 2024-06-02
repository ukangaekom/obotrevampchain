// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20FlashMint.sol";

contract CocoaLand is ERC20, ERC20Burnable, ERC20Pausable, Ownable, ERC20Permit, ERC20Votes{
    
    address[] contracts;
    mapping(address=>bool) private Available;
    mapping(address => bool) private Authorization;

    uint256 private TotalSupply;
    uint256 private  CirculatingSupply;
    uint256 private UnmintedSupply;
    
    constructor(address initialOwner)
        ERC20("Cocoa Land", "COL")
        Ownable(initialOwner)
        ERC20Permit("Cocoa Land")
    {
        TotalSupply = 10000000000 * (10 ** decimals());

        CirculatingSupply = 0;
        UnmintedSupply = 10000000000 * (10 ** decimals());
        
    }


    // Modifiers for authorizing contracts to interact with the token contract

    modifier checkAuthorization{
        require(Authorization[msg.sender], "You are not authorized to use this function");
        _;
    }

    // function to authorize a contract
    function authorize(address _contract) public onlyOwner{
        contracts.push(_contract);
        if(!Available[_contract]){
            contracts.push(_contract);
            Available[_contract] = true;
            Authorization[_contract] = true;


        } else {

            Authorization[_contract] = true;

        }

    }



    // A function to get total supply

    function getTotalSupply () public view returns (uint256){

        return TotalSupply;

    }

    // A function to get circulating supply of token

    function getCirculatingSupply () public view returns (uint256){

        return CirculatingSupply;

    }

    // function to get UnmintedSupply
    function getLockedSupply () public view returns (uint256){
        return UnmintedSupply;
    }

    // A function to burn tokens 

    function burnToken(address _sender, uint256 _amount) public  checkAuthorization{
        UnmintedSupply += _amount * (10 ** decimals());
        CirculatingSupply -= _amount * (10 ** decimals());
        uint256 _unitAmount = _amount * (10 ** decimals());
        _burn(_sender, _unitAmount);

    }


    
    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function mint(address to, uint256 amount) public checkAuthorization {
        uint256 mintedAmount = amount *  (10 ** decimals());
        CirculatingSupply += mintedAmount;
        UnmintedSupply -= mintedAmount;
        
        _mint(to, mintedAmount);

    }

    function clock() public view override returns (uint48) {
        return uint48(block.timestamp);
    }

    // solhint-disable-next-line func-name-mixedcase
    function CLOCK_MODE() public pure override returns (string memory) {
        return "mode=timestamp";
    }


    function decimals() public pure override returns (uint8) {
        return 5;
    }

    // The following functions are overrides required by Solidity.

    function _update(address from, address to, uint256 value)
        internal
        override(ERC20, ERC20Pausable, ERC20Votes) 
    {
        super._update(from, to, value);
    }

    function nonces(address owner)
        public
        view
        override(ERC20Permit, Nonces)
        returns (uint256)
    {
        return super.nonces(owner);
    }
}
