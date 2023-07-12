// SPDX-License-Identifier: UNLICENSED

// DO NOT MODIFY BELOW THIS
pragma solidity ^0.8.17;

import "hardhat/console.sol";

contract Splitwise {
// DO NOT MODIFY ABOVE THIS

// ADD YOUR CONTRACT CODE BELOW

    struct IOU {
        address creditor;
        int32 amount;
        uint creditor_id;
        bool _valid;
    }

    struct Debtor {
        IOU [] IOUs;
        address debtor;
        uint id;
        bool _valid;
    }

    mapping (address => mapping(address => IOU)) ledger;
    mapping (address => Debtor) debtorMap;

    Debtor[] ledgerArr;

    function add_IOU(address _creditor, int32 _amount) public returns (bool res) {
        require(msg.sender != _creditor, "Cannot owes to themself");

        if (debtorMap[msg.sender]._valid == false) {
            IOU memory _IOU = IOU({creditor: _creditor, amount: _amount, creditor_id: 0, _valid: true});
            Debtor storage debtor = debtorMap[msg.sender];
            ledger[msg.sender][_creditor] = _IOU;
            debtor.debtor = msg.sender;
            debtor.IOUs.push(_IOU);
            debtor.id = ledgerArr.length;
            debtor._valid = true;
            ledgerArr.push(debtor);
            debtorMap[msg.sender] = debtor;
            return true;
        }
        else if (ledger[msg.sender][_creditor]._valid == false) {
            IOU memory _IOU = IOU({creditor: _creditor, amount: _amount, creditor_id: ledgerArr[debtorMap[msg.sender].id].IOUs.length, _valid: true});
            ledger[msg.sender][_creditor] = _IOU;
            ledgerArr[debtorMap[msg.sender].id].IOUs.push(_IOU);
            return true;
        }
        else {
            require(ledger[msg.sender][_creditor].amount + _amount >= 0, "tx results to negative IOU.");
            ledger[msg.sender][_creditor].amount = ledger[msg.sender][_creditor].amount + _amount;
            ledgerArr[debtorMap[msg.sender].id].IOUs[ledger[msg.sender][_creditor].creditor_id].amount += _amount;
            if (ledger[msg.sender][_creditor].amount == 0){
                ledger[msg.sender][_creditor]._valid = false;
                ledgerArr[debtorMap[msg.sender].id].IOUs[ledger[msg.sender][_creditor].creditor_id]._valid = false;
            } else {
                ledger[msg.sender][_creditor]._valid = true;
                ledgerArr[debtorMap[msg.sender].id].IOUs[ledger[msg.sender][_creditor].creditor_id]._valid = true;
            }
            return true;
        }
        return false;
    }

    function getLedger() public view returns(Debtor[] memory _ledgerArr){
        return ledgerArr;
    }

    function lookup(address debtor, address creditor) public view returns (int32 ret) {
        return ledger[debtor][creditor].amount;
    }

}
