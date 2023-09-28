// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

contract MultiSig{
    address[] public owners;
    uint public numConfirm;
    struct Transaction{
        address to;
        uint value;
        bool executed;
    }
    mapping(uint=>mapping (address=>bool)) isConfirm;
    Transaction[] public transactions;

    event TransactionSubmit(uint transactionId , address sender , address receiver , uint amount);
    event TransactionConfirmed(uint transactionId);
    event TransactionExecuted(uint transactionId);
    constructor(address[] memory _owners , uint _numConfirm){
        require(_owners.length>1,"Owners required must be greater than 1");
        require(_numConfirm>0 && numConfirm<=_owners.length,"Numbers of confirmations are not sync with the numbers of owners");

        for(uint i=0;i<_owners.length;i++){
            require(_owners[i]!=address(0),"Invalid Owner");
            owners.push(_owners[i]);
        }
        numConfirm=_numConfirm;
    }
    function submitTransaction(address _to) public payable{
        require(_to!=address(0),"Ininvalid Receivers addresss");
        require(msg.value>0,"Transfer amount must be greater than 0");

        uint transactionId =  transactions.length;

        transactions.push(Transaction({to:_to,value:msg.value,executed:false}));
        emit TransactionSubmit(transactionId ,msg.sender ,_to,msg.value);
    }
    function confirmTransaction(uint _transactionId) public {
        require(_transactionId<transactions.length,"Invalid Transaction Id");
        require(!isConfirm[_transactionId][msg.sender],"Transaction is already confirmed by the owner");
        isConfirm[_transactionId][msg.sender]=true;
        emit TransactionConfirmed(_transactionId);
        if(isTransactionConfirmed(_transactionId)){
            executeTransaction(_transactionId);
        }
    }
    function executeTransaction(uint _transactionId) public  payable{
         require(_transactionId<transactions.length,"Invalid Transaction Id");
         require(!transactions[_transactionId].executed,"Transaction is already executed");
         (bool success,)=transactions[_transactionId].to.call{value:transactions[_transactionId].value}("");
         require(success,"Transaction Execution is fali");
         transactions[_transactionId].executed=true;
         emit TransactionExecuted(_transactionId);
    }
  function isTransactionConfirmed(uint _transactionId) internal view returns(bool){
    require(_transactionId<transactions.length,"Invalid Transaction Id");
    uint confirmationCount;

    for(uint i=0;i<owners.length;i++){
        if(isConfirm[_transactionId][owners[i]]){
            confirmationCount++;
        }
    }
    return confirmationCount>=numConfirm;
  }

}
