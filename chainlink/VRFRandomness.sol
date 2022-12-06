// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

contract Randomness is VRFConsumerBaseV2 {

    modifier onlyOwner() {
        require(msg.sender == _owner);
        _;
    }
    /**
     *  We store the contract deployer's address only for the purposes of the example
     *  in the code comment below.
     *
     *  Doing this is not necessary to use the `ContractMetadata` extension.
     */

    address _owner;

    VRFCoordinatorV2Interface COORDINATOR;

    uint64 _subscriptionId;

    // map tokenIds to decay state
    mapping(uint256 => bool) private _vrfInProgress;

    // Goerli coordinator. For other networks,
    // see https://docs.chain.link/docs/vrf-contracts/#configurations
    address vrfCoordinator = 0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D;

    // The gas lane to use, which specifies the maximum gas price to bump to.
    // For a list of available gas lanes on each network,
    // see https://docs.chain.link/docs/vrf-contracts/#configurations
    bytes32 _keyHash =
        0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15;

    // Depends on the number of requested values that you want sent to the
    // fulfillRandomWords() function. Storing each word costs about 20,000 gas,
    // so 40,000 is a safe default for this example contract. Test and adjust
    // this limit based on the network that you select, the size of the request,
    // and the processing of the callback request in the fulfillRandomWords()
    // function.
    uint32 _callbackGasLimit = 40000;

    // The default is 3, but you can set this higher.
    uint16 _requestConfirmations = 3;

    // For this example, retrieve 1 random value in one request.
    // Cannot exceed VRFCoordinatorV2.MAX_NUM_WORDS.
    uint32 numWords = 16;

    // optional map tokenId to decay amount
    mapping(uint256 => uint256) private _features;

    // map requestIds to tokenIds
    mapping(uint256 => uint256) private _requests;

    constructor(
        uint64 subscriptionId
    ) VRFConsumerBaseV2(vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        _owner = msg.sender;
        _subscriptionId = subscriptionId;
    }

    function setCallbackGasLimit(uint32 callbackGasLimit) public onlyOwner {
        _callbackGasLimit = callbackGasLimit;
    }

    function generateRandomness(uint256 tokenId) private returns (uint256 requestId) {
        require(!_vrfInProgress[tokenId], "Decay in progress");

        requestId = COORDINATOR.requestRandomWords(
            _keyHash,
            _subscriptionId,
            _requestConfirmations,
            _callbackGasLimit,
            numWords
        );

        _requests[requestId] = tokenId;
        _vrfInProgress[tokenId] = true;
    }

    /**
     * @notice Callback function used by VRF Coordinator to return the random number to this contract.
     *
     * @dev The VRF Coordinator will only send this function verified responses, and the parent VRFConsumerBaseV2
     * contract ensures that this method only receives randomness from the designated VRFCoordinator.
     *
     * @param requestId uint256
     * @param randomWords uint256[] The random result returned by the oracle.
     */
    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        override
    {
        uint256 tokenId = _requests[requestId];
        uint256 value = randomWords[0] % 100;
        _features[tokenId] = value;
        _vrfInProgress[tokenId] = false;
    }
}