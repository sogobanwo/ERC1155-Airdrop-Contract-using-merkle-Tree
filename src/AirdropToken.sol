// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "solmate/utils/MerkleProofLib.sol";


contract AirdropToken is ERC1155, Ownable {
      bytes32 root;

    constructor(bytes32 _root, address initialOwner) ERC1155("https://gateway.pinata.cloud/ipfs/QmZh3CWQz6i7m76pr6QNaUW8tPfpMNpsfujsb5J6EAfDUi")Ownable(initialOwner) {
        root = _root;
    }


    mapping(address => bool) public hasClaimed;

    function claim(
        address _claimer,
        uint _tokenId,
        uint _amount,
        bytes memory _data,
        bytes32[] calldata _proof
    ) external returns (bool success) {
        require(!hasClaimed[_claimer], "already claimed");
        bytes32 leaf = keccak256(abi.encodePacked(_claimer, _tokenId, _amount ));
        bool verificationStatus = MerkleProofLib.verify(_proof, root, leaf);
        require(verificationStatus, "not whitelisted");
        hasClaimed[_claimer] = true;
        _mint(_claimer, _tokenId, _amount, _data);
        success = true;
    }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function mint(address account, uint256 id, uint256 amount, bytes memory data)
        public
        onlyOwner
    {
        _mint(account, id, amount, data);
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyOwner
    {
        _mintBatch(to, ids, amounts, data);
    }
}
