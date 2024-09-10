// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./base/MintableToken.sol";

contract MOVETokenV2 is MintableToken {
    /**
     * @dev Initialize the contract
     */
    function initialize() public initializer {
        __MintableToken_init("Movement", "MOVE");
        _mint(address(msg.sender), 10000000000 * 10 ** decimals());
    }

    function decimals() public pure override returns (uint8) {
        return 8;
    }
}
