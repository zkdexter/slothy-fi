// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {BaseSlothyBlock} from "../../BaseSlothyBlock.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IApwine} from "../../interfaces/IApwine.sol";

contract ApwineDepositBlock is BaseSlothyBlock {
    address internal constant CONTROLLER =
        0x4bA30FA240047c17FC557b8628799068d4396790;

    function run(bytes32[] memory _args) public returns (bool _success) {
        /**
         * @dev _args[0] = _tokenAddress
         * @dev _args[1] = _wineVaultAddress
         * @dev _args[2] = _principalToken
         * @dev _args[3] = _futureYieldToken
         * @dev _args[4] = _amount
         */

        address _tokenAddress = this.argToAddress(_args[0]);
        address _wineVaultAddress = this.argToAddress(_args[1]);
        address _principalToken = this.argToAddress(_args[2]);
        address _futureYieldToken = this.argToAddress(_args[3]);
        uint256 _amount = this.argToUint256(_args[4]);

        // borrow from vault
        IERC20(_tokenAddress).transferFrom(msg.sender, address(this), _amount);

        // approve spending on Apwine controller
        IERC20(_tokenAddress).approve(CONTROLLER, _amount);

        // deposit to Apwine
        IApwine(CONTROLLER).deposit(_wineVaultAddress, _amount);

        // transfer principal token back to slothy vault
        IERC20(_principalToken).transfer(
            msg.sender,
            IERC20(_principalToken).balanceOf(address(this))
        );

        // transfer future yield token back to slothy vault
        IERC20(_futureYieldToken).transfer(
            msg.sender,
            IERC20(_principalToken).balanceOf(address(this))
        );

        emit ApwineDepositBlockEvent(
            msg.sender,
            _tokenAddress,
            _wineVaultAddress,
            _principalToken,
            _futureYieldToken,
            _amount
        );

        return true;
    }

    event ApwineDepositBlockEvent(
        address indexed _vaultAddress,
        address _tokenAddress,
        address _wineVaultAddress,
        address _principalToken,
        address _futureYieldToken,
        uint256 _amount
    );
}
