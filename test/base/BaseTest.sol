// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import {Address} from "@openzeppelin/contracts/utils/Address.sol";

import "forge-std/Test.sol";
import "../mocks/MockERC20.sol";
import "../mocks/MockERC721.sol";
import "../mocks/MockERC1155.sol";

contract BaseTest is Test {
    using Address for address;

    MockERC20 mockERC20;
    MockERC721 mockERC721;
    MockERC1155 mockERC1155;

    address alice;
    address bob;

    function setUp() public virtual {
        mockERC20 = new MockERC20();
        mockERC721 = new MockERC721();
        mockERC1155 = new MockERC1155();

        alice = makeAddr("alice");
        bob = makeAddr("bob");
    }

    function createAccounts(
        uint256 amount
    ) internal pure returns (address[] memory) {
        address[] memory accounts = new address[](amount);
        for (uint256 i = 0; i < amount; i++) {
            address account = vm.addr(i + 1);
            accounts[i] = account;
        }

        return accounts;
    }

    function min3(
        uint256 a,
        uint256 b,
        uint256 c
    ) internal pure returns (uint256) {
        return a > b ? (b > c ? c : b) : (a > c ? c : a);
    }

    function min2(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? b : a;
    }

    function nonZeroArrayAddress(
        address[] memory recipients
    ) internal view returns (address[] memory) {
        uint256 newArraySize = 0;

        for (uint n; n < recipients.length; n++) {
            if (recipients[n] != address(0) && !recipients[n].isContract()) {
                ++newArraySize;
            }
        }

        address[] memory nonZeroRecipeints = new address[](newArraySize);
        uint index;
        for (uint n; n < recipients.length; n++) {
            if (
                recipients[n] != address(0) &&
                !recipients[n].isContract() &&
                index < newArraySize
            ) {
                nonZeroRecipeints[index] = recipients[n];
                index++;
            }
        }

        return nonZeroRecipeints;
    }

    function sumArrayUint256(
        uint256[] memory numbers
    ) internal pure returns (uint256) {
        uint sum = 0;
        for (uint n; n < numbers.length; n++) {
            sum = sum + numbers[n];
        }

        return sum;
    }
}
