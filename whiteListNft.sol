// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyNFT is ERC721, ERC721Enumerable, ERC721Pausable, Ownable {
    uint256 private _nextTokenId;
    uint256 public maxSupply = 1000;
    bool public publicMintOpen = false;
    bool public whiteListMintOpen = false;

    mapping(address => bool) public whiteList;

    constructor() ERC721("BEAR", "BR") Ownable(msg.sender) {}

    function _baseURI() internal pure override returns (string memory) {
        return
            "https://gateway.pinata.cloud/ipfs/QmeEj27nZ1jyi9TZCw1HCBe3RvCgy7U4S583PbnkZR5vz3";
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    //   Populate eth whiteList
    function setWhiteList(address[] calldata addresses) external onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            whiteList[addresses[i]] = true;
        }
    }

    // Modify the mint windows
    function editMIntWindows(bool _publicMintOpen, bool _whiteListMintOpen)
        external
        onlyOwner
    {
        publicMintOpen = _publicMintOpen;
        whiteListMintOpen = _whiteListMintOpen;
    }

    function whiteListMint() public payable {
        require(whiteListMintOpen, "whiteList Mint Closed");
        require(msg.value == 0.0001 ether, "No enough Funds");
        require(whiteList[msg.sender], "Owner not allowed");
        internalMint();
    }

    // function safeMint(address to) public onlyOwner {
    //     uint256 tokenId = _nextTokenId++;
    //     _safeMint(to, tokenId);
    // }

    function publicMint() public payable {
        require(publicMintOpen, "Public Mint closed");
        require(msg.value == 0.001 ether, "Not Enough Funds");
       internalMint(); 
    }

    function internalMint() internal {
        require(totalSupply() < maxSupply, "Sold out");
        uint256 tokenId = _nextTokenId++;
        _safeMint(msg.sender, tokenId);
    }

    function withdraw(address _addr) external onlyOwner{
        // get the balance of the contract
        uint256 balance = address(this).balance;
        payable(_addr).transfer(balance);
    }

    // The following functions are overrides required by Solidity.

    function _update(
        address to,
        uint256 tokenId,
        address auth
    )
        internal
        override(ERC721, ERC721Enumerable, ERC721Pausable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._increaseBalance(account, value);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
