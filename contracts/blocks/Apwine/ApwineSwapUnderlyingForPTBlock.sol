// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {BaseSlothyBlock} from "../../BaseSlothyBlock.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IApwine} from "../../interfaces/IApwine.sol";

contract ApwineSwapUnderlyingForPTBlock is BaseSlothyBlock {
    address internal constant AMM_ROUTER =
        0x790a0cA839DC5E4690C8c58cb57fD2beCA419AFc;

    function run(bytes32[] memory _args) public returns (bool _success) {
        /**
         * @dev _args[0] = _outputTokenAmount
         * @dev _args[1] = _AMMAddress
         * @dev _args[2] = _underlyingTokenAddress
         * @dev _args[3] = _underlyingTokenAmount
         */

        uint256 _outputTokenAmount = this.argToUint256(_args[0]);
        address _AMMAddress = this.argToAddress(_args[1]);
        address _underlyingTokenAddress = this.argToAddress(_args[2]);
        uint256 _underlyingTokenAmount = this.argToUint256(_args[3]);

        // borrow from vault
        IERC20(_underlyingTokenAddress).transferFrom(
            msg.sender,
            address(this),
            _underlyingTokenAmount
        );

        // swap
        IERC20(_underlyingTokenAddress).approve(
            AMM_ROUTER,
            _underlyingTokenAmount
        );

        uint256[] memory _pool = new uint256[](1);
        uint256[] memory _direction = new uint256[](2);
        _direction[0] = 1;

        IApwine(AMM_ROUTER).swapExactAmountIn(
            _AMMAddress,
            _pool, // Pool 0 is PT/Underlying, Pool 1 is PT/FYT
            _direction, // Token 0 is always PT. Here, we swap from Underlying to PT
            _underlyingTokenAmount,
            _outputTokenAmount,
            msg.sender,
            60,
            address(0)
        );
        //! _minAmountOut and _deadline above should be computed and passed at runtime, by a script or client

        emit ApwineSwapUnderlyingForPTBlockEvent(
            msg.sender,
            _outputTokenAmount,
            _AMMAddress,
            _underlyingTokenAddress,
            _underlyingTokenAmount
        );

        return true;
    }

    event ApwineSwapUnderlyingForPTBlockEvent(
        address indexed _vaultAddress,
        uint256 _outputTokenAmount,
        address _AMMAddress,
        address _underlyingTokenAddress,
        uint256 _underlyingTokenAmount
    );
}
