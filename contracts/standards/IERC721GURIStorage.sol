// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./IERC721G.sol";

interface IERC721GURIStorage is IERC721G {
    function tokenURI(uint256 tokenId) external view returns (string memory);

    function setTokenURI(uint256 tokenId, string calldata _tokenURI) external;

    function mintWithURI(
        address to,
        uint256 tokenId,
        string calldata _tokenURI
    ) external;

    function mintBatchWithURI(
        address to,
        uint256[] calldata tokenIds,
        string[] calldata __tokenURIs
    ) external;
}
