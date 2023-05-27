// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "forge-std/Test.sol";

import "../mocks/MockERC20.sol";
import "../mocks/MockERC721.sol";
import "../mocks/MockERC1155.sol";

contract BaseTest is Test {
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
}
