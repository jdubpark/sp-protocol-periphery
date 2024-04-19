// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.23;
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

library TestProxyHelper {
    /// Deploys a new UUPS proxy with the provided implementation and data
    /// @dev WARNING: DO NOT USE IN PRODUCTION, this doesn't check for storage layout compatibility
    /// @param impl address of the implementation contract
    /// @param data encoded initializer call
    function deployUUPSProxy(address impl, bytes memory data) internal returns (address) {
        ERC1967Proxy proxy = new ERC1967Proxy(impl, data);
        return address(proxy);
    }
}
