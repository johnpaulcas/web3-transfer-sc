// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import {BaseTest} from "./BaseTest.sol";

abstract contract BaseMultiTokenDisperserTest is BaseTest {
    error InsufficientBalance(address account, uint256 required);
    error MismatchedArrayLengths(
        uint256 recipientsLength,
        uint256 tokenIdsLength
    );

    event EtherDispersed(
        address indexed from,
        address[] indexed to,
        uint256[] amount
    );

    event ERC20Dispersed(
        address indexed token,
        address indexed from,
        address[] indexed to,
        uint256[] amount
    );

    event ERC721Dispersed(
        address indexed token,
        address indexed from,
        address[] indexed to,
        uint256[] tokenId
    );

    event ERC1155Dispersed(
        address indexed token,
        address indexed from,
        address[] indexed to,
        uint256[] tokenId,
        uint256[] amount
    );
}
