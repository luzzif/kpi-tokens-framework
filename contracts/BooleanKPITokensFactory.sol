pragma solidity ^0.8.4;

import "erc1155-to-erc20-wrapper-contracts/interfaces/IERC1155PositionWrapperFactory.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "./interfaces/ICTF.sol";
import "./libraries/CTF.sol";

/**
 * @title BooleanKPITokensFactory
 * @dev BooleanKPITokensFactory contract
 * @author Federico Luzzi - <fedeluzzi00@gmail.com>
 * SPDX-License-Identifier: GPL-3.0
 */
contract BooleanKPITokensFactory is IERC1155Receiver {
    using SafeERC20 for IERC20;

    ICTF conditionalTokensFramework;
    IERC1155PositionWrapperFactory erc1155PositionWrapperFactory;
    address wrapperImplementation;

    event KpiTokensCreated(address collector);

    constructor(
        address _conditionalTokensFrameworkAddress,
        address _erc1155PositionWrapperFactory
    ) {
        conditionalTokensFramework = ICTF(_conditionalTokensFrameworkAddress);
        erc1155PositionWrapperFactory = IERC1155PositionWrapperFactory(
            _erc1155PositionWrapperFactory
        );
        wrapperImplementation = IERC1155PositionWrapperFactory(
            _erc1155PositionWrapperFactory
        )
            .implementation();
    }

    function supportsInterface(bytes4 interfaceId)
        external
        pure
        override
        returns (bool)
    {
        return interfaceId == type(IERC1155Receiver).interfaceId;
    }

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        return bytes4("");
    }

    function onERC1155BatchReceived(
        address _operator,
        address _from,
        uint256[] calldata _positionIds,
        uint256[] calldata _amounts,
        bytes calldata
    ) external view override returns (bytes4) {
        require(_operator == address(this), "TODO");
        return IERC1155Receiver(address(0)).onERC1155BatchReceived.selector;
    }

    function createBooleanKpiTokens(
        address _oracle,
        bytes32 _questionId,
        address _collateralToken,
        uint256 _collateralAmount,
        string[] memory _tokenNames,
        string[] memory _tokenSymbols
    ) external {
        require(_oracle != address(0), "TODO");
        require(_questionId != bytes32(""), "TODO");
        require(_collateralToken != address(0), "TODO");
        require(_collateralAmount > 0, "TODO");
        require(_tokenNames.length == 2 && _tokenSymbols.length == 2, "TODO");

        // preparing condition
        conditionalTokensFramework.prepareCondition(
            _oracle,
            _questionId,
            uint256(2)
        );
        bytes32 _conditionId =
            CTF.getConditionId(_oracle, _questionId, uint256(2));

        // preparing partition so that a position can only be taken on outcome A or B
        uint256[] memory _partitions = new uint256[](2);
        _partitions[0] = 1;
        _partitions[1] = 2;

        // transferring collateral from caller to contract
        IERC20(_collateralToken).safeTransferFrom(
            msg.sender,
            address(this),
            _collateralAmount
        );

        // approving collateral to ctf
        IERC20(_collateralToken).safeIncreaseAllowance(
            address(conditionalTokensFramework),
            _collateralAmount
        );

        // minting ERC1155 tokens for each of the outcomes, backed by the given collateral
        conditionalTokensFramework.splitPosition(
            _collateralToken,
            bytes32(""),
            _conditionId,
            _partitions,
            _collateralAmount
        );

        // for each of the outcomes
        for (uint8 _i = 0; _i < 2; _i++) {
            // creating ERC20 wrapper
            uint256 _positionId =
                CTF.getPositionId(
                    _collateralToken,
                    CTF.getCollectionId(
                        bytes32(""),
                        _conditionId,
                        _partitions[_i]
                    )
                );
            erc1155PositionWrapperFactory.createWrapper(
                _tokenNames[_i],
                _tokenSymbols[_i],
                _positionId
            );

            // wrapping the tokens
            address _wrapperAddress =
                Clones.predictDeterministicAddress(
                    wrapperImplementation,
                    keccak256(abi.encodePacked(_positionId)),
                    address(erc1155PositionWrapperFactory)
                );
            conditionalTokensFramework.setApprovalForAll(msg.sender, true);
            conditionalTokensFramework.safeTransferFrom(
                address(this),
                _wrapperAddress,
                _positionId,
                _collateralAmount,
                bytes("")
            );

            // sending wrapped tokens to sender
            IERC20(_wrapperAddress).transfer(msg.sender, _collateralAmount);
        }
    }
}
