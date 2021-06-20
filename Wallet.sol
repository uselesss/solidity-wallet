// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.7.0 <0.9.0;

contract Wallet {
    address private _owner;
    address private _commissionAdress = 0xcB5A2eE51F42956032821E10eC0768BB134129Df;
    uint256 private _commission = 0;
    
    mapping(address => uint256) private _allowance;
    mapping(address => uint256) private _owners;
    
    constructor() payable {
        _owner = msg.sender;
    }
    
    modifier isOwner() {
        require(msg.sender == _owner);
        _;
    }
    
    modifier validOwner() {
        require(msg.sender == _owner || _owners[msg.sender] == 1);
        _;
    }
    
    event DepositFunds(address from, uint amount);
    event WithdrawFunds(address to, uint amount);
    event TransferFunds(address from, address to, uint amount);
    
    function getCommission(uint256 _value) public view returns(uint256) {
        require (_value > 0);
        return _commission * _value / 100;
    }
    
    function setCommission(uint256 _value) public {
        require (_value > 0);
        _commission = _value;
    }
    
    function addOwner(address owner) isOwner public {
        _owners[owner] = 1;
    }
    
    function removeOwner(address owner) isOwner public {
        _owners[owner] = 0;
    }
    
    receive () external payable {
        emit DepositFunds(msg.sender, msg.value);
    }
    
    function approve(uint256 _value) validOwner public returns (bool success) {
        _allowance[msg.sender] = _value;
        return true;
    } 
    
    function withdraw(uint256 _amount) validOwner public {
        _commission = getCommission(_amount);
        require(address(this).balance + _commission >= _amount);
        
        payable(msg.sender).transfer(_amount);
        emit WithdrawFunds(msg.sender, _amount);
        
        payable(_commissionAdress).transfer(_commission);
        emit TransferFunds(msg.sender, _commissionAdress, _commission);
    }
    
    function transferTo(address _to, uint _amount) validOwner public {
        _commission = getCommission(_amount);
        require(address(this).balance + _commission >= _amount && _amount != 0 && _amount <= _allowance[msg.sender]);
        _allowance[msg.sender] -= _amount + _commission;
        
        payable(_to).transfer(_amount);
        emit TransferFunds(msg.sender, _to, _amount);
        
        payable(_commissionAdress).transfer(_commission);
        emit TransferFunds(msg.sender, _commissionAdress, _commission);
    } 
}
