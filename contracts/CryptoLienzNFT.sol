// contracts/CryptoLiensNFT.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract CryptoLienzNFT is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    address payable public minter;
    uint256 public maxBatch = 5;
    uint256 public totalCount = 200;
    uint256 public price = 60000000000000000; // 0.04 eth

    bool private started = false;


    event MintNFT(address indexed _from, string url, uint256 times);
    // https://gateway.pinata.cloud/ipfs/QmQNNdJnaQjGiL6pHXnyeGVxTwZNpipzgW87zVwLp8CL6i/

    string private _uri = "";

    modifier restricted() {
      if (msg.sender == minter) _;
    }

    constructor() ERC721("CryptoLienzNFT", "CLNFT") {
      minter = payable(msg.sender);
    }

    function mintNFT(uint256 _times) public payable {
        require(started, "not started");
        require(_times > 0 && _times <= maxBatch, "Wrong batch number");
        require(_tokenIds.current() + _times <= totalCount, "Not enough toad left");
        require(msg.value == _times * price, "Not the good price");

        for(uint256 i=0; i< _times; i++){
            _tokenIds.increment();

            uint256 newItemId = _tokenIds.current();
            _mint(msg.sender, newItemId);
            string memory url = string(abi.encodePacked(_uri, uint2str(newItemId)));

            emit MintNFT(msg.sender, url, _times);

            _setTokenURI(newItemId, url);

            payable(msg.sender).transfer(msg.value);
        }
    }

    function totalSupply() public view virtual returns (uint256) {
        return _tokenIds.current();
    }
        
    function setStart(bool _start) public onlyOwner {
        started = _start;
    }

    function baseTokenURI() public view returns (string memory) {
        return _uri;
    }

    function setBaseTokenURI(string memory _baseURI) public restricted {
        _uri = _baseURI;
    }

    function uint2str(uint256 _i) internal pure returns (string memory str) {
        if (_i == 0) {
          return "0";
        }
        uint256 j = _i;
        uint256 length;
        while (j != 0) {
          length++;
          j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint256 k = length;
        j = _i;
        while (j != 0) {
          bstr[--k] = bytes1(uint8(48 + j % 10));
          j /= 10;
        }
        str = string(bstr);
        return str;
    }
}

// const contract = await CryptoLienzNFT.deployed();

// contract.awardItem("0x63126293FA2E90d87aCF90A79134A2761943136b", "https://upload.wikimedia.org/wikipedia/commons/thumb/0/05/Ethereum_logo_2014.svg/256px-Ethereum_logo_2014.svg.png")