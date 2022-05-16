pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/mux1.circom";

		// NOTES from video
		// Start with non empty array - assume power of 2
		// TODO: Handle non power of 2 length, dupliate last hash, compute hash on the duplicate
		// Compute the Cryptographic Hash
		// Store in new array
		// loop through until you only have one hash result (the root)z

template HashLeftRight() {
    signal input left;
    signal input right;
    signal output hash;

    component hasher = Poseidon(2);
    hasher.inputs[0] <== left;
    hasher.inputs[1] <== right;

    hash <== hasher.out;
}

template CheckRoot(n) { // compute the root of a MerkleTree of n Levels 
    signal input leaves[2**n];
    signal output root;

    //[assignment] insert your code here to calculate the Merkle root from 2^n leaves
		var numLeaves = 2**n;
		var numLeftRightHashes = numLeaves/2;

		component hashing[numLeaves - 1];

		for(var i = 0; i < numLeaves - 1; i++){
			hashing[i] = HashLeftRight();
		}

		for(var i = 0; i < numLeftRightHashes; i++) {
			hashing[i].left <== leaves[i*2];
			hashing[i].right <== leaves[i*2 + 1];
		}

		for(var i = 0; i < numLeaves - 1; i++) {
			hashing[i + numLeftRightHashes ].left <== hashing[i*2].hash;
      hashing[i + numLeftRightHashes].right <== hashing[i*2+1].hash;
		}

		root <== hashing[numLeaves-1].hash;
}

template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal

    //[assignment] insert your code here to compute the root from a leaf and elements along the path

		component hash[n];
		component mux[n];
		signal hashes[n + 1];
		hashes[0] <== leaf;

		for (var i = 0; i < n; i++) {
        hash[i] = HashLeftRight();

				// 
				mux[i] = MultiMux1(2);
				mux[i].c[0][0] <== hashes[i];
        mux[i].c[0][1] <== path_elements[i];
        mux[i].c[1][0] <== path_elements[i];
        mux[i].c[1][1] <== hashes[i];
        mux[i].s <== path_index[i];

        hash[i].left <== mux[i].out[0];
        hash[i].right <== mux[i].out[1];

        hashes[i + 1] <== hash[i].hash;

    }

		root <== hashes[n];
}