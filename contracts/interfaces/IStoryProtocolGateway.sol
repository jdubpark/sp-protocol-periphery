// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.23;

import { PILTerms } from "@storyprotocol/core/interfaces/modules/licensing/IPILicenseTemplate.sol";

interface IStoryProtocolGateway {
    /// @notice Creates a new NFT collection to be used by SPG.
    /// @param name The name of the collection.
    /// @param symbol The symbol of the collection.
    /// @param maxSupply The maximum supply of the collection.
    /// @param mintCost The cost to mint an NFT from the collection.
    /// @param mintToken The token to be used for mint payment.
    /// @param owner The owner of the collection.
    /// @return nftContract The address of the newly created NFT collection.
    function createCollection(
        string memory name,
        string memory symbol,
        uint32 maxSupply,
        uint256 mintCost,
        address mintToken,
        address owner
    ) external returns (address nftContract);

    /// @notice Mint an NFT from a collection and register it as an IP.
    /// @dev Caller must have the minter role for the provided SPG NFT.
    /// @param nftContract The address of the NFT collection.
    /// @param recipient The address of the recipient of the minted NFT.
    /// @return ipId The ID of the registered IP.
    /// @return tokenId The ID of the minted NFT.
    function mintAndRegisterIp(address nftContract, address recipient) external returns (address ipId, uint256 tokenId);

    /// @notice Mint an NFT from a collection and register it with metadata as an IP.
    /// @dev Caller must have the minter role for the provided SPG NFT.
    /// @param nftContract The address of the NFT collection.
    /// @param recipient The address of the recipient of the minted NFT.
    /// @param metadataURI The URI of the metadata for the IP.
    /// @param metadataHash The hash of the metadata for the IP.
    /// @param nftMetadataHash The hash of the metadata for the IP NFT.
    /// @return ipId The ID of the registered IP.
    /// @return tokenId The ID of the minted NFT.
    function mintAndRegisterIp(
        address nftContract,
        address recipient,
        string memory metadataURI,
        bytes32 metadataHash,
        bytes32 nftMetadataHash
    ) external returns (address ipId, uint256 tokenId);

    /// @notice Register Programmable IP License Terms (if unregistered) and attach it to IP.
    /// @param ipId The ID of the IP.
    /// @param terms The PIL terms to be registered.
    /// @return licenseTermsId The ID of the registered PIL terms.
    function registerPILTermsAndAttach(address ipId, PILTerms memory terms) external returns (uint256 licenseTermsId);

    /// @notice Mint an NFT from a collection, register it as an IP, register Programmable IP License Terms (if
    /// unregistered), and attach it to the registered IP.
    /// @dev Caller must have the minter role for the provided SPG NFT.
    /// @param nftContract The address of the NFT collection.
    /// @param recipient The address of the recipient of the minted NFT.
    /// @param terms The PIL terms to be registered.
    /// @return ipId The ID of the registered IP.
    /// @return tokenId The ID of the minted NFT.
    /// @return licenseTermsId The ID of the registered PIL terms.
    function mintAndRegisterIpAndAttachPILTerms(
        address nftContract,
        address recipient,
        PILTerms memory terms
    ) external returns (address ipId, uint256 tokenId, uint256 licenseTermsId);

    /// @notice Mint an NFT from a collection, register it with metadata as an IP, register Programmable IP License
    /// Terms (if unregistered), and attach it to the registered IP.
    /// @dev Caller must have the minter role for the provided SPG NFT.
    /// @param nftContract The address of the NFT collection.
    /// @param recipient The address of the recipient of the minted NFT.
    /// @param metadataURI The URI of the metadata for the IP.
    /// @param metadataHash The hash of the metadata for the IP.
    /// @param nftMetadataHash The hash of the metadata for the IP NFT.
    /// @param terms The PIL terms to be registered.
    /// @return ipId The ID of the registered IP.
    /// @return tokenId The ID of the minted NFT.
    /// @return licenseTermsId The ID of the registered PIL terms.
    function mintAndRegisterIpAndAttachPILTerms(
        address nftContract,
        address recipient,
        string memory metadataURI,
        bytes32 metadataHash,
        bytes32 nftMetadataHash,
        PILTerms memory terms
    ) external returns (address ipId, uint256 tokenId, uint256 licenseTermsId);

