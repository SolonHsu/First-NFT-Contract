// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
contract BigBenFun is ERC721, ERC721Enumerable, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;//
    uint256 public maxTokenSupply;//宣告最大值
    uint256 public constant MAX_MINTS_PER_TXN = 5;//
    uint256 public mintPrice = 80000 wei; // 0.08 ETH
    bool public saleIsActive = false;
    string public baseURI;
    
    constructor(string memory name, string memory symbol, uint256 maxBigBenTokenSupply) ERC721(name, symbol) {
        maxTokenSupply = maxBigBenTokenSupply;//最大供應量

    }
    function setMaxTokenSupply(uint256 maxBigBenTokenSupply) public onlyOwner {
        maxTokenSupply = maxBigBenTokenSupply;//與constructor一樣
    }
    function setMintPrice(uint256 newPrice) public onlyOwner {
        mintPrice = newPrice;//設定最低mint價
    }
    /*
    * Pause sale if active, make active if paused.
    */
    function flipSaleState() public onlyOwner {
        saleIsActive = !saleIsActive;//啟動或關閉 買賣時機
    }
    /*
    * Mint BigBenFun NFTs
    */
    function mintBigBenFun(uint256 numberOfTokens) public payable {
        require(saleIsActive, "Sale must be active");//買賣必須啟動
        require(numberOfTokens <= MAX_MINTS_PER_TXN, "You can only adopt 5 BigBenFun at a time");//最多買5個
        require(totalSupply() + numberOfTokens <= maxTokenSupply, "Purchase would exceed max available BigBenFun");
        //已鑄造數+此次總鑄造數<=最大供應量
        require(mintPrice * numberOfTokens <= msg.value, "Ether value sent is not correct");//發送金額須>=單價 x Token數量
        for(uint256 i = 0; i < numberOfTokens; i++) {
            uint256 mintIndex = _tokenIdCounter.current() + 1;//欲鑄造Index=合約內Index＋1
            if (mintIndex <= maxTokenSupply) {//若欲鑄造Index<=最大供應量
                _safeMint(msg.sender, mintIndex);//真正的鑄造
                _tokenIdCounter.increment();//合約內Index+1
            }
        }
    }
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;//內部回傳baseURI
    }
    function setBaseURI(string memory newBaseURI) public onlyOwner {
        baseURI = newBaseURI;
    }

    function withdraw(address to) public onlyOwner {//提款
        uint256 balance = address(this).balance;//將此合約餘額數字給balance
        payable(to).transfer(balance);//把balance的錢轉給to
    }
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);//繼承後者的方法_beforeTokenTransfer(合約前預訂要做的事)
    }
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

}