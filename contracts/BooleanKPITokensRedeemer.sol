pragma solidity ^0.8.4;

import "erc1155-to-erc20-wrapper-contracts/interfaces/IERC1155PositionWrapperFactory.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "./interfaces/ICTF.sol";
import "./libraries/CTF.sol";

/**
 * @title KPITokensFactory
 * @dev KPITokensFactory contract
 * @author Federico Luzzi - <fedeluzzi00@gmail.com>
 * SPDX-License-Identifier: GPL-3.0
 */
contract KPITokensRedeemer {
    ICTF conditionalTokensFramework;
    address wrapperImplementation;

    event KpiTokensCreated(address collector);

    constructor(
        address _conditionalTokensFrameworkAddress,
        address _erc1155PositionWrapperFactory
    ) {
        conditionalTokensFramework = ICTF(_conditionalTokensFrameworkAddress);
        wrapperImplementation = IERC1155PositionWrapperFactory(
            _erc1155PositionWrapperFactory
        )
            .implementation();
    }

    function redeem(
        address _oracle,
        bytes32 _questionId,
        address _collateralToken
    ) external {
        require(_oracle != address(0), "TODO");
        require(_questionId != bytes32(""), "TODO");
        require(_collateralToken != address(0), "TODO");

        uint256[] memory _partitions = new uint256[](2);
        _partitions[0] = 1; // 0b01: represents outcome B
        _partitions[1] = 2; // 0b10: represents outcome A

        conditionalTokensFramework.redeemPositions(
            _collateralToken,
            bytes32(""),
            CTF.getConditionId(_oracle, _questionId, uint256(2)),
            _partitions
        );
    }
}
