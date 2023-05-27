// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Address.sol";

import "./interfaces/IMultiTokenDisperser.sol";

contract MultiTokenDisperser is IMultiTokenDisperser {
    using Address for address;

    function disperseERC721(
        IERC721 token,
        address[] calldata recipients,
        uint256[] calldata tokenIds
    ) external override {
        _validateRecipientsAndTokens(recipients, tokenIds);

        for (uint256 i = 0; i < recipients.length; i++) {
            token.safeTransferFrom(msg.sender, recipients[i], tokenIds[i]);
        }

        emit ERC721Dispersed(address(token), msg.sender, recipients, tokenIds);
    }

    function disperseERC1155(
        IERC1155 token,
        address[] calldata recipients,
        uint256[] calldata tokenIds,
        uint256[] calldata amounts
    ) external override {
        _validateRecipientsAndTokens(recipients, tokenIds);
        _validateRecipientsAndAmounts(recipients, amounts);

        for (uint256 i = 0; i < recipients.length; i++) {
            token.safeTransferFrom(
                msg.sender,
                recipients[i],
                tokenIds[i],
                amounts[i],
                ""
            );
        }

        emit ERC1155Dispersed(
            address(token),
            msg.sender,
            recipients,
            tokenIds,
            amounts
        );
    }

    function disperseERC20(
        IERC20 token,
        address[] calldata recipients,
        uint256[] calldata amounts,
        uint256 total
    ) external override {
        _validateRecipientsAndAmounts(recipients, amounts);

        if (token.balanceOf(msg.sender) < total) {
            revert InsufficientBalance(msg.sender, total);
        }

        for (uint256 i = 0; i < recipients.length; i++) {
            bool success = token.transferFrom(
                msg.sender,
                recipients[i],
                amounts[i]
            );
            require(success, "MultiTokenDisperser: ERC20 transfer failed");
        }

        emit ERC20Dispersed(address(token), msg.sender, recipients, amounts);
    }

    function disperseEther(
        address[] calldata recipients,
        uint256[] calldata amounts,
        uint256 total
    ) external payable override {
        _validateRecipientsAndTokens(recipients, amounts);

        if (msg.value != total) {
            revert InsufficientBalance(msg.sender, total);
        }

        for (uint256 i = 0; i < recipients.length; i++) {
            Address.sendValue(payable(recipients[i]), amounts[i]);
        }

        emit EtherDispersed(msg.sender, recipients, amounts);
    }

    function _validateRecipientsAndTokens(
        address[] memory recipients,
        uint256[] memory tokenIds
    ) internal pure {
        _validateArrayLength(recipients, tokenIds);
    }

    function _validateRecipientsAndAmounts(
        address[] memory recipients,
        uint256[] memory amounts
    ) internal pure {
        _validateArrayLength(recipients, amounts);
    }

    function _validateArrayLength(
        address[] memory recipients,
        uint256[] memory values
    ) internal pure {
        if (recipients.length != values.length) {
            revert MismatchedArrayLengths(recipients.length, values.length);
        }
    }

    function _validateSufficientBalance(
        IERC20 token,
        address sender,
        uint256 total
    ) internal view {
        if (token.balanceOf(sender) < total) {
            revert InsufficientBalance(sender, total);
        }
    }
}
