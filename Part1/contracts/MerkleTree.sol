//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { PoseidonT3 } from "./Poseidon.sol"; //an existing library to perform Poseidon hash on solidity
import "./verifier.sol"; //inherits with the MerkleTreeInclusionProof verifier contract

contract MerkleTree is Verifier {
    uint256[] public hashes; // the Merkle tree in flattened array form
    uint256 public index = 0; // the current index of the first unfilled leaf
    uint256 public root; // the current Merkle root

    constructor() {
        // [assignment] initialize a Merkle tree of 8 with blank leaves
				// could improve this but calculating the size (2 ** n?)
				for (uint i = 0; i < 15; i++) {
            // hashes[i] = 0; ???
						hashes.push(0);
        }
    }

    function insertLeaf(uint256 hashedLeaf) public returns (uint256) {
        // [assignment] insert a hashed leaf into the Merkle tree
				uint256 left;
        uint256 right;
        hashes[index] = hashedLeaf;
				uint256 localIdx = index;

        for (uint level = 3; level > 1; level--){
						// Left
            if (localIdx % 2 == 0){
                left = hashes[localIdx];
                right = hashes[localIdx + 1];
            } 
						// Right
						else {
                left = hashes[localIdx - 1];
                right = hashes[localIdx];
            }

            localIdx = (localIdx / 2) + (2 **  level);
            hashes[localIdx] = PoseidonT3.poseidon([left, right]);
        }

        index += 1;
        root = hashes[hashes.length - 1];
        return root;
    }

    function verify(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[1] memory input
        ) public view returns (bool) {

        // [assignment] verify an inclusion proof and check that the proof root matches current root
				return verifyProof(a, b, c, input);
    }
}
