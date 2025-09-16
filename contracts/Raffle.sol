// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/vrf/interfaces/VRFCoordinatorV2Interface.sol";

error Raffle__NotEnoughAmount();
error Raffle__TransectionFailed();

abstract contract Raffle is VRFConsumerBaseV2 {
    // immutable variable
    uint256 private immutable i_EntranceFee;
    uint64 private immutable i_subscriptionId;
    uint16 private immutable i_requestConfirmations;
    uint32 private immutable i_callbackGasLimit;

    bytes32 private immutable i_keyHash;
    VRFCoordinatorV2Interface private immutable i_vrfCoodinator;

    // CONSTANT
    uint16 private constant NUMWORDS = 1;

    // state variable
    address payable[] private s_Players;

    // Events
    event RaffleEnter(address player);

    constructor(
        uint256 entrancefee,
        uint64 subscriptionId,
        address vrfcoodinator,
        bytes32 gasLane,
        uint16 requestconfirmation,
        uint32 callbackgaslimit
    ) VRFConsumerBaseV2(vrfcoodinator) {
        i_EntranceFee = entrancefee;
        i_subscriptionId = subscriptionId;
        i_vrfCoodinator = VRFCoordinatorV2Interface(vrfcoodinator);
        i_keyHash = gasLane;
        i_requestConfirmations = requestconfirmation;
        i_callbackGasLimit = callbackgaslimit;
    }

    function enterRaffle() public payable {
        if (msg.value < i_EntranceFee) {
            revert Raffle__NotEnoughAmount();
        }
        s_Players.push(payable(msg.sender));

        emit RaffleEnter(msg.sender);
    }

    function pickwinner() public {
        uint256 Len = s_Players.length;
        uint256 winnerIndex = getrandomNumber() % Len;
        address payable Winner = s_Players[winnerIndex];
        (bool success, ) = Winner.call{value: address(this).balance}("");
        if (!success) {
            revert Raffle__TransectionFailed();
        }
    }

    function getrandomNumber() internal returns (uint256 requestId) {
        requestId = i_vrfCoodinator.requestRandomWords(
            i_keyHash,
            i_subscriptionId,
            i_requestConfirmations,
            i_callbackGasLimit,
            NUMWORDS
        );
    }

    // getter function

    function getPlayer(uint256 index) public view returns (address) {
        return s_Players[index];
    }

    function getEnteranceFee() public view returns (uint256) {
        return i_EntranceFee;
    }
}
