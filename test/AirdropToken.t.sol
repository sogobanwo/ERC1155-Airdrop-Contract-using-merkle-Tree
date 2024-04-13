// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2, stdJson} from "forge-std/Test.sol";

import {AirdropToken} from "../src/AirdropToken.sol";

contract AirdropTokenTest is Test {
    using stdJson for string;
    AirdropToken public airdropToken;
    struct Result {
        bytes32 leaf;
        bytes32[] proof;
    }

    struct User {
        address user;
        uint tokenId;
        uint amount;
    }
    Result public result;
    User public user;
    bytes32 root =
        0xe863cb1ed3d13fa29e5654b0630eb4d63cf20d7d9e0fba9ae15ea03d9795f68f;
    address user1 = 0x6d6534cC42361946cb28CAd1da30ba3C5d776f93;

    function setUp() public {
        airdropToken = new AirdropToken(root, msg.sender);
        string memory _root = vm.projectRoot();
        string memory path = string.concat(_root, "/merkle_tree.json");

        string memory json = vm.readFile(path);
        string memory data = string.concat(_root, "/address_data.json");

        string memory dataJson = vm.readFile(data);

        bytes memory encodedResult = json.parseRaw(
            string.concat(".", vm.toString(user1))
        );
        user.user = vm.parseJsonAddress(
            dataJson,
            string.concat(".", vm.toString(user1), ".address")
        );
        user.tokenId = vm.parseJsonUint(
            dataJson,
            string.concat(".", vm.toString(user1), ".tokenId")
        );
        user.amount = vm.parseJsonUint(
            dataJson,
            string.concat(".", vm.toString(user1), ".amount")
        );
        
        result = abi.decode(encodedResult, (Result));
        console2.logBytes32(result.leaf);
    }

    function testClaimed() public {
        bool success = airdropToken.claim(user.user, user.tokenId, user.amount, "", result.proof);
        assertTrue(success);
    }

    function testAlreadyClaimed() public {
        airdropToken.claim(user.user, user.tokenId, user.amount, "", result.proof);
        vm.expectRevert("already claimed");
        airdropToken.claim(user.user, user.tokenId, user.amount, "", result.proof);
    }

    function testIncorrectProof() public {
        bytes32[] memory fakeProofleaveitleaveit;

        vm.expectRevert("not whitelisted");
        airdropToken.claim(user.user, user.tokenId, user.amount, "", fakeProofleaveitleaveit);
    }
}
