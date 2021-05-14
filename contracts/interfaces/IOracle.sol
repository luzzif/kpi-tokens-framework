pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

/**
 * @title IOracle
 * @dev IOracle contract
 * @author Federico Luzzi - <fedeluzzi00@gmail.com>
 * SPDX-License-Identifier: GPL-3.0
 */
interface IOracle {
    function submitKpi(bytes memory _data) external returns (bytes32);

    function kpiReached(bytes32 _id) external returns (bool);
}
