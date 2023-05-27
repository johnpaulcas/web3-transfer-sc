// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title IMultiTokenDisperser
/// @notice This is the interface for the MultiTokenDisperser contract.
/// @dev This contract can be used to disperse multiple types of tokens (ERC721, ERC1155, ERC20) or Ether to multiple recipients.
interface IMultiTokenDisperser {
    /// @notice Errors that describe failings of token dispersals
    error InsufficientBalance(address account, uint256 required);
    error MismatchedArrayLengths(
        uint256 recipientsLength,
        uint256 tokenIdsLength
    );

    /// @notice Emitted when ERC721 tokens are dispersed
    event ERC721Dispersed(
        address indexed token,
        address indexed from,
        address[] indexed to,
        uint256[] tokenId
    );

    /// @notice Emitted when ERC1155 tokens are dispersed
    event ERC1155Dispersed(
        address indexed token,
        address indexed from,
        address[] indexed to,
        uint256[] tokenId,
        uint256[] amount
    );

    /// @notice Emitted when ERC20 tokens are dispersed
    event ERC20Dispersed(
        address indexed token,
        address indexed from,
        address[] indexed to,
        uint256[] amount
    );

    /// @notice Emitted when Ether is dispersed
    event EtherDispersed(
        address indexed from,
        address[] indexed to,
        uint256[] amount
    );

    /// @notice Disperse ERC721 tokens to multiple recipients.
    /// @dev The calling account must own the tokens being dispersed. The function will revert if the ownership conditions are not met.
    ///     This function emits an {ERC721Dispersed} event.
    /// @param token The ERC721 token to disperse
    /// @param recipients The addresses of the recipients
    /// @param tokenIds The IDs of the tokens to disperse
    function disperseERC721(
        IERC721 token,
        address[] calldata recipients,
        uint256[] calldata tokenIds
    ) external;

    /// @notice Disperse ERC1155 tokens to multiple recipients.
    /// @dev The calling account must own enough of the token being dispersed. The function will revert if the ownership conditions are not met.
    ///     This function emits an {ERC1155Dispersed} event.
    /// @param token The ERC1155 token to disperse
    /// @param recipients The addresses of the recipients
    /// @param tokenIds The IDs of the tokens to disperse
    /// @param amounts The amounts of each token to disperse
    function disperseERC1155(
        IERC1155 token,
        address[] calldata recipients,
        uint256[] calldata tokenIds,
        uint256[] calldata amounts
    ) external;

    /// @notice Disperse ERC20 tokens to multiple recipients.
    /// @dev The calling account must own enough tokens to cover the total amount being dispersed. The function will revert if the ownership conditions are not met.
    ///     This function emits an {ERC20Dispersed} event.
    /// @param token The ERC20 token to disperse
    /// @param recipients The addresses of the recipients
    /// @param amounts The amounts of tokens to disperse to each recipient
    /// @param total The total amount of tokens being dispersed. This must be equal to the sum of all individual amounts.
    function disperseERC20(
        IERC20 token,
        address[] calldata recipients,
        uint256[] calldata amounts,
        uint256 total
    ) external;

    /// @notice Disperse Ether to multiple recipients.
    /// @dev The calling account must have enough Ether to cover the total amount being dispersed. The function will revert if the balance conditions are not met.
    ///     This function emits an {EtherDispersed} event.
    /// @param recipients The addresses of the recipients
    /// @param amounts The amounts of Ether to disperse to each recipient
    /// @param total The total amount of Ether being dispersed. This must be equal to the sum of all individual amounts.
    function disperseEther(
        address[] calldata recipients,
        uint256[] calldata amounts,
        uint256 total
    ) external payable;
}
