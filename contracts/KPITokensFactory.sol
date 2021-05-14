pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "./interfaces/IOracle.sol";
import "./interfaces/IKPIToken.sol";

/**
 * @title KPITokensFactory
 * @dev KPITokensFactory contract
 * @author Federico Luzzi - <fedeluzzi00@gmail.com>
 * SPDX-License-Identifier: GPL-3.0
 */
contract KPITokensFactory is Ownable {
    using SafeERC20 for IERC20;

    address kpiTokenImplementation;
    IOracle oracle;

    event KpiTokenCreated(address kpiToken);

    constructor(address _kpiTokenImplementation, address _oracle) {
        kpiTokenImplementation = _kpiTokenImplementation;
        oracle = IOracle(_oracle);
    }

    function upgradeKpiTokenImplementation(address _kpiTokenImplementation)
        external
        onlyOwner
    {
        kpiTokenImplementation = _kpiTokenImplementation;
    }

    function createKpiToken(
        address _collateralToken,
        uint256 _collateralAmount,
        string memory _name,
        string memory _symbol,
        uint256 _totalSupply,
        bytes memory _oracleData
    ) external {
        require(_collateralToken != address(0), "TODO");
        require(_collateralAmount > 0, "TODO");
        require(bytes(_name).length > 0, "TODO");
        require(bytes(_symbol).length > 0, "TODO");
        require(_oracleData.length > 0, "TODO");

        // create KPI token immutable clone
        address _kpiTokenProxy = Clones.clone(kpiTokenImplementation);

        // transfer collateral from user to KPI token
        IERC20(_collateralToken).safeTransferFrom(
            msg.sender,
            address(_kpiTokenProxy),
            _collateralAmount
        );

        // asking the KPI question to the oracle
        bytes32 _kpiId = oracle.submitKpi(_oracleData);

        // initialize KPI token
        IKPIToken(_kpiTokenProxy).initialize(
            _kpiId,
            address(oracle),
            _name,
            _symbol,
            _totalSupply,
            _collateralToken,
            msg.sender
        );

        emit KpiTokenCreated(_kpiTokenProxy);
    }
}
