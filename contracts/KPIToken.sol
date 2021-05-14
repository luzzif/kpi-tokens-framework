pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "./interfaces/IOracle.sol";

/**
 * @title KPIToken
 * @dev KPIToken contract
 * @author Federico Luzzi - <fedeluzzi00@gmail.com>
 * SPDX-License-Identifier: GPL-3.0
 */
contract KPIToken is Initializable, ERC20Upgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    bytes32 public kpiId;
    IOracle public oracle;
    IERC20Upgradeable public collateralToken;
    address public creator;
    bool public kpiReached;
    bool public finalized;

    event Initialized(
        bytes32 kpiId,
        string name,
        string symbol,
        uint256 totalSupply,
        address oracle,
        address collateralToken,
        address creator
    );
    event Finalized(bool response);
    event Redeemed(uint256 burnedTokens, uint256 redeemedCollateral);

    function initialize(
        bytes32 _kpiId,
        address _oracle,
        string calldata _name,
        string calldata _symbol,
        uint256 _totalSupply,
        address _collateralToken,
        address _creator
    ) external initializer {
        require(_kpiId != bytes32(""), "TODO");
        require(_oracle != address(0), "TODO");
        require(bytes(_name).length > 0, "TODO");
        require(bytes(_symbol).length > 0, "TODO");
        require(_totalSupply > 0, "TODO");
        require(_collateralToken != address(0), "TODO");
        require(_creator != address(0), "TODO");
        require(
            IERC20Upgradeable(_collateralToken).balanceOf(address(this)) > 0,
            "TODO"
        );

        __ERC20_init(_name, _symbol);
        _mint(_creator, _totalSupply);
        kpiId = _kpiId;
        oracle = IOracle(_oracle);
        collateralToken = IERC20Upgradeable(_collateralToken);
        creator = _creator;

        emit Initialized(
            _kpiId,
            _name,
            _symbol,
            _totalSupply,
            _oracle,
            _collateralToken,
            _creator
        );
    }

    function finalize() external {
        if (!oracle.kpiReached(kpiId)) {
            collateralToken.safeTransfer(
                creator,
                collateralToken.balanceOf(address(this))
            );
        } else {
            kpiReached = true;
        }
        finalized = true;
        emit Finalized(kpiReached);
    }

    function redeem() external {
        require(finalized, "TODO");
        uint256 _kpiTokenBalance = balanceOf(msg.sender);
        require(_kpiTokenBalance > 0, "TODO");
        uint256 _collateralToRedeem =
            (collateralToken.balanceOf(address(this)) * _kpiTokenBalance) /
                totalSupply();
        if (kpiReached) {
            collateralToken.safeTransfer(msg.sender, _collateralToRedeem);
        }
        _burn(msg.sender, _kpiTokenBalance);
        emit Redeemed(_kpiTokenBalance, _collateralToRedeem);
    }
}
