// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

// We need to import the helper functions from the contract that we copy/pasted.
import { Base64 } from "./libraries/Base64.sol";

contract MyEpicNFT is ERC721URIStorage {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

     // This is our SVG code. All we need to change is the word that's displayed. Everything else stays the same.
    // So, we make a baseSvg variable here that all our NFTs can use.
    string svgPartOne = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='";
    string svgPartTwo = "'/><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";
    // I create three arrays, each with their own theme of random words.
    // Pick some random funny words, names of anime characters, foods you like, whatever! 
    string[] firstWords = ["Academy", "Chemtech", "Clockwork", "Cuddly", "Enforcer", "Glutton", "Imperial", "Mercenary","Mutant", "Scrap","Sister","Socialite", "Syndicate","Yordle", "Yordle-Lord"];
    string[] secondWords = ["Arcanist", "Assassin", "Bodyguard", "Bruiser", "Challenger", "Colossus","Enchanter","Innovator", "Protector", "Scholar", "Sniper", "Transformer", "Twinshot"];
    string[] thirdWords = ["Akali", "Blitzcrank", "Braum", "Caitlyn", "Camille", "Chogath","Darius","DrMundo", "Ekko","Ezreal", "Fiora","Galio","Gangplank","Garen","Graves","Heimerdinger","Illaoi","Janna","Jayce","Jhin","Jinx","Kaisa","Kassadin","Katarina","KogMaw","Leona","Lissandra","Lulu","Lux","Malzahar","MissFortune","Orianna","Poppy","Quinn","Samira","Seraphine","Shaco","Singed","Sion","Swain","TahmKench","Talon","Taric","Tristana","Trundle","TwistedFate","Twitch","Urgot","Veigar","Vex","Vi","Victor","Warwick","Yone","Yuumi","Zac","Ziggs","Zilean","Zyra"];

    string[] colors = ["gold", "crimson", "blueviolet", "deepskyblue", "seagreen", "darkolivegreen","royalblue","sienna","tomato","firebrick","dimgrey"];
    uint256 maxMint = 50;
    event NewNFTMinted(address sender, uint256 tokenId);

    constructor() ERC721 ("TeamfightTactics", "TFT"){
        console.log("This is my TeamfightTactics NFT");
    }

    function pickRandomFirstWord(uint256 tokenId) public view returns (string memory) {
        // I seed the random generator. More on this in the lesson. 
        uint256 rand = random(string(abi.encodePacked("FIRST_WORD", block.timestamp, Strings.toString(tokenId))));
        // Squash the # between 0 and the length of the array to avoid going out of bounds.
        rand = rand % firstWords.length;
    return firstWords[rand];
    }

    function pickRandomSecondWord(uint256 tokenId) public view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("SECOND_WORD", block.timestamp,Strings.toString(tokenId))));
        rand = rand % secondWords.length;
        return secondWords[rand];
    }

    function pickRandomThirdWord(uint256 tokenId) public view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("THIRD_WORD", block.timestamp,Strings.toString(tokenId))));
        rand = rand % thirdWords.length;
        return thirdWords[rand];
    }

     // Same old stuff, pick a random color.
    function pickRandomColor(uint256 tokenId) public view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("COLOR",block.timestamp, Strings.toString(tokenId))));
        rand = rand % colors.length;
        return colors[rand];
    }

    function getTotalNFTCount() external view returns (uint256) {
        return _tokenIds.current();
    }

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }
     // A function our user will hit to get their NFT.
    function makeAnEpicNFT() public {
        
        // Get the current tokenId, this starts at 0.
        require(_tokenIds.current() <= maxMint);
        uint256 newItemId = _tokenIds.current();
        // We go and randomly grab one word from each of the three arrays.
        string memory first = pickRandomFirstWord(newItemId);
        string memory second = pickRandomSecondWord(newItemId);
        string memory third = pickRandomThirdWord(newItemId);
        string memory color = pickRandomColor(newItemId);
        string memory combinedWord = string(abi.encodePacked(first, second, third));

        

        // I concatenate it all together, and then close the <text> and <svg> tags.
        string memory finalSvg = string(abi.encodePacked(svgPartOne, color, svgPartTwo, combinedWord, "</text></svg>"));

        // Get all the JSON metadata in place and base64 encode it.
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        // We set the title of our NFT as the generated word.
                        combinedWord,
                        '", "description": "TFT Heroes", "image": "data:image/svg+xml;base64,',
                        // We add data:image/svg+xml;base64 and then append our base64 encode our svg.
                        Base64.encode(bytes(finalSvg)),
                        '"}'
                    )
                )
            )
        );
        // Just like before, we prepend data:application/json;base64, to our data.
        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        console.log("\n--------------------");
        console.log(
            string(
                abi.encodePacked(
                    "https://nftpreview.0xdev.codes/?code=",
                    finalTokenUri
                )
            )
        );
        console.log("--------------------\n");

        _safeMint(msg.sender, newItemId);
        
        // Update your URI!!!
        _setTokenURI(newItemId, finalTokenUri);
    
        _tokenIds.increment();
        console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);

        emit NewNFTMinted(msg.sender, newItemId);
        }
}