    /// @notice Register a given NFT as an IP and attach Programmable IP License Terms.
    /// @dev Because IP Account is created in this function, we need to set the permission via signature to allow this
    /// contract to attach PIL Terms to the newly created IP Account in the same function.
    /// @param nftContract The address of the NFT collection.
    /// @param tokenId The ID of the NFT.
    /// @param terms The PIL terms to be registered.
    /// @param signer The address of the signer for execution with signature.
    /// @param deadline The deadline for the signature.
    /// @param signature The signature for the execution via IP Account.
    /// @return ipId The ID of the registered IP.
    /// @return licenseTermsId The ID of the registered PIL terms.
    function registerIpAndAttachPILTerms(
        address nftContract,
        uint256 tokenId,
        PILTerms memory terms,
        address signer,
        uint256 deadline,
        bytes calldata signature
    ) external returns (address ipId, uint256 licenseTermsId);

    /// @notice Register a given NFT as an IP with metadata and attach Programmable IP License Terms.
    /// @param nftContract The address of the NFT collection.
    /// @param tokenId The ID of the NFT.
    /// @param metadataURI The URI of the metadata for the IP.
    /// @param metadataHash The hash of the metadata for the IP.
    /// @param nftMetadataHash The hash of the metadata for the IP NFT.
    /// @param terms The PIL terms to be registered.
    /// @param signer The address of the signer for execution with signature.
    /// @param deadline The deadline for the signature.
    /// @param signature The signature for the execution via IP Account.
    /// @return ipId The ID of the registered IP.
    /// @return licenseTermsId The ID of the registered PIL terms.
    function registerIpAndAttachPILTerms(
        address nftContract,
        uint256 tokenId,
        string memory metadataURI,
        bytes32 metadataHash,
        bytes32 nftMetadataHash,
        PILTerms memory terms,
        address signer,
        uint256 deadline,
        bytes calldata signature
    ) external returns (address ipId, uint256 licenseTermsId);

    /// @notice Mint an NFT from a collection and register it as a derivative IP using license tokens.
    /// @dev Caller must have the minter role for the provided SPG NFT.
    /// @param nftContract The address of the NFT collection.
    /// @param licenseTokenIds The IDs of the license tokens to be burned for linking the IP to parent IPs.
    /// @param royaltyContext The context for royalty module, should be empty for Royalty Policy LAP.
    /// @param recipient The address to receive the minted NFT.
    /// @return ipId The ID of the registered IP.
    /// @return tokenId The ID of the minted NFT.
    function registerAndMakeDerivativeWithLicenseTokens(
        address nftContract,
        uint256[] calldata licenseTokenIds,
        bytes calldata royaltyContext,
        address recipient
    ) external returns (address ipId, uint256 tokenId);

    /// @notice Register the given NFT as a derivative IP using license tokens.
    /// @param nftContract The address of the NFT collection.
    /// @param tokenId The ID of the NFT.
    /// @param licenseTokenIds The IDs of the license tokens to be burned for linking the IP to parent IPs.
    /// @param royaltyContext The context for royalty module, should be empty for Royalty Policy LAP.
    /// @param signer The address of the signer for execution with signature.
    /// @param deadline The deadline for the signature.
    /// @param signature The signature for the execution via IP Account.
    /// @return ipId The ID of the registered IP.
    function registerAndMakeDerivativeWithLicenseTokens(
        address nftContract,
        uint256 tokenId,
        uint256[] calldata licenseTokenIds,
        bytes calldata royaltyContext,
        address signer,
        uint256 deadline,
        bytes calldata signature
    ) external returns (address ipId);
}
