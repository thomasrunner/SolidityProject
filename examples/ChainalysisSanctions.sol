// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface SanctionsList {
    function isSanctioned(address addr) external view returns (bool);
}

contract SanctionedAddresses {
    
    // Chainalysis sanctions contract
    address constant SANCTIONS_CONTRACT = 0x40C57923924B5c5c5455c48D93317139ADDaC8fb;
    SanctionsList constant SANCTIONSLIST = SanctionsList(SANCTIONS_CONTRACT);
    
    constructor() { }

    function isSanctionsAddress() public view {
        //Check if msg.sender is sanctioned
        bool isToSanctioned = SANCTIONSLIST.isSanctioned(msg.sender);
        require(!isToSanctioned, "Transfer to sanctioned address");
    }
}
