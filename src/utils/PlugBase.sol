// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ISocket} from "../interfaces/ISocket.sol";

abstract contract PlugBase {
    address public owner;
    ISocket socket;

    constructor(address _socket) {
        owner = msg.sender;
        socket = ISocket(_socket);
    }

    //
    // Modifiers
    //
    modifier onlyOwner() {
        require(msg.sender == owner, "no auth");
        _;
    }

    function connect(
        uint256 _remoteChainSlug,
        address _remotePlug,
        string memory _integrationType
    ) external onlyOwner {
        socket.setPlugConfig(_remoteChainSlug, _remotePlug, _integrationType);
    }

    function outbound(
        uint256 chainSlug,
        uint256 gasLimit,
        uint256 fees,
        bytes memory payload
    ) internal {
        socket.outbound{value: fees}(chainSlug, gasLimit, payload);
    }

    function inbound(bytes calldata payload_) external payable {
        require(msg.sender == address(socket), "no auth");
        _receiveInbound(payload_);
    }

    function getChainSlug() internal returns (uint256) {
        return socket.chainSlug();
    }

    function _receiveInbound(bytes memory payload_) internal virtual;

    function removeOwner() external onlyOwner {
        owner = address(0);
    }
}
