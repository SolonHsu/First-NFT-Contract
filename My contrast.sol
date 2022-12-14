// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Mine is ERC721,ERC721Enumerable,Ownable{
    using Counters for Counters.Counter;
    Counters.Counter private count;
    uint256 public MAX_TokenSupply = 5;
    uint8 public constant Once_limit = 2;
    uint256 public minPrice=80000;
    bool public SaleActive=false;
    string public baseURI;

    event touch(
        address buy,
        uint256 nowsupply
    );

    constructor(string memory name,string memory symbol,string memory newbaseURI)ERC721(name,symbol){
        baseURI = newbaseURI;
    }
    function SetMax(uint256 maxMyTokenSupply)public onlyOwner{
        MAX_TokenSupply=maxMyTokenSupply;//修改庫存量
    }

    function SetMint(uint256 newPrice)public onlyOwner{//調整售價
        minPrice = newPrice;
    }

    function SaleSwtich()public onlyOwner{//開關
        SaleActive = !SaleActive;
    }

    function Mint(uint8 mintmount)public payable{
        require(SaleActive==true,"Sale is not active.");//確定開關打開
        //require(isContract(msg.sender)==false,"Robot is not allowed.");//須為EOA
        require(mintmount<=Once_limit,"You can only buy 3 at a time.");     //確定未超過一次鑄造數量
        require(mintmount>0,"It must bigger than 0.");
        require(minPrice*mintmount<=msg.value,"Money is not enough"); //確定價格足夠
        require(totalSupply()+mintmount<=MAX_TokenSupply,"Not enough to supply.");
        //已鑄造數(721Enumerable)＋NFT index <=庫存量
        for(uint256 i=1;i<=mintmount;i++){
            uint256 next = count.current()+1;//欲鑄造index = NFT index +1
            if(next<=MAX_TokenSupply){//欲鑄造index<=庫存量
                _safeMint(msg.sender,next);//_safeMint(to,token_Id)
                count.increment();//NFT index+1
            }


        }
        emit touch(msg.sender,count.current());
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;//內部回傳baseURI
    }
    function setBaseURI(string memory newBaseURI) public onlyOwner{
        baseURI = newBaseURI;
    }
     function viewcontract()public view onlyOwner returns(uint256 b,uint256 c){
        b=address(this).balance;
        c=count.current();
    }
    function withdraw()public onlyOwner{
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);//需加payable該address才可轉錢
    }


    //若一個函式在多個繼承的合約中都存在，則一定要重寫
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);//繼承後者的方法_beforeTokenTransfer(合約前預訂要做的事)
    }
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}