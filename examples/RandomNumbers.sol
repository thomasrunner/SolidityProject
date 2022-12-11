// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract RandomNumberGenerator {
    
    // * seed value adds additional randomness by making the result of the last transaction the seed for next
    uint256 private _seed = 4254618;
    uint256 constant MODEVALUE = 100;

    constructor(uint256 seed) {
        _seed = seed;
    }

    /**
     * @param seed reset seed value.
     */
    function resetSeedSalt(uint256 seed) public {
        _seed = seed;
    }

    /**
     * @notice Updates the source of randomness. Uses block.difficulty in pre-merge chains, this is substituted
     * to block.prevrandao in post merge chains.
     * @param value is the token Id
     */
    function randomSeededNum(
        uint256 value
    ) public returns (uint256) {
        uint256 seed = uint256(keccak256(abi.encode(block.difficulty,block.timestamp,block.number,msg.sender,_seed,value)));
        _seed = seed;
        uint256 output = _seed % MODEVALUE;
		return output;
    }

    /**
     * @notice Updates the source of randomness. Uses block.difficulty in pre-merge chains, this is substituted
     * to block.prevrandao in post merge chains.
     * @param value is the token Id
     */
    function randomNum(
        uint256 value
    ) public view returns (uint256) {
        uint256 seed = uint256(keccak256(abi.encode(block.difficulty,block.timestamp,block.number,msg.sender,_seed,value)));
        uint256 output = seed % MODEVALUE;
		return output;
    }
}
