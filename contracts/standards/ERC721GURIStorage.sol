// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./ERC721G.sol";
import "./IERC721GURIStorage.sol";

contract ERC721GURIStorage is ERC721G, IERC721GURIStorage {
    using Strings for uint256;

    //keccak256("URI_SETTER_ROLE");
    bytes32 internal constant URI_SETTER_ROLE = 0x7804d923f43a17d325d77e781528e0793b2edd9890ab45fc64efd7b4b427744c;

    mapping(uint256 => string) private _tokenURIs;

    constructor(
        string memory name,
        string memory symbol,
        string memory baseURI_
    ) ERC721G(name, symbol, baseURI_) {
        _setupRole(URI_SETTER_ROLE, msg.sender);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override(ERC721, IERC721GURIStorage)
        returns (string memory)
    {
        _requireMinted(tokenId);

        string memory _tokenURI = _tokenURIs[tokenId];
        if (bytes(_tokenURI).length > 0) return _tokenURI;
        return super.tokenURI(tokenId);
    }

    function setTokenURI(uint256 tokenId, string calldata _tokenURI) external virtual onlyRole(URI_SETTER_ROLE) {
        _setTokenURI(tokenId, _tokenURI);
    }

    function mintWithURI(
        address to,
        uint256 tokenId,
        string calldata _tokenURI
    ) external virtual onlyRole(MINTER_ROLE) {
        _mint(to, tokenId);
        _setTokenURI(tokenId, _tokenURI);
    }

    function mintBatchWithURI(
        address to,
        uint256[] calldata tokenIds,
        string[] calldata __tokenURIs
    ) external virtual onlyRole(MINTER_ROLE) {
        require(tokenIds.length == __tokenURIs.length, "LENGTH_NOT_EQUAL");
        _mintBatch(to, tokenIds);
        for (uint256 i = 0; i < tokenIds.length; i++) {
            _setTokenURI(tokenIds[i], __tokenURIs[i]);
        }
    }

    function _setTokenURI(uint256 tokenId, string calldata _tokenURI) internal virtual {
        if (bytes(_tokenURI).length == 0) return;

        _requireMinted(tokenId);
        _tokenURIs[tokenId] = _tokenURI;
    }

    function _removeTokenURI(uint256 tokenId) internal virtual {
        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (to == address(0)) {
            _removeTokenURI(tokenId);
        }
    }

    function _beforeTokenBatchTransfer(
        address from,
        address to,
        uint256[] calldata tokenIds
    ) internal virtual override {
        super._beforeTokenBatchTransfer(from, to, tokenIds);

        if (to == address(0)) {
            for (uint256 i = 0; i < tokenIds.length; i++) {
                _removeTokenURI(tokenIds[i]);
            }
        }
    }
}
