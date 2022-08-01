// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";

contract GaiaProtocolPFP is AccessControl, ERC721Burnable, ERC721Pausable {
    event SetBaseURI(string baseURI_);

    bytes32 internal constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 internal constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 internal constant BURNER_ROLE = keccak256("BURNER_ROLE");

    uint256 internal _totalSupply;
    string internal __baseURI;

    constructor(
        string memory name,
        string memory symbol,
        string memory baseURI_
    ) ERC721(name, symbol) {
        __baseURI = baseURI_;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, msg.sender);
        _setupRole(PAUSER_ROLE, msg.sender);
        _setupRole(BURNER_ROLE, msg.sender);
    }

    //ROLE functions
    function setBaseURI(string calldata baseURI_) external onlyRole(DEFAULT_ADMIN_ROLE) {
        __baseURI = baseURI_;
        emit SetBaseURI(baseURI_);
    }

    function setPause(bool status) external onlyRole(PAUSER_ROLE) {
        if (status) _pause();
        else _unpause();
    }

    function mint(address to, uint256 tokenId) public virtual onlyRole(MINTER_ROLE) {
        _mint(to, tokenId);
    }

    function burn(uint256 tokenId) public override onlyRole(BURNER_ROLE) {
        super.burn(tokenId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721, ERC721Pausable) {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _totalSupply++;
        }
        if (to == address(0)) {
            _totalSupply--;
        }
    }

    function _baseURI() internal view override returns (string memory) {
        return __baseURI;
    }
    
    //view functions
    function exists(uint256 tokenId) external view returns (bool) {
        return _exists(tokenId);
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControl, ERC721) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
