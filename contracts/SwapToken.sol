// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;
import { IERC20 } from "./IMint20.sol";

contract SwapToken {
    IERC20 public nigerToken;
    IERC20 public usdToken;
    address owner;
    bool internal locked;
    uint256 internal constant ONE_NGN_TO_USD = 1;

    enum Token {NONE, NGN, USD }

    mapping (Token => uint256)  contractBalances;

    constructor(IERC20 _nigerTokenCAddr, IERC20 _usdTokenCAddr){
        nigerToken = _nigerTokenCAddr;
        usdToken = _usdTokenCAddr;
        owner = msg.sender;
    }

    event SwapSuccessful(address indexed from, address indexed to, uint256 amount);
    event WithdrawSuccessful(address indexed owner, Token indexed _name, uint256 amount);


    modifier reentrancyGuard() {
        require(!locked, "Reentrancy not allowed");
        locked = true;
        _;
        locked = false;
    }

    modifier onlyOwner(){
        require(msg.sender == owner, "Only owner can access");
        _;
    }

    function swapNGNtoUSD(address _from, uint256 _amount) external reentrancyGuard  {
        require(msg.sender != address(0), "Zero not allowed");
        require(_amount > 0 , "Cannot swap zero amount");

        uint256 standardAmount = _amount * 10**18;

        uint256 userBal = nigerToken.balanceOf(msg.sender);

        require(userBal >= _amount, "Your balance is not enough");

        uint256 allowance = nigerToken.allowance(msg.sender, address(this));
        require(allowance >= _amount, "Token allowance too low");

        bool deducted = nigerToken.transferFrom(_from, address(this), standardAmount);

        require(deducted, "Excution failed");

        contractBalances[Token.NGN] +=  standardAmount;


        uint256 swapedValue = NGN_USD_Rate(standardAmount, Token.NGN);

        bool swapped = usdToken.transfer(msg.sender, swapedValue);



        if (swapped) {

            contractBalances[Token.USD] +=  swapedValue;



            emit SwapSuccessful(_from, address(this), standardAmount );
        }

    }

    function swapUsdtToDLT(address _from, uint256 _amount) external reentrancyGuard {
        require(msg.sender != address(0), "Zero not allowed");
        require(_amount > 0 , "Cannot swap zero amount");

        uint256 standardAmount = _amount * 10**18;

        uint256 userBal = usdToken.balanceOf(msg.sender);


        require(userBal >= _amount, "Your balance is not enough");

       
        uint256 allowance = usdToken.allowance(msg.sender, address(this));
        require(allowance >= _amount, "Token allowance too low");


        bool deducted = usdToken.transferFrom(_from, address(this), standardAmount);

        require(deducted, "Excution failed");

        contractBalances[Token.USD] +=  standardAmount;


        uint256 swapedValue = NGN_USD_Rate(standardAmount, Token.USD);

        bool swapped = usdToken.transfer(msg.sender, swapedValue);

        if (swapped) {

            contractBalances[Token.NGN] +=  swapedValue;


            emit SwapSuccessful(_from, address(this), standardAmount );
        }


    }


        function getContractBalance() external view onlyOwner returns (uint256 contractUsdtbal_, uint256 contractDLTbal_) {
        contractUsdtbal_ = usdToken.balanceOf(address(this));
        contractDLTbal_ = nigerToken.balanceOf(address(this));
    }


      function withdraw(Token _name, uint256 _amount) external onlyOwner  {
        require(_amount > 0, "balance is less");

        uint256 bal = contractBalances[_name];

        require(bal >= _amount, "Insufficient contract balance");


        if(Token.NGN == _name) {

         nigerToken.transfer(msg.sender, _amount);

         
        emit WithdrawSuccessful(msg.sender, _name, _amount);


        }else  if(Token.USD == _name) {
         usdToken.transfer(msg.sender, _amount);

         
        emit WithdrawSuccessful(msg.sender, _name, _amount);


        }

        revert("Token not defined");
    }



 function NGN_USD_Rate (uint256 _amount, Token _token) internal pure returns (uint256 swapedValue_) {
        if(_token == Token.USD) {
            swapedValue_ = _amount * ONE_NGN_TO_USD;  
        } else if(_token == Token.NGN) {
            swapedValue_ = _amount  / ONE_NGN_TO_USD ;
        } else {
            revert("Unsupported currency");
        }
        return swapedValue_;
    }
}
