pragma solidity ^0.8.4;

import "../interfaces/IOracle.sol";
import "../interfaces/oracles/IReality.sol";

/**
 * @title Reality
 * @dev Reality contract
 * @author Federico Luzzi - <fedeluzzi00@gmail.com>
 * SPDX-License-Identifier: GPL-3.0
 */
contract Reality is IOracle {
    IReality public reality;

    constructor(address _reality) {
        reality = IReality(_reality);
    }

    function submitKpi(bytes memory _data) external override returns (bytes32) {
        (
            string memory _question,
            address _arbitrator,
            uint32 _timeout,
            uint32 _openingTs,
            uint256 _nonce
        ) = abi.decode(_data, (string, address, uint32, uint32, uint256));
        return
            reality.askQuestion(
                0,
                _question,
                _arbitrator,
                _timeout,
                _openingTs,
                _nonce
            );
    }

    function kpiReached(bytes32 _kpiId) external override returns (bool) {
        return uint256(reality.resultFor(_kpiId)) == 1;
    }
}
