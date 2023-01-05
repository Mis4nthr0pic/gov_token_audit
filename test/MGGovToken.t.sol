pragma solidity 0.6.12;

import "forge-std/Test.sol";
import {MockGovToken} from "src/MGGovToken.sol";

contract MockGovTokenTest is Test {
    MockGovToken mockGovToken;
    address owner;
    address delegate1;
    address delegate2;
    address delegate3;
    address notOwner;

    function setUp() public {
        owner = msg.sender;
        notOwner = makeAddr("not owner");
        delegate1 = makeAddr("delegate 1");
        delegate2 = makeAddr("delegate 2");
        delegate3 = makeAddr("delegate 3");
        mockGovToken = new MockGovToken();
    }

    function testMint() public {
        // Test initial state
        assertEq(mockGovToken.balanceOf(delegate1), 0);

        // Test mint function
        mockGovToken.mint(delegate1, 100);
        assertEq(mockGovToken.balanceOf(delegate1), 100);

        // Test that only owner can mint
        vm.prank(notOwner);
        vm.expectRevert("Ownable: caller is not the owner");
        mockGovToken.mint(delegate2, 100);
    }

    function testBurn() public {
        // Test initial state
        assertEq(mockGovToken.balanceOf(delegate1), 0);

        // Test burn function
        mockGovToken.mint(delegate1, 100);
        assertEq(mockGovToken.balanceOf(delegate1), 100);
        mockGovToken.burn(delegate1, 50);
        assertEq(mockGovToken.balanceOf(delegate1), 50);

        // Test that only owner can burn
        vm.prank(notOwner);
        vm.expectRevert("Ownable: caller is not the owner");
        mockGovToken.burn(delegate1, 50);
    }

    function testDelegates() public {
        // Test initial state
        assertEq(mockGovToken.delegates(delegate1), address(0));

        vm.prank(delegate1);
        // Test delegates function
        mockGovToken.delegate(delegate2);
        assertEq(mockGovToken.delegates(delegate1), delegate2);
    }
}
