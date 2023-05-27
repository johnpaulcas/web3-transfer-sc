// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import {BaseTest} from "./base/BaseTest.sol";
import {BaseMultiTokenDisperserTest} from "./base/BaseMultiTokenDisperser.t.sol";

import "../src/MultiTokenDisperser.sol";

contract MultiTokenDisperserTest is BaseMultiTokenDisperserTest {
    MultiTokenDisperser disperser;

    function setUp() public override {
        super.setUp();
        disperser = new MultiTokenDisperser();
    }

    function testDisperseEther() public {
        address from = alice;

        address[] memory recipients = createAccounts(5);

        uint256[] memory amounts = new uint256[](5);
        amounts[0] = 100;
        amounts[1] = 200;
        amounts[2] = 300;
        amounts[3] = 400;
        amounts[4] = 500;

        uint256 totalAmounts = 1500;

        vm.deal(from, totalAmounts);

        vm.expectEmit(true, true, false, true, address(disperser));
        emit EtherDispersed(from, recipients, amounts);

        vm.prank(from);
        disperser.disperseEther{value: totalAmounts}(
            recipients,
            amounts,
            totalAmounts
        );

        for (uint256 n; n < recipients.length; ++n) {
            assertEq(address(recipients[n]).balance, amounts[n]);
        }
    }

    function testDisperseERC20() public {
        address from = alice;

        address[] memory recipients = createAccounts(5);

        uint256[] memory amounts = new uint256[](5);
        amounts[0] = 100;
        amounts[1] = 200;
        amounts[2] = 300;
        amounts[3] = 400;
        amounts[4] = 500;

        uint256 totalAmounts = 1500;

        mockERC20.mint(from, totalAmounts);

        vm.prank(from);
        mockERC20.approve(address(disperser), type(uint256).max);

        vm.expectEmit(true, true, false, true, address(disperser));
        emit ERC20Dispersed(address(mockERC20), from, recipients, amounts);

        vm.prank(from);
        disperser.disperseERC20(mockERC20, recipients, amounts, totalAmounts);

        for (uint256 n; n < recipients.length; ++n) {
            assertEq(mockERC20.balanceOf(recipients[n]), amounts[n]);
        }
    }

    function testDisperseERC721() public {
        address from = alice;

        address[] memory recipients = createAccounts(5);

        uint256[] memory tokenIds = new uint256[](5);
        tokenIds[0] = 100;
        tokenIds[1] = 200;
        tokenIds[2] = 300;
        tokenIds[3] = 400;
        tokenIds[4] = 500;

        for (uint index; index < tokenIds.length; index++) {
            mockERC721.mint(from, tokenIds[index]);
        }

        vm.prank(from);
        mockERC721.setApprovalForAll(address(disperser), true);

        vm.expectEmit(true, true, false, true, address(disperser));
        emit ERC721Dispersed(address(mockERC721), from, recipients, tokenIds);

        vm.prank(from);
        disperser.disperseERC721(mockERC721, recipients, tokenIds);

        for (uint256 n; n < recipients.length; ++n) {
            assertEq(mockERC721.ownerOf(tokenIds[n]), recipients[n]);
        }
    }

    function testDisperseERC1155() public {
        address from = alice;

        address[] memory recipients = createAccounts(5);

        uint256[] memory ids = new uint256[](5);
        ids[0] = 1337;
        ids[1] = 1338;
        ids[2] = 1339;
        ids[3] = 1340;
        ids[4] = 1341;

        uint256[] memory mintAmounts = new uint256[](5);
        mintAmounts[0] = 100;
        mintAmounts[1] = 200;
        mintAmounts[2] = 300;
        mintAmounts[3] = 400;
        mintAmounts[4] = 500;

        uint256[] memory transferAmounts = new uint256[](5);
        transferAmounts[0] = 50;
        transferAmounts[1] = 100;
        transferAmounts[2] = 150;
        transferAmounts[3] = 200;
        transferAmounts[4] = 250;

        mockERC1155.mintBatch(from, ids, mintAmounts);

        vm.prank(from);
        mockERC1155.setApprovalForAll(address(disperser), true);

        vm.expectEmit(true, true, false, true, address(disperser));
        emit ERC1155Dispersed(
            address(mockERC1155),
            from,
            recipients,
            ids,
            transferAmounts
        );

        vm.prank(from);
        disperser.disperseERC1155(
            mockERC1155,
            recipients,
            ids,
            transferAmounts
        );

        for (uint256 n; n < recipients.length; ++n) {
            assertEq(
                mockERC1155.balanceOf(recipients[n], ids[n]),
                transferAmounts[n]
            );

            assertEq(
                mockERC1155.balanceOf(from, ids[n]),
                mintAmounts[n] - transferAmounts[n]
            );
        }
    }
}
