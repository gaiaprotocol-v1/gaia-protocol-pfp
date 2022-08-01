// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./IERC721G.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";

contract ERC721G is AccessControl, ERC721Pausable, IERC721G {
    //keccak256("MINTER_ROLE");
    bytes32 internal constant MINTER_ROLE = 0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6;
    //keccak256("PAUSER_ROLE");
    bytes32 internal constant PAUSER_ROLE = 0x65d7a28e3265b37a6474929f336521b332c1681b933f6cb9f3376673440d862a;
    //keccak256("BURNER_ROLE");
    bytes32 internal constant BURNER_ROLE = 0x3c11d16cbaffd01df69ce1c404f6340ee057498f5f00246190ea54220576a848;

    //overriding variables
    mapping(uint256 => address) internal _owners;
    mapping(address => uint256) internal _balances;

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
    }

    //ERC721 overriding functions
    function _mint(address to, uint256 tokenId) internal virtual override {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual override {
        address owner = ERC721.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        if (from == address(0)) {
            _totalSupply++;
        }
        if (to == address(0)) {
            _totalSupply--;
        }
    }

    function _exists(uint256 tokenId) internal view virtual override returns (bool) {
        return _owners[tokenId] != address(0);
    }

    function balanceOf(address owner) public view virtual override(ERC721, IERC721) returns (uint256) {
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view virtual override(ERC721, IERC721) returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: invalid token ID");
        return owner;
    }

    //view functions
    function _baseURI() internal view virtual override returns (string memory) {
        return __baseURI;
    }

    function exists(uint256 tokenId) external view virtual returns (bool) {
        return _exists(tokenId);
    }

    function totalSupply() external view virtual returns (uint256) {
        return _totalSupply;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(IERC165, AccessControl, ERC721)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    //operational functions
    function setBaseURI(string calldata baseURI_) external onlyRole(DEFAULT_ADMIN_ROLE) {
        __baseURI = baseURI_;
        emit SetBaseURI(baseURI_);
    }

    function setPause(bool status) external onlyRole(PAUSER_ROLE) {
        if (status) _pause();
        else _unpause();
    }

    //mint/burn/transfer
    function mint(address to, uint256 tokenId) public virtual onlyRole(MINTER_ROLE) {
        _mint(to, tokenId);
    }

    function mintBatch(address to, uint256[] calldata tokenIds) external virtual onlyRole(MINTER_ROLE) {
        _mintBatch(to, tokenIds);
    }

    function burn(uint256 tokenId) external virtual onlyRole(BURNER_ROLE) {
        require(_isApprovedOrOwner(msg.sender, tokenId), "UNAUTHORIZED");
        _burn(tokenId);
    }

    function burnBatch(address from, uint256[] calldata tokenIds) external virtual onlyRole(BURNER_ROLE) {
        require(from != address(0), "BURN_FROM_ADDRESS_0");
        uint256 amount = tokenIds.length;
        require(amount > 0, "INVALID_AMOUNT");
        bool passChecking;
        if (msg.sender == from || isApprovedForAll(from, msg.sender)) passChecking = true;

        _beforeTokenBatchTransfer(from, address(0), tokenIds);

        for (uint256 i = 0; i < amount; i++) {
            uint256 tokenId = tokenIds[i];
            require(_owners[tokenId] == from, "OWNER_FROM_NOT_EQUAL");
            if (!passChecking) require(getApproved(tokenId) == msg.sender, "UNAUTHORIZED");
            // Clear approvals
            _approve(address(0), tokenId);
            delete _owners[tokenId];
            emit Transfer(from, address(0), tokenId);
        }
        _balances[from] -= amount;
    }

    function batchTransferFrom(
        address from,
        address to,
        uint256[] calldata tokenIds
    ) external virtual {
        require(from != address(0), "TRANSFER_FROM_ADDRESS_0");
        require(to != address(0), "TRANSFER_TO_ADDRESS_0");
        uint256 amount = tokenIds.length;
        require(amount > 0, "INVALID_AMOUNT");
        bool passChecking;
        if (msg.sender == from || isApprovedForAll(from, msg.sender)) passChecking = true;

        _beforeTokenBatchTransfer(from, to, tokenIds);

        for (uint256 i = 0; i < amount; i++) {
            uint256 tokenId = tokenIds[i];
            require(_owners[tokenId] == from, "OWNER_FROM_NOT_EQUAL");
            if (!passChecking) require(getApproved(tokenId) == msg.sender, "UNAUTHORIZED");
            // Clear approvals
            _approve(address(0), tokenId);
            _owners[tokenId] = to;
            emit Transfer(from, to, tokenId);
        }

        _balances[from] -= amount;
        _balances[to] += amount;
    }

    function _mintBatch(address to, uint256[] calldata tokenIds) internal virtual {
        require(to != address(0), "MINT_TO_ADDRESS_0");
        uint256 amount = tokenIds.length;
        require(amount > 0, "INVALID_AMOUNT");

        _beforeTokenBatchTransfer(address(0), to, tokenIds);
        for (uint256 i = 0; i < amount; i++) {
            uint256 tokenId = tokenIds[i];
            require(!_exists(tokenId), "ALREADY_MINTED");

            _owners[tokenId] = to;
            emit Transfer(address(0), to, tokenId);
        }
        _balances[to] += amount;
    }

    function _beforeTokenBatchTransfer(
        address from,
        address to,
        uint256[] calldata tokenIds
    ) internal virtual whenNotPaused {
        if (from == address(0)) {
            _totalSupply += tokenIds.length;
        }
        if (to == address(0)) {
            _totalSupply -= tokenIds.length;
        }
    }
}
