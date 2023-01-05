# MockAccessControl - Audit - Alexandre Melo

## Findings
| Severity | Total |
| -------- | :---: |
| 1        | high  |
| 1        |  low  |


## 1 - Improper Delegation Handling - HIGH

```
function _delegate(address delegator, address delegatee) internal {
    address currentDelegate = _delegates[delegator];
    uint256 delegatorBalance = balanceOf(delegator);
    _delegates[delegator] = delegatee;

    emit DelegateChanged(delegator, currentDelegate, delegatee);

    _moveDelegates(currentDelegate, delegatee, delegatorBalance);
}

function _moveDelegates(address srcRep, address dstRep, uint256 amount) internal {
    if (srcRep != dstRep && amount > 0) {
        if (srcRep != address(0)) {
            // decrease old representative
            uint32 srcRepNum = numCheckpoints[srcRep];
            uint256 srcRepOld = srcRepNum > 0 ? checkpoints[srcRep][srcRepNum - 1].votes : 0;
            uint256 srcRepNew = srcRepOld.sub(amount);
            _writeCheckpoint(srcRep, srcRepNum, srcRepOld, srcRepNew);
        }

        if (dstRep != address(0)) {
            // increase new representative
            uint32 dstRepNum = numCheckpoints[dstRep];
            uint256 dstRepOld = dstRepNum > 0 ? checkpoints[dstRep][dstRepNum - 1].votes : 0;
            uint256 dstRepNew = dstRepOld.add(amount);
            _writeCheckpoint(dstRep, dstRepNum, dstRepOld, dstRepNew);
        }
    }
}
```
Description: **In the contract, there is a voting mechanism implemented, allowing the users (Delegators) to
delegate their votes to another address (Delegatees) without transferring their tokens.
The users can delegate their votes to another address using the delegate() function, which calls the
_delegate() function.** 

**The _delegate() function sets the delegatee of the address, and transfer the number of votes
from the old delegatee to the new delegatee with the current token balance of the delegator by using the
_moveDelegates() function. However, the delegate mechanism will only activate when the delegator calls the delegate() function.** 

**This means the tokens could be transferred to another person after the first delegation, and that person can call
the delegate() function again, allowing the tokens to be used for double spending attack in an aspect of
voting mechanism.**

## Recomendation:
**The delegation vote should be transferred from the previous delegatee to the new delegatee when the token transfer occurs.
Since the contract is implemented by following the ERC20 standard, inserting the
_moveDelegates function to the transfer() and transferFrom() functions will solve this issue.**

```
function transfer(address recipient, uint256 amount) external override nonReentrant returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    _moveDelegates(_delegates[msgSender()], _delegates[recipient], amount);
    return true;
}

function transferFrom(
    address sender,
    address recipient,
    uint256 amount
    ) external override nonReentrant returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
        sender,
        _msgSender(),
        _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
        _moveDelegates(_delegates[sender], _delegates[recipient], amount);
        return true;
}
```


## 2 - NOT USING SAFEMATH - LOW
Description: **This contract is using pragma `0.6.12` which is known for overflowing under certain operations.**

## Recomendation:
To avoid such situation is recommended the use of the SafeMath library.

## Tools used
`foundry`.

`slither`.

`mythril`.
