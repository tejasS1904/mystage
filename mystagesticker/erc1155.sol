// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.5.0
pragma solidity ^0.8.26;

import {AccessControl} from "@openzeppelin/contracts@5.5.0/access/AccessControl.sol";
import {ERC1155} from "@openzeppelin/contracts@5.5.0/token/ERC1155/ERC1155.sol";
import {ERC1155Supply} from "@openzeppelin/contracts@5.5.0/token/ERC1155/extensions/ERC1155Supply.sol";
import {ERC2981} from "./ERC2981.sol";
import {Strings} from "@openzeppelin/contracts@5.5.0/utils/Strings.sol";
/// @custom:security-contact craig@mysta.ge
contract MyStage is ERC1155, AccessControl, ERC1155Supply, ERC2981 {
    
    bytes32 public constant URI_SETTER_ROLE = keccak256("URI_SETTER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant ROYALTY_SETTER_ROLE = keccak256("ROYALTY_SETTER_ROLE");

    bool private _minthasRun;
    string private _baseUri;

    modifier onlyOnce() {
        require(!_minthasRun, "mint or mint batch Function can only be called once");
        _;
        _minthasRun = true;
    }

    constructor(string memory baseURI,address defaultAdmin, address secondaryAdmin, address receiver, uint96 royaltyNumerator)
        ERC1155(baseURI) //Location of the metadata. Clients will replace any instance of {id} in this string with the tokenId.
    {
        _baseUri = baseURI;
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(MINTER_ROLE, secondaryAdmin);
        _grantRole(URI_SETTER_ROLE, secondaryAdmin);
        _grantRole(ROYALTY_SETTER_ROLE, secondaryAdmin);
        _setDefaultRoyalty(receiver, royaltyNumerator);
    }

    function setURI(string memory newuri) public onlyRole(URI_SETTER_ROLE) {
        _setURI(newuri);
        _baseUri = newuri;
    }

    function mint(address account, uint256 id, uint256 amount, bytes memory data)
        public
        onlyOnce
        onlyRole(MINTER_ROLE)
    {
        _mint(account, id, amount, data);
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyOnce
        onlyRole(MINTER_ROLE)
    {
        _mintBatch(to, ids, amounts, data);
    }

    // the base in 10000 so the 100% royalty is 10000 basically (feeNume/feeDeno)
    //1% -> 100
    //2.45 -> 245
    //10% -> 1000
    function setDefaultRoyalty(address receiver, uint96 feeNumerator) public onlyRole(ROYALTY_SETTER_ROLE)
    {
        _setDefaultRoyalty(receiver, feeNumerator);
    }
    
    function setTokenRoyalty(uint256 tokenId, address receiver, uint96 feeNumerator) public onlyRole(ROYALTY_SETTER_ROLE)
    {
        _setTokenRoyalty(tokenId, receiver, feeNumerator);
    }

    // The following functions are overrides required by Solidity.

    function _update(address from, address to, uint256[] memory ids, uint256[] memory values)
        internal
        override(ERC1155, ERC1155Supply)
    {
        super._update(from, to, ids, values);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155, AccessControl, ERC2981)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

      function uri(uint256 id) public view override returns (string memory) {
      return string(abi.encodePacked(_baseUri, Strings.toString(id), ".json"));
    }
}
