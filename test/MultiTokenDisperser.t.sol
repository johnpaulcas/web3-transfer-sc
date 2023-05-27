// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import {BaseTest} from "./base/BaseTest.sol";
import {BaseMultiTokenDisperserTest} from "./base/BaseMultiTokenDisperser.t.sol";

import {Address} from "@openzeppelin/contracts/utils/Address.sol";

import "../src/interfaces/IMultiTokenDisperser.sol";
import "../src/MultiTokenDisperser.sol";

contract MultiTokenDisperserTest is BaseMultiTokenDisperserTest {
    using Address for address;

    mapping(address => mapping(uint256 => uint256)) public userMintAmounts;
    MultiTokenDisperser disperser;

    function setUp() public override {
        super.setUp();
        disperser = new MultiTokenDisperser();
    }

    // Ether ================

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

    function testDisperseEther_revert_MismatchedArrayLengths() public {
        address from = alice;
        address[] memory recipients = createAccounts(3);

        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 100;
        amounts[1] = 200;

        uint256 totalAmounts = 300;

        vm.deal(from, totalAmounts);

        vm.expectRevert(
            abi.encodeWithSelector(
                MismatchedArrayLengths.selector,
                recipients.length,
                amounts.length
            )
        );

        vm.prank(from);
        disperser.disperseEther{value: totalAmounts}(
            recipients,
            amounts,
            totalAmounts
        );
    }

    function testFailDisperseEtherMismatchedArrayLengths() public {
        address from = alice;
        address[] memory recipients = createAccounts(3);

        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 100;
        amounts[1] = 200;

        uint256 totalAmounts = 300;

        vm.deal(from, totalAmounts);

        vm.prank(from);
        disperser.disperseEther{value: totalAmounts}(
            recipients,
            amounts,
            totalAmounts
        );
    }

    function testDisperseEther_revert_InsufficientBalance() public {
        address from = alice;
        address[] memory recipients = createAccounts(3);

        uint256[] memory amounts = new uint256[](3);
        amounts[0] = 100;
        amounts[1] = 200;
        amounts[2] = 300;

        uint256 totalAmounts = 500;
        vm.deal(from, totalAmounts);

        vm.expectRevert(
            abi.encodeWithSelector(
                InsufficientBalance.selector,
                from,
                totalAmounts
            )
        );

        vm.prank(from);
        disperser.disperseEther{value: 400}(recipients, amounts, totalAmounts);
    }

    function testFailDisperseEtherInsufficientBalance() public {
        address from = alice;

        address[] memory recipients = createAccounts(3);

        uint256[] memory amounts = new uint256[](3);
        amounts[0] = 100;
        amounts[1] = 200;
        amounts[2] = 300;

        uint256 totalAmounts = 500;
        vm.deal(from, totalAmounts);

        vm.prank(from);
        disperser.disperseEther{value: 400}(recipients, amounts, totalAmounts);
    }

    function testDisperseEther_revert_bytesInsufficientBalance() public {
        address from = alice;
        address[] memory recipients = createAccounts(5);

        uint256[] memory amounts = new uint256[](5);
        amounts[0] = 100;
        amounts[1] = 200;
        amounts[2] = 300;
        amounts[3] = 400;
        amounts[4] = 500;

        uint256 totalAmounts = 1000;
        vm.deal(from, totalAmounts);

        vm.expectRevert(bytes("Address: insufficient balance"));

        vm.prank(from);
        disperser.disperseEther{value: totalAmounts}(
            recipients,
            amounts,
            totalAmounts
        );
    }

    function testFailDisperseEtherBytesInsufficientBalance() public {
        address from = alice;
        address[] memory recipients = createAccounts(5);

        uint256[] memory amounts = new uint256[](5);
        amounts[0] = 100;
        amounts[1] = 200;
        amounts[2] = 300;
        amounts[3] = 400;
        amounts[4] = 500;

        uint256 totalAmounts = 1000;
        vm.deal(from, totalAmounts);

        vm.prank(from);
        disperser.disperseEther{value: totalAmounts}(
            recipients,
            amounts,
            totalAmounts
        );
    }

    function testFailDisperseEtherOutOfFund() public {
        address from = alice;
        address[] memory recipients = createAccounts(5);

        uint256[] memory amounts = new uint256[](5);
        amounts[0] = 100;
        amounts[1] = 200;
        amounts[2] = 300;
        amounts[3] = 400;
        amounts[4] = 500;

        uint256 totalAmounts = 1500;

        vm.prank(from);
        disperser.disperseEther{value: totalAmounts}(
            recipients,
            amounts,
            totalAmounts
        );
    }

    // Disperse ERC20 ==================

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

    function testDisperseERC20_revert_MismatchedArrayLengths() public {
        address from = alice;
        address[] memory recipients = createAccounts(3);

        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 100;
        amounts[1] = 200;

        uint256 totalAmounts = 300;

        mockERC20.mint(from, totalAmounts);

        vm.expectRevert(
            abi.encodeWithSelector(
                MismatchedArrayLengths.selector,
                recipients.length,
                amounts.length
            )
        );

        vm.prank(from);
        disperser.disperseERC20(mockERC20, recipients, amounts, totalAmounts);
    }

    function testFailDisperseERC20MismatchedArrayLengths() public {
        address from = alice;
        address[] memory recipients = createAccounts(3);

        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 100;
        amounts[1] = 200;

        uint256 totalAmounts = 300;
        mockERC20.mint(from, totalAmounts);

        vm.prank(from);
        disperser.disperseERC20(mockERC20, recipients, amounts, totalAmounts);
    }

    function testDisperseERC20_revert_InsufficientBalance() public {
        address from = alice;
        address[] memory recipients = createAccounts(3);

        uint256[] memory amounts = new uint256[](3);
        amounts[0] = 100;
        amounts[1] = 200;
        amounts[2] = 300;

        uint256 totalAmounts = 500;

        vm.expectRevert(
            abi.encodeWithSelector(
                InsufficientBalance.selector,
                from,
                totalAmounts
            )
        );

        vm.prank(from);
        disperser.disperseERC20(mockERC20, recipients, amounts, totalAmounts);
    }

    function testDisperseERC20_revert_InsufficientAllowance() public {
        address from = alice;
        address[] memory recipients = createAccounts(3);

        uint256[] memory amounts = new uint256[](3);
        amounts[0] = 100;
        amounts[1] = 200;
        amounts[2] = 300;

        uint256 totalAmounts = 500;
        mockERC20.mint(from, totalAmounts);

        vm.expectRevert(bytes("ERC20: insufficient allowance"));

        vm.prank(from);
        disperser.disperseERC20(mockERC20, recipients, amounts, totalAmounts);
    }

    function testDisperseERC20_revert_TransferExceedsBalance() public {
        address from = alice;
        address[] memory recipients = createAccounts(3);

        uint256[] memory amounts = new uint256[](3);
        amounts[0] = 100;
        amounts[1] = 200;
        amounts[2] = 300;

        uint256 totalAmounts = 500;
        mockERC20.mint(from, totalAmounts);

        vm.prank(from);
        mockERC20.approve(address(disperser), type(uint256).max);

        vm.expectRevert(bytes("ERC20: transfer amount exceeds balance"));

        vm.prank(from);
        disperser.disperseERC20(mockERC20, recipients, amounts, totalAmounts);
    }

    function testFailDisperseERC20InsufficientBalance() public {
        address from = alice;

        address[] memory recipients = createAccounts(3);

        uint256[] memory amounts = new uint256[](3);
        amounts[0] = 100;
        amounts[1] = 200;
        amounts[2] = 300;

        uint256 totalAmounts = 500;
        mockERC20.mint(from, totalAmounts);

        vm.prank(from);
        mockERC20.approve(address(disperser), type(uint256).max);

        vm.prank(from);
        disperser.disperseERC20(mockERC20, recipients, amounts, totalAmounts);
    }

    function testFailDisperseERC20InsufficientAllowance() public {
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
        disperser.disperseERC20(mockERC20, recipients, amounts, totalAmounts);
    }

    // Disperse ERC721 ==================

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

    function testDisperseERC721_revert_MismatchedArrayLengths() public {
        address from = alice;

        address[] memory recipients = createAccounts(5);

        uint256[] memory tokenIds = new uint256[](3);
        tokenIds[0] = 100;
        tokenIds[1] = 200;
        tokenIds[2] = 300;

        for (uint index; index < tokenIds.length; index++) {
            mockERC721.mint(from, tokenIds[index]);
        }

        vm.prank(from);
        mockERC721.setApprovalForAll(address(disperser), true);

        vm.expectRevert(
            abi.encodeWithSelector(
                MismatchedArrayLengths.selector,
                recipients.length,
                tokenIds.length
            )
        );

        vm.prank(from);
        disperser.disperseERC721(mockERC721, recipients, tokenIds);
    }

    function testFailDisperseERC721MismatchedArrayLengths() public {
        address from = alice;

        address[] memory recipients = createAccounts(5);

        uint256[] memory tokenIds = new uint256[](3);
        tokenIds[0] = 100;
        tokenIds[1] = 200;
        tokenIds[2] = 300;

        for (uint index; index < tokenIds.length; index++) {
            mockERC721.mint(from, tokenIds[index]);
        }

        vm.prank(from);
        mockERC721.setApprovalForAll(address(disperser), true);

        vm.prank(from);
        disperser.disperseERC721(mockERC721, recipients, tokenIds);
    }

    function testDisperseERC721_revert_TransferFromIncorrectOwner() public {
        address from = alice;

        address[] memory recipients = createAccounts(3);

        uint256[] memory tokenIds = new uint256[](3);
        tokenIds[0] = 100;
        tokenIds[1] = 200;
        tokenIds[2] = 300;

        for (uint index; index < tokenIds.length; index++) {
            mockERC721.mint(from, tokenIds[index]);
        }

        vm.prank(from);
        mockERC721.setApprovalForAll(address(disperser), true);

        vm.expectRevert(bytes("ERC721: transfer from incorrect owner"));

        vm.prank(address(0xbeef));
        disperser.disperseERC721(mockERC721, recipients, tokenIds);
    }

    function testFailDisperseERC721TransferFromIncorrectOwner() public {
        address from = alice;

        address[] memory recipients = createAccounts(3);

        uint256[] memory tokenIds = new uint256[](3);
        tokenIds[0] = 100;
        tokenIds[1] = 200;
        tokenIds[2] = 300;

        for (uint index; index < tokenIds.length; index++) {
            mockERC721.mint(from, tokenIds[index]);
        }

        vm.prank(from);
        mockERC721.setApprovalForAll(address(disperser), true);

        vm.prank(address(0xbeef));
        disperser.disperseERC721(mockERC721, recipients, tokenIds);
    }

    function testDisperseERC721_revert_InvalidTokenId() public {
        address from = alice;

        address[] memory recipients = createAccounts(3);

        uint256[] memory tokenIds = new uint256[](3);
        tokenIds[0] = 100; // non existing tokenId

        vm.prank(from);
        mockERC721.setApprovalForAll(address(disperser), true);

        vm.expectRevert(bytes("ERC721: invalid token ID"));

        vm.prank(from);
        disperser.disperseERC721(mockERC721, recipients, tokenIds);
    }

    function testFailDisperseERC721InvalidTokenId() public {
        address from = alice;

        address[] memory recipients = createAccounts(3);

        uint256[] memory tokenIds = new uint256[](3);
        tokenIds[0] = 100; // non existing tokenId

        vm.prank(from);
        mockERC721.setApprovalForAll(address(disperser), true);

        vm.prank(from);
        disperser.disperseERC721(mockERC721, recipients, tokenIds);
    }

    function testDisperseERC721_revert_TokenNotOwnerOrApproved() public {
        address from = alice;

        address[] memory recipients = createAccounts(3);

        uint256[] memory tokenIds = new uint256[](3);
        tokenIds[0] = 100; // non existing tokenId

        mockERC721.mint(address(0xbeef), tokenIds[0]);

        vm.expectRevert(bytes("ERC721: caller is not token owner or approved"));

        vm.prank(from);
        disperser.disperseERC721(mockERC721, recipients, tokenIds);
    }

    function testFailDisperseERC721TokenNotOwnerOrApproved() public {
        address from = alice;

        address[] memory recipients = createAccounts(3);

        uint256[] memory tokenIds = new uint256[](3);
        tokenIds[0] = 100; // non existing tokenId

        mockERC721.mint(address(0xbeef), tokenIds[0]);

        vm.prank(from);
        disperser.disperseERC721(mockERC721, recipients, tokenIds);
    }

    // Disperse ERC1155 ==================

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

    function testDisperseERC1155_revert_MismatchedArrayLengths_IDs() public {
        address from = alice;

        address[] memory recipients = createAccounts(5);

        uint256[] memory ids = new uint256[](3);
        ids[0] = 1337;
        ids[1] = 1338;
        ids[2] = 1339;

        uint256[] memory mintAmounts = new uint256[](3);
        mintAmounts[0] = 100;
        mintAmounts[1] = 200;
        mintAmounts[2] = 300;

        uint256[] memory transferAmounts = new uint256[](5);
        transferAmounts[0] = 50;
        transferAmounts[1] = 100;
        transferAmounts[2] = 150;
        transferAmounts[3] = 200;
        transferAmounts[3] = 250;

        mockERC1155.mintBatch(from, ids, mintAmounts);

        vm.prank(from);
        mockERC1155.setApprovalForAll(address(disperser), true);

        vm.expectRevert(
            abi.encodeWithSelector(
                MismatchedArrayLengths.selector,
                recipients.length,
                ids.length
            )
        );

        vm.prank(from);
        disperser.disperseERC1155(
            mockERC1155,
            recipients,
            ids,
            transferAmounts
        );
    }

    function tesFailtDisperseERC1155MismatchedArrayLengthsIDs() public {
        address from = alice;

        address[] memory recipients = createAccounts(5);

        uint256[] memory ids = new uint256[](3);
        ids[0] = 1337;
        ids[1] = 1338;
        ids[2] = 1339;

        uint256[] memory mintAmounts = new uint256[](3);
        mintAmounts[0] = 100;
        mintAmounts[1] = 200;
        mintAmounts[2] = 300;

        uint256[] memory transferAmounts = new uint256[](5);
        transferAmounts[0] = 50;
        transferAmounts[1] = 100;
        transferAmounts[2] = 150;
        transferAmounts[3] = 200;
        transferAmounts[3] = 250;

        mockERC1155.mintBatch(from, ids, mintAmounts);

        vm.prank(from);
        mockERC1155.setApprovalForAll(address(disperser), true);

        vm.prank(from);
        disperser.disperseERC1155(
            mockERC1155,
            recipients,
            ids,
            transferAmounts
        );
    }

    function testDisperseERC1155_revert_MismatchedArrayLengths_TransferAmounts()
        public
    {
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

        uint256[] memory transferAmounts = new uint256[](3);
        transferAmounts[0] = 50;
        transferAmounts[1] = 100;
        transferAmounts[2] = 150;

        mockERC1155.mintBatch(from, ids, mintAmounts);

        vm.prank(from);
        mockERC1155.setApprovalForAll(address(disperser), true);

        vm.expectRevert(
            abi.encodeWithSelector(
                MismatchedArrayLengths.selector,
                recipients.length,
                transferAmounts.length
            )
        );

        vm.prank(from);
        disperser.disperseERC1155(
            mockERC1155,
            recipients,
            ids,
            transferAmounts
        );
    }

    function testFailDisperseERC1155MismatchedArrayLengthsTransferAmounts()
        public
    {
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

        uint256[] memory transferAmounts = new uint256[](3);
        transferAmounts[0] = 50;
        transferAmounts[1] = 100;
        transferAmounts[2] = 150;

        mockERC1155.mintBatch(from, ids, mintAmounts);

        vm.prank(from);
        mockERC1155.setApprovalForAll(address(disperser), true);

        vm.prank(from);
        disperser.disperseERC1155(
            mockERC1155,
            recipients,
            ids,
            transferAmounts
        );
    }

    function testDisperseERC1155_revert_InsufficientBalance() public {
        address from = alice;

        address[] memory recipients = createAccounts(1);

        uint256[] memory ids = new uint256[](1);
        ids[0] = 1337;

        uint256[] memory mintAmounts = new uint256[](1);
        mintAmounts[0] = 100;

        uint256[] memory transferAmounts = new uint256[](1);
        transferAmounts[0] = 50;

        mockERC1155.mintBatch(from, ids, mintAmounts);

        vm.prank(address(0xbeef));
        mockERC1155.setApprovalForAll(address(disperser), true);

        vm.expectRevert(bytes("ERC1155: insufficient balance for transfer"));

        vm.prank(address(0xbeef));
        disperser.disperseERC1155(
            mockERC1155,
            recipients,
            ids,
            transferAmounts
        );
    }

    function testFailDisperseERC1155InsufficientBalance() public {
        address from = alice;

        address[] memory recipients = createAccounts(1);

        uint256[] memory ids = new uint256[](1);
        ids[0] = 1337;

        uint256[] memory mintAmounts = new uint256[](1);
        mintAmounts[0] = 100;

        uint256[] memory transferAmounts = new uint256[](1);
        transferAmounts[0] = 50;

        mockERC1155.mintBatch(from, ids, mintAmounts);

        vm.prank(address(0xbeef));
        mockERC1155.setApprovalForAll(address(disperser), true);

        vm.prank(address(0xbeef));
        disperser.disperseERC1155(
            mockERC1155,
            recipients,
            ids,
            transferAmounts
        );
    }

    function testDisperseERC1155_revert_NotOwnerOrApproved() public {
        address from = alice;

        address[] memory recipients = createAccounts(1);
        uint256[] memory ids = new uint256[](1);
        ids[0] = 1337;

        uint256[] memory mintAmounts = new uint256[](1);
        mintAmounts[0] = 100;

        uint256[] memory transferAmounts = new uint256[](1);
        transferAmounts[0] = 50;

        mockERC1155.mintBatch(from, ids, mintAmounts);

        vm.expectRevert(
            bytes("ERC1155: caller is not token owner or approved")
        );

        vm.prank(address(0xbeef));
        disperser.disperseERC1155(
            mockERC1155,
            recipients,
            ids,
            transferAmounts
        );
    }

    function testFailDisperseERC1155NotOwnerOrApproved() public {
        address from = alice;

        address[] memory recipients = createAccounts(1);
        uint256[] memory ids = new uint256[](1);
        ids[0] = 1337;

        uint256[] memory mintAmounts = new uint256[](1);
        mintAmounts[0] = 100;

        uint256[] memory transferAmounts = new uint256[](1);
        transferAmounts[0] = 50;

        mockERC1155.mintBatch(from, ids, mintAmounts);

        vm.prank(address(0xbeef));
        disperser.disperseERC1155(
            mockERC1155,
            recipients,
            ids,
            transferAmounts
        );
    }

    function testDisperseERC1155TransferNonExistingToken() public {
        address from = alice;

        address[] memory recipients = createAccounts(1);
        uint256[] memory ids = new uint256[](1);
        ids[0] = 1337;

        uint256[] memory mintAmounts = new uint256[](1);
        mintAmounts[0] = 100;

        uint256[] memory transferAmounts = new uint256[](1);
        transferAmounts[0] = 50;

        vm.prank(from);
        mockERC1155.setApprovalForAll(address(disperser), true);

        vm.expectRevert(bytes("ERC1155: insufficient balance for transfer"));

        vm.prank(from);
        disperser.disperseERC1155(
            mockERC1155,
            recipients,
            ids,
            transferAmounts
        );
    }

    function testFailDisperseERC1155TransferNonExistingToken() public {
        address from = alice;

        address[] memory recipients = createAccounts(1);
        uint256[] memory ids = new uint256[](1);
        ids[0] = 1337;

        uint256[] memory mintAmounts = new uint256[](1);
        mintAmounts[0] = 100;

        uint256[] memory transferAmounts = new uint256[](1);
        transferAmounts[0] = 50;

        vm.prank(from);
        mockERC1155.setApprovalForAll(address(disperser), true);

        vm.prank(from);
        disperser.disperseERC1155(
            mockERC1155,
            recipients,
            ids,
            transferAmounts
        );
    }

    // FUZZ: disperseEther

    function testDisperseEther(
        address from,
        uint256 numberOfRecipients,
        uint256[] memory amounts
    ) public {
        if (from == address(0) || from.isContract()) from = alice;

        uint256 minRecipients = bound(numberOfRecipients, 3000, 5000);
        address[] memory recipients = createAccounts(minRecipients);

        if (amounts.length == 0) return;

        uint256 mintLength = min2(recipients.length, amounts.length);

        address[] memory normalizeRecipients = new address[](mintLength);
        uint256[] memory normalizeAmounts = new uint256[](mintLength);

        uint256 totalAmounts = 0;
        for (uint i; i < mintLength; i++) {
            uint256 remainingMintAmount = type(uint256).max - totalAmounts;

            uint256 minAmount = bound(amounts[i], 0, remainingMintAmount);

            normalizeRecipients[i] = recipients[i];
            normalizeAmounts[i] = minAmount;

            totalAmounts += minAmount;
        }

        vm.deal(from, totalAmounts);

        vm.expectEmit(true, true, false, true, address(disperser));
        emit EtherDispersed(from, normalizeRecipients, normalizeAmounts);

        vm.prank(from);
        disperser.disperseEther{value: totalAmounts}(
            normalizeRecipients,
            normalizeAmounts,
            totalAmounts
        );
    }

    // FUZZ: disperseERC20

    function testDisperseERC20(
        address from,
        address[] memory recipients,
        uint256[] memory amounts
    ) public {
        if (from == address(0) || from.isContract()) from = alice;

        address[] memory nonZeroRecipeints = nonZeroArrayAddress(recipients);

        if (nonZeroRecipeints.length == 0 || amounts.length == 0) return;

        uint256 mintLength = min2(nonZeroRecipeints.length, amounts.length);

        address[] memory normalizeRecipients = new address[](mintLength);
        uint256[] memory normalizeAmounts = new uint256[](mintLength);

        uint256 totalAmounts = 0;
        for (uint i; i < mintLength; i++) {
            uint256 remainingMintAmount = type(uint256).max - totalAmounts;

            uint256 minAmount = bound(amounts[i], 0, remainingMintAmount);

            normalizeRecipients[i] = nonZeroRecipeints[i];
            normalizeAmounts[i] = minAmount;

            totalAmounts += minAmount;
        }

        mockERC20.mint(from, totalAmounts);

        vm.prank(from);
        mockERC20.approve(address(disperser), type(uint256).max);

        vm.expectEmit(true, true, false, true, address(disperser));
        emit ERC20Dispersed(
            address(mockERC20),
            from,
            normalizeRecipients,
            normalizeAmounts
        );

        vm.prank(from);
        disperser.disperseERC20(
            mockERC20,
            normalizeRecipients,
            normalizeAmounts,
            totalAmounts
        );
    }

    // FUZZ: disperse721
    function testDisperseERC721(
        address from,
        address[] memory recipients,
        uint256 numberOfIds
    ) public {
        if (from == address(0) || from.isContract()) from = alice;

        address[] memory nonZeroRecipients = nonZeroArrayAddress(recipients);

        uint idsSize = bound(numberOfIds, 3000, 5000);
        uint256[] memory ids = new uint256[](idsSize);
        for (uint n; n < ids.length; n++) {
            ids[n] = n + 1;
        }

        uint256 mintLength = min2(nonZeroRecipients.length, ids.length);

        address[] memory normalizeRecipients = new address[](mintLength);
        uint256[] memory normalizeTokenIds = new uint256[](mintLength);

        for (uint256 n; n < normalizeRecipients.length; n++) {
            normalizeRecipients[n] = nonZeroRecipients[n];
            normalizeTokenIds[n] = ids[n];
        }

        for (uint index; index < normalizeTokenIds.length; index++) {
            mockERC721.mint(from, normalizeTokenIds[index]);
        }

        vm.prank(from);
        mockERC721.setApprovalForAll(address(disperser), true);

        vm.expectEmit(true, true, false, true, address(disperser));
        emit ERC721Dispersed(
            address(mockERC721),
            from,
            normalizeRecipients,
            normalizeTokenIds
        );

        vm.prank(from);
        disperser.disperseERC721(
            mockERC721,
            normalizeRecipients,
            normalizeTokenIds
        );

        for (uint256 n; n < nonZeroRecipients.length; ++n) {
            assertEq(
                mockERC721.ownerOf(normalizeTokenIds[n]),
                normalizeRecipients[n]
            );
        }
    }

    // FUZZ: disperseERC1155

    function testDisperseERC1155(
        address from,
        uint256[] memory mintAmounts,
        uint256[] memory transferAmounts,
        uint256 numberOfIds
    ) public {
        if (from == address(0) || from.isContract()) from = alice;

        uint idsSize = bound(numberOfIds, 3000, 5000);
        uint256[] memory ids = new uint256[](idsSize);
        for (uint n; n < ids.length; n++) {
            ids[n] = n + 1;
        }

        uint256 minLength = min3(
            ids.length,
            mintAmounts.length,
            transferAmounts.length
        );

        uint256[] memory normalizedIds = new uint256[](minLength);
        uint256[] memory normalizedMintAmounts = new uint256[](minLength);
        uint256[] memory normalizedTransferAmounts = new uint256[](minLength);
        address[] memory normalizedRecipients = createAccounts(minLength);

        for (uint256 i = 0; i < minLength; i++) {
            uint256 id = ids[i];

            uint256 remainingMintAmountForId = type(uint256).max -
                userMintAmounts[from][id];

            uint256 mintAmount = bound(
                mintAmounts[i],
                1,
                remainingMintAmountForId
            );
            uint256 transferAmount = bound(transferAmounts[i], 1, mintAmount);

            normalizedIds[i] = id;
            normalizedMintAmounts[i] = mintAmount;
            normalizedTransferAmounts[i] = transferAmount;
        }

        mockERC1155.mintBatch(from, normalizedIds, normalizedMintAmounts);

        vm.prank(from);
        mockERC1155.setApprovalForAll(address(disperser), true);

        vm.expectEmit(true, true, false, true, address(disperser));
        emit ERC1155Dispersed(
            address(mockERC1155),
            from,
            normalizedRecipients,
            normalizedIds,
            normalizedTransferAmounts
        );

        vm.prank(from);
        disperser.disperseERC1155(
            mockERC1155,
            normalizedRecipients,
            normalizedIds,
            normalizedTransferAmounts
        );

        for (uint256 n; n < normalizedRecipients.length; ++n) {
            assertEq(
                mockERC1155.balanceOf(
                    normalizedRecipients[n],
                    normalizedIds[n]
                ),
                normalizedTransferAmounts[n]
            );

            assertEq(
                mockERC1155.balanceOf(from, ids[n]),
                normalizedMintAmounts[n] - normalizedTransferAmounts[n]
            );
        }
    }
}
