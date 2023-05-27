// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    constructor() ERC20("MockERC20", "MockERC20") {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function mintBatch(
        address[] calldata recipients,
        uint256[] calldata amounts
    ) external {
        for (uint n; n < amounts.length; ++n) {
            _mint(recipients[n], amounts[n]);
        }
    }
}
