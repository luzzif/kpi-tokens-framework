pragma solidity >=0.8.4;

/**
 * @title ICTF
 * @dev ICTF interface
 * @author Federico Luzzi - <fedeluzzi00@gmail.com>
 * SPDX-License-Identifier: GPL-3.0
 */
interface ICTF {
    function prepareCondition(
        address _oracle,
        bytes32 _questionId,
        uint256 _outcomeSlotCount
    ) external;

    function reportPayouts(bytes32 _questionId, uint256[] calldata _payouts)
        external;

    function splitPosition(
        address _collateralToken,
        bytes32 _parentCollectionId,
        bytes32 _conditionId,
        uint256[] calldata _partition,
        uint256 _amount
    ) external;

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _id,
        uint256 _value,
        bytes calldata _data
    ) external;

    function redeemPositions(
        address _collateralToken,
        bytes32 _parentCollectionId,
        bytes32 _conditionId,
        uint256[] calldata _indexSets
    ) external;
}
