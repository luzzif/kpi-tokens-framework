pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

/**
 * @title IKPIToken
 * @dev IKPIToken contract
 * @author Federico Luzzi - <fedeluzzi00@gmail.com>
 * SPDX-License-Identifier: GPL-3.0
 */
interface IKPIToken is IERC20Upgradeable {
    function initialize(
        bytes32 _kpiId,
        address _oracle,
        string calldata _name,
        string calldata _symbol,
        uint256 _totalSupply,
        address _collateralToken,
        address _creator
    ) external;
}
