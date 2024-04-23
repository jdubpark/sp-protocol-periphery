// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.23;

import { BeaconProxy } from "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import { UpgradeableBeacon } from "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import { IAccessControl } from "@openzeppelin/contracts/access/IAccessControl.sol";
import { IERC20Errors } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import { SPGNFT } from "../contracts/SPGNFT.sol";
import { ISPGNFT } from "../contracts/interfaces/ISPGNFT.sol";
import { SPGNFTLib } from "../contracts/lib/SPGNFTLib.sol";
import { Errors } from "../contracts/lib/Errors.sol";

import { BaseTest } from "./utils/BaseTest.t.sol";

contract SPGNFTTest is BaseTest {
    ISPGNFT internal nftContract;

    function setUp() public override {
        super.setUp();

        nftContract = ISPGNFT(
            spg.createCollection({
                name: "Test Collection",
                symbol: "TEST",
                maxSupply: 100,
                mintCost: 100 * 10 ** mockToken.decimals(),
                mintToken: address(mockToken),
                owner: alice
            })
        );
    }

    function test_SPGNFT_initialize() public {
        address spgNftImpl = address(new SPGNFT(address(spg)));
        address NFT_CONTRACT_BEACON = address(new UpgradeableBeacon(spgNftImpl, deployer));
        ISPGNFT anotherNftContract = ISPGNFT(address(new BeaconProxy(NFT_CONTRACT_BEACON, "")));

        anotherNftContract.initialize({
            name: "Test Collection",
            symbol: "TEST",
            maxSupply: 100,
            mintCost: 100 * 10 ** mockToken.decimals(),
            mintToken: address(mockToken),
            owner: alice
        });

        assertEq(nftContract.name(), anotherNftContract.name());
        assertEq(nftContract.symbol(), anotherNftContract.symbol());
        assertEq(nftContract.totalSupply(), anotherNftContract.totalSupply());
        assertTrue(anotherNftContract.hasRole(SPGNFTLib.MINTER_ROLE, alice));
        assertEq(anotherNftContract.mintCost(), 100 * 10 ** mockToken.decimals());
    }

    function test_SPGNFT_initialize_revert_zeroParams() public {
        address spgNftImpl = address(new SPGNFT(address(spg)));
        address NFT_CONTRACT_BEACON = address(new UpgradeableBeacon(spgNftImpl, deployer));
        nftContract = ISPGNFT(address(new BeaconProxy(NFT_CONTRACT_BEACON, "")));

        vm.expectRevert(Errors.SPGNFT__ZeroAddressParam.selector);
        nftContract.initialize({
            name: "Test Collection",
            symbol: "TEST",
            maxSupply: 100,
            mintCost: 0,
            mintToken: address(mockToken),
            owner: address(0)
        });

        vm.expectRevert(Errors.SPGNFT__ZeroAddressParam.selector);
        nftContract.initialize({
            name: "Test Collection",
            symbol: "TEST",
            maxSupply: 100,
            mintCost: 1,
            mintToken: address(0),
            owner: alice
        });

        vm.expectRevert(Errors.SPGNFT_ZeroMaxSupply.selector);
        nftContract.initialize({
            name: "Test Collection",
            symbol: "TEST",
            maxSupply: 0,
            mintCost: 0,
            mintToken: address(mockToken),
            owner: alice
        });
    }

    function test_SPGNFT_mint() public {
        vm.startPrank(alice);

        mockToken.mint(address(alice), 1000 * 10 ** mockToken.decimals());
        mockToken.approve(address(nftContract), 1000 * 10 ** mockToken.decimals());

        uint256 mintCost = nftContract.mintCost();
        uint256 balanceBeforeAlice = mockToken.balanceOf(alice);
        uint256 balanceBeforeContract = mockToken.balanceOf(address(nftContract));
        uint256 tokenId = nftContract.mint(bob);

        assertEq(nftContract.totalSupply(), 1);
        assertEq(nftContract.balanceOf(bob), 1);
        assertEq(nftContract.ownerOf(tokenId), bob);
        assertEq(mockToken.balanceOf(alice), balanceBeforeAlice - mintCost);
        assertEq(mockToken.balanceOf(address(nftContract)), balanceBeforeContract + mintCost);
        balanceBeforeAlice = mockToken.balanceOf(alice);
        balanceBeforeContract = mockToken.balanceOf(address(nftContract));

        tokenId = nftContract.mint(bob);
        assertEq(nftContract.totalSupply(), 2);
        assertEq(nftContract.balanceOf(bob), 2);
        assertEq(nftContract.ownerOf(tokenId), bob);
        assertEq(mockToken.balanceOf(alice), balanceBeforeAlice - mintCost);
        assertEq(mockToken.balanceOf(address(nftContract)), balanceBeforeContract + mintCost);
        balanceBeforeAlice = mockToken.balanceOf(alice);
        balanceBeforeContract = mockToken.balanceOf(address(nftContract));

        // change mint cost
        nftContract.setMintCost(200 * 10 ** mockToken.decimals());
        mintCost = nftContract.mintCost();

        tokenId = nftContract.mint(cal);
        assertEq(mockToken.balanceOf(address(nftContract)), 400 * 10 ** mockToken.decimals());
        assertEq(nftContract.totalSupply(), 3);
        assertEq(nftContract.balanceOf(cal), 1);
        assertEq(nftContract.ownerOf(tokenId), cal);
        assertEq(mockToken.balanceOf(alice), balanceBeforeAlice - mintCost);
        assertEq(mockToken.balanceOf(address(nftContract)), balanceBeforeContract + mintCost);

        vm.stopPrank();
    }

    function test_SPGNFT_revert_mint_erc20InsufficientAllowance() public {
        uint256 mintCost = nftContract.mintCost();
        mockToken.mint(address(alice), mintCost);

        vm.expectRevert(
            abi.encodeWithSelector(IERC20Errors.ERC20InsufficientAllowance.selector, address(nftContract), 0, mintCost)
        );
        vm.prank(alice);
        nftContract.mint(bob);
    }

    function test_SPGNFT_revert_mint_erc20InsufficientBalance() public {
        vm.startPrank(alice);
        mockToken.approve(address(nftContract), 1000 * 10 ** mockToken.decimals());

        vm.expectRevert(
            abi.encodeWithSelector(
                IERC20Errors.ERC20InsufficientBalance.selector,
                address(alice),
                0,
                nftContract.mintCost()
            )
        );
        nftContract.mint(bob);
        vm.stopPrank();
    }

    function test_SPGNFT_setMintCost() public {
        vm.startPrank(alice);

        nftContract.setMintCost(200 * 10 ** mockToken.decimals());
        assertEq(nftContract.mintCost(), 200 * 10 ** mockToken.decimals());

        nftContract.setMintCost(300 * 10 ** mockToken.decimals());
        assertEq(nftContract.mintCost(), 300 * 10 ** mockToken.decimals());

        vm.stopPrank();
    }

    function test_SPGNFT_revert_setMintCost_accessControlUnauthorizedAccount() public {
        vm.startPrank(bob);

        vm.expectRevert(
            abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, bob, SPGNFTLib.ADMIN_ROLE)
        );
        nftContract.setMintCost(2);

        vm.stopPrank();
    }

    function test_SPGNFT_withdrawToken() public {
        vm.startPrank(alice);

        mockToken.mint(address(alice), 1000 * 10 ** mockToken.decimals());
        mockToken.approve(address(nftContract), 1000 * 10 ** mockToken.decimals());

        uint256 mintCost = nftContract.mintCost();

        nftContract.mint(bob);
        assertEq(mockToken.balanceOf(address(nftContract)), mintCost);

        uint256 balanceBeforeBob = mockToken.balanceOf(bob);

        nftContract.withdrawToken(address(mockToken), bob);
        assertEq(mockToken.balanceOf(address(nftContract)), 0);
        assertEq(mockToken.balanceOf(bob), balanceBeforeBob + mintCost);

        vm.stopPrank();
    }

    function test_SPGNFT_revert_withdrawETH_accessControlUnauthorizedAccount() public {
        vm.startPrank(bob);

        vm.expectRevert(
            abi.encodeWithSelector(IAccessControl.AccessControlUnauthorizedAccount.selector, bob, SPGNFTLib.ADMIN_ROLE)
        );
        nftContract.withdrawToken(address(mockToken), bob);

        vm.stopPrank();
    }
}
