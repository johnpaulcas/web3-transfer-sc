// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MockERC721 is ERC721 {
    constructor() ERC721("MockERC721", "MockERC721") {}

    function mint(address to, uint256 tokenId) external {
        _mint(to, tokenId);
    }

    function mintBatch(
        address[] calldata recipients,
        uint256[] calldata tokenIds
    ) external {
        for (uint n; n < tokenIds.length; ++n) {
            _mint(recipients[n], tokenIds[n]);
        }
    }

    function safeMint(address to, uint256 tokenId) external {
        _safeMint(to, tokenId);
    }
}
