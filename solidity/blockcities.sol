// BlockCities 1st Run @ ERC721 contracts
// Initial Template forked from CryptoKitties Source code
// Copied from: https://etherscan.io/address/0x06012c8cf97bead5deae237070f9587f8e7a266d#code
// https://ethfiddle.com/09YbyJRfiI
pragma solidity ^0.4.18;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;
  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner. This prevents double ownership.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current building owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }
}

/// @title Interface for contracts conforming to ERC-721: Non-Fungible Tokens
/// @author Dieter Shirley <dete@axiomzen.co> (https://github.com/dete)
contract ERC721 {
    // Required methods
    function totalSupply() public view returns (uint256 total);
    function balanceOf(address _owner) public view returns (uint256 balance);
    function ownerOf(uint256 _tokenId) external view returns (address owner);
    function approve(address _to, uint256 _tokenId) external;
    function transfer(address _to, uint256 _tokenId) external;
    function transferFrom(address _from, address _to, uint256 _tokenId) external;
    // Events
    event Transfer(address from, address to, uint256 tokenId);
    event Approval(address owner, address approved, uint256 tokenId);
    // 3 optional ERC721 functions that we will use later
    // function name() public view returns (string name);
    // function tokensOfOwner(address _owner) external view returns (uint256[] tokenIds);
    // function tokenMetadata(uint256 _tokenId, string _preferredTransport) public view returns (string infoUrl);

    // ERC-165 Compatibility (https://github.com/ethereum/EIPs/issues/165)
    function supportsInterface(bytes4 _interfaceID) external view returns (bool);
}
// // Auction wrapper functions

// Auction wrapper functions
// private formula to mix stuff

contract BlueprintMixing {
    function isBlueprintPlan() public pure returns (bool);
    /// @dev given blueprints of buildings 1 & 2, return a genetic building combination w/ some randomness
    /// @param constructingId DNA of constructing
    /// @param blueprintId DNA of building2
    /// currently housed in some Python code.
    /// @return the DNA that is supposed to be passed down the child
    function mixBlueprints(uint256 constructingId, uint256 blueprintId, uint256 targetBlock) public returns (uint256);
}

/// @title A facet of BuildingCore that manages special access privileges.
/// @dev See the BuildingCore contract documentation to understand how the various contract facets are arranged.
contract BuildingAccessControl {
    // will update to reflect BlockCities ideas
    // This facet controls access control for BlockCities. There are four roles managed here:
    
    //     - The CEO: The CEO can reassign other roles and change the addresses of our dependent smart
    //         contracts. It is also the only role that can unpause the smart contract. It is initially
    //         set to the address that created the smart contract in the BuildingCore constructor.
    
    //     - The CFO: The CFO can withdraw funds from BuildingCore and its auction contracts.
    
    //     - The COO: The COO can release era0 buildings to auction, and mint promo buildings.
    
    // It should be noted that these roles are distinct without overlap in their access abilities, the
    // abilities listed for each role above are exhaustive. In particular, while the CEO can assign any
    // address to any role, the CEO address itself doesn't have the ability to act in those roles. This
    // restriction is intentional so that we aren't tempted to use the CEO address frequently out of
    // convenience. The less we use an address, the less likely it is that we somehow compromise the
    // account.

    /// @dev Emited when contract is upgraded - See README.md for updgrade plan
    event ContractUpgrade(address newContract);

    // The addresses of the accounts (or contracts) that can execute actions within each roles.
    address public ceoAddress;
    address public cfoAddress;
    address public cooAddress;

    // @dev Keeps track whether the contract is paused. When that is true, most actions are blocked
    bool public paused = false;

    /// @dev Access modifier for CEO-only functionality
    modifier onlyCEO() {
        require(msg.sender == ceoAddress);
        _;
    }

    /// @dev Access modifier for CFO-only functionality
    modifier onlyCFO() {
        require(msg.sender == cfoAddress);
        _;
    }

    /// @dev Access modifier for COO-only functionality
    modifier onlyCOO() {
        require(msg.sender == cooAddress);
        _;
    }
    /// @dev Must be a CEO, CFO, or COO to use
    modifier onlyCLevel() {
        require(
            msg.sender == cooAddress ||
            msg.sender == ceoAddress ||
            msg.sender == cfoAddress
        );
        _;
    }

    /// @dev Assigns a new address to act as the CEO. Only available to the current CEO.
    /// @param _newCEO The address of the new CEO
    function setCEO(address _newCEO) external onlyCEO {
        require(_newCEO != address(0));

        ceoAddress = _newCEO;
    }

    /// @dev Assigns a new address to act as the CFO. Only available to the current CEO.
    /// @param _newCFO The address of the new CFO
    function setCFO(address _newCFO) external onlyCEO {
        require(_newCFO != address(0));

        cfoAddress = _newCFO;
    }

    /// @dev Assigns a new address to act as the COO. Only available to the current CEO.
    /// @param _newCOO The address of the new COO
    function setCOO(address _newCOO) external onlyCEO {
        require(_newCOO != address(0));

        cooAddress = _newCOO;
    }

    /*** Pausable functionality adapted from OpenZeppelin ***/

    /// @dev Modifier to allow actions only when the contract IS NOT paused
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /// @dev Modifier to allow actions only when the contract IS paused
    modifier whenPaused {
        require(paused);
        _;
    }

    /// @dev Called by any "C-level" role to pause the contract. Used only when
    ///  a bug or exploit is detected and we need to limit damage.
    function pause() external onlyCLevel whenNotPaused {
        paused = true;
    }

    /// @dev Unpauses the smart contract. Can only be called by the CEO, since
    ///  one reason we may pause the contract is when CFO or COO accounts are
    ///  compromised.
    /// @notice This is public rather than external so it can be called by
    ///  derived contracts.
    function unpause() public onlyCEO whenPaused {
        // can't unpause if contract was upgraded
        paused = false;
    }
}
/// @title Blockcities basic contract containing the main structs, events, etc.
/// @author Credits to Axiom Zen (https://www.axiomzen.co), Opensea, and OpenZeppelin 
/// @dev See the BuildingCore contract documentation to understand how the various contract facets are arranged.
contract BuildingBase is BuildingAccessControl {
    /*** EVENTS ***/

    /// @dev The Build event occurs either by "construction" by 2 constructing buildings, or when era0 buildings are minted.
    ///  when a new era0 building is created.
    event Build(address owner, uint256 buildingId, uint256 blueprintId, uint256 constructingId, uint256 DNA);

    /// @dev Transfer event as defined in current draft of ERC721. Emitted every time a building
    ///  ownership is assigned, including births.
    event Transfer(address from, address to, uint256 tokenId);

    /*** DATA TYPES ***/

    /// @dev Make sure this fits into 256 bits - if we add/subtract anything, 
    /// make sure it still fits into 256 bits for gas optimization.
    struct Building {
        // The Buildings's genetic code is for the time being, permanent (maybe renovation abilities in the future)
        uint256 DNA;
        // The timestamp from the block when this building came into existence.
        uint64 constructTime;
        // The minimum timestamp after which this building can engage in blueprinting
        // activities again. Buildings are not gendered.
        uint64 cooldownEndBlock;

        // The ID of the blueprint buildings (parents), set to 0 for era0 buildings.
        // Note that using 32-bit unsigned integers limits us to a "mere" 4 billion buildings. This number might seem small until you realize
        // that Ethereum currently has a limit of about 500 million
        // transactions per year! We can revisit this when we have enough buildings to worry about this.
        uint32 blueprintId;
        uint32 constructingId;
        // Set to the ID of blueprintId when constructingId is building the building. Used to gather traits from both "parents"
        uint32 blueprintingWithId;

        // Set to the index in the cooldown array (see below) that represents
        // the current cooldown duration for this Building. This starts at zero
        // for era0 buildings, and is initialized to floor(era/2) for others.
        // Incremented by one for each successful building action.
        uint16 cooldownIndex;

        // The "era number" of this building. Unique, real-world buildings start out as minted
        // by the BlockCities team, and have an era number of 0. The
        // era number of all other building is the larger of the two era 'numbers of their parents, plus one.
        // (i.e. max(constructingId.era, blueprintId.era) + 1)
        uint16 era;
    }

    /*** CONSTANTS ***/
    /// @dev A lookup table indicating the cooldown duration after any successful
    ///  building action, called "construction time". Designed such that the cooldown roughly doubles each time a building
    ///  is built, encouraging owners not to just keep blueprinting the same building repeatedly (max time is 7 days as of now).
    uint32[14] public cooldowns = [
        uint32(1 minutes),
        uint32(2 minutes),
        uint32(5 minutes),
        uint32(10 minutes),
        uint32(30 minutes),
        uint32(1 hours),
        uint32(2 hours),
        uint32(4 hours),
        uint32(8 hours),
        uint32(16 hours),
        uint32(1 days),
        uint32(2 days),
        uint32(4 days),
        uint32(7 days)
    ];

    // An approximation of currently how many seconds are in between blocks.
    // Current approximation according to Quora is 15.3 seconds :) 
    uint256 public secondsPerBlock = 15;

    /*** STORAGE ***/

    /// @dev An array that will store all of the Building struct for all buildings ever.
    Building[] buildings;

    /// @dev A mapping from building IDs to the address that owns them. All buildings (even era0 ones) have non-zero owner
    mapping (uint256 => address) public buildingIndexToOwner;

    // @dev A mapping from owner address to count of tokens that address owns.
    //  Used internally inside balanceOf() to resolve ownership count.
    mapping (address => uint256) ownershipTokenCount;

    /// @dev A mapping from BuildingIDs to an address that has been approved to call transferFrom(). 
    /// Zero means no approvals outstanding; each building can only have one approved address at a time.
    mapping (uint256 => address) public buildingIndexToApproved;

    /// @dev A mapping from BuildingIDs to an address that has been approved to call blueprintWith()). 
    /// Zero means no approvals outstanding; each building can only have one approved address at a time.
    mapping (uint256 => address) public blueprintAllowedToAddress;

    /// @dev The address of the ClockAuction contract that handles sales of Buildings. 
    SaleClockAuction public saleAuction;

    /// @dev The address of a custom ClockAuction subclassed contract that handles blueprinting
    ///  auctions. Needs to be separate from saleAuction because the actions taken on success
    ///  after a sales and blueprinting auction are quite different.
    blueprintingClockAuction public blueprintingAuction;

    /// @dev Assigns ownership of a specific Building to an address.
    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        // Since the number of buildings is capped to 2^32 we can't overflow this
        ownershipTokenCount[_to]++;
        // transfer ownership
        buildingIndexToOwner[_tokenId] = _to;
        // When creating new buildings _from is 0x0, but we can't account that address.
        if (_from != address(0)) {
            ownershipTokenCount[_from]--;
            // once the building is transferred also clear blueprinting allowances
            delete blueprintAllowedToAddress[_tokenId];
            // clear any previously approved ownership exchange
            delete buildingIndexToApproved[_tokenId];
        }
        // Emit the transfer event.
        Transfer(_from, _to, _tokenId);
    }

    /// @dev An internal method that creates a new Building and stores it. Will generate both a Build event
    ///  and a Transfer event.
    /// @param _constructingId The Building ID of the constructingId of this building (zero for era0)
    /// @param _blueprintId The Building ID of the blueprintId of this building (zero for era0)
    /// @param _era The era number of this building, must be computed by caller.
    /// @param _DNA The building's genetic code.
    /// @param _owner The inital owner of this building, must be non-zero, save for the very first building
    function _createBuilding(
        uint256 _constructingId,
        uint256 _blueprintId,
        uint256 _era,
        uint256 _DNA,
        address _owner
    )
        internal
        returns (uint)
    {
        // These requires are not strictly necessary, our calling code should make
        // sure that these conditions are never broken. However! _createBuilding() is already
        // an expensive call (for storage), and it doesn't hurt to be especially careful
        // to ensure our data structures are always valid.
        // Choosing not to include these functions at this time
        // require(_constructingId == uint256(uint32(_constructingId)));
        // require(_blueprintId == uint256(uint32(_blueprintId)));
        // require(_era == uint256(uint16(_era)));

        // New building starts with the same cooldown as parent era/2
        uint16 cooldownIndex = uint16(_era / 2);
        if (cooldownIndex > 13) {
            cooldownIndex = 13;
        }

        Building memory _Building = Building({
            DNA: _DNA,
            constructTime: uint64(now),
            cooldownEndBlock: 0,
            constructingId: uint32(_constructingId),
            blueprintId: uint32(_blueprintId),
            blueprintingWithId: 0,
            cooldownIndex: cooldownIndex,
            era: uint16(_era)
        });
        uint256 newBuildingId = buildings.push(_Building) - 1;

        // It's probably never going to happen, 4 billion buildings is A LOT, but
        // let's just be 100% sure we never let this happen.
        require(newBuildingId == uint256(uint32(newBuildingId)));

        // emit the birth event
        Build(
            _owner,
            newBuildingId,
            uint256(_Building.constructingId),
            uint256(_Building.blueprintId),
            _Building.DNA
        );
        // This will assign ownership, and also emit the Transfer event as per ERC721 draft
        _transfer(0, _owner, newBuildingId);
        return newBuildingId;
    }

    // Any C-level can fix how many seconds per blocks are currently observed.
    function setSecondsPerBlock(uint256 secs) external onlyCLevel {
        require(secs < cooldowns[0]);
        secondsPerBlock = secs;
    }
}

/// @title The external contract that is responsible for generating metadata for the buildings,
///  it has one function that will return the data as bytes.
contract ERC721Metadata {
    /// @dev Given a token Id, returns a byte array that is supposed to be converted into string.
    function getMetadata(uint256 _tokenId, string) public view returns (bytes32[4] buffer, uint256 count) {
        if (_tokenId == 1) {
            buffer[0] = "Hello World! :D";
            count = 15;
        } else if (_tokenId == 2) {
            buffer[0] = "I would definitely choose a medi";
            buffer[1] = "um length string.";
            count = 49;
        } else if (_tokenId == 3) {
            buffer[0] = "Lorem ipsum dolor sit amet, mi e";
            buffer[1] = "st accumsan dapibus augue lorem,";
            buffer[2] = " tristique vestibulum id, libero";
            buffer[3] = " suscipit varius sapien aliquam.";
            count = 128;
        }
    }
}
// the above code is interesting, but why segment the metadata into just three choices?

/// @title The facet of the core contract that manages ownership, ERC-721 (draft) compliant.
/// @author Axiom Zen (https://www.axiomzen.co)
/// @dev Ref: https://github.com/ethereum/EIPs/issues/721
///  See the BuildingCore contract documentation to understand how the various contract facets are arranged.
contract BuildingOwnership is BuildingBase, ERC721 {

    /// @notice Name and symbol of the non fungible token, as defined in ERC721.
    string public constant name = "BlockCities";
    string public constant symbol = "BC";

    // The contract that will return Building metadata
    ERC721Metadata public erc721Metadata;

    bytes4 constant InterfaceSignature_ERC165 =
        bytes4(keccak256('supportsInterface(bytes4)'));

    bytes4 constant InterfaceSignature_ERC721 =
        bytes4(keccak256('name()')) ^
        bytes4(keccak256('symbol()')) ^
        bytes4(keccak256('totalSupply()')) ^
        bytes4(keccak256('balanceOf(address)')) ^
        bytes4(keccak256('ownerOf(uint256)')) ^
        bytes4(keccak256('approve(address,uint256)')) ^
        bytes4(keccak256('transfer(address,uint256)')) ^
        bytes4(keccak256('transferFrom(address,address,uint256)')) ^
        bytes4(keccak256('tokensOfOwner(address)')) ^
        bytes4(keccak256('tokenMetadata(uint256,string)'));

    /// @notice Introspection interface as per ERC-165 (https://github.com/ethereum/EIPs/issues/165).
    ///  Returns true for any standardized interfaces implemented by this contract (ERC-165 and ERC-721).
    function supportsInterface(bytes4 _interfaceID) external view returns (bool)
    {
        return ((_interfaceID == InterfaceSignature_ERC165) || (_interfaceID == InterfaceSignature_ERC721));
    }

    /// @dev Set the address of the sibling contract that tracks metadata.
    ///  CEO only.
    function setMetadataAddress(address _contractAddress) public onlyCEO {
        erc721Metadata = ERC721Metadata(_contractAddress);
    }

    // Internal utility functions: These functions all assume that their input arguments
    // are valid. We leave it to public methods to sanitize their inputs and follow the required logic.

    /// @dev Checks if a given address is the current owner of a particular Building.
    /// @param _claimant the address we are validating against.
    /// @param _tokenId Building id, only valid when > 0
    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return buildingIndexToOwner[_tokenId] == _claimant;
    }

    /// @dev Checks if a given address currently has transferApproval for a particular Building.
    /// @param _claimant the address we are confirming Building is approved for.
    /// @param _tokenId Building id, only valid when > 0
    function _approvedFor(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return buildingIndexToApproved[_tokenId] == _claimant;
    }

    /// @dev Marks an address as being approved for transferFrom(), overwriting any previous
    ///  approval. Setting _approved to address(0) clears all transfer approval.
    ///  NOTE: _approve() does NOT send the Approval event. This is intentional because
    ///  _approve() and transferFrom() are used together for putting Buildings on auction, and
    ///  there is no value in spamming the log with Approval events in that case. ***
    function _approve(uint256 _tokenId, address _approved) internal {
        buildingIndexToApproved[_tokenId] = _approved;
    }

    /// @notice Returns the number of Buildings owned by a specific address.
    /// @param _owner The owner address to check.
    /// @dev Required for ERC-721 compliance
    function balanceOf(address _owner) public view returns (uint256 count) {
        return ownershipTokenCount[_owner];
    }

    /// @notice Transfers a Building to another address. If transferring to a smart contract be VERY CAREFUL to ensure 
    /// that it is aware of ERC-721 Tokens/BlockCities Tokens or your Building may be lost forever. Seriously.
    /// @param _to The address of the recipient, can be a user or contract.
    /// @param _tokenId The ID of the Building to transfer.
    /// @dev Required for ERC-721 compliance.
    function transfer(
        address _to,
        uint256 _tokenId
    )
        external
        whenNotPaused
    {
        // Safety check to prevent against an unexpected 0x0 default.
        require(_to != address(0));
        // Disallow transfers to this contract to prevent accidental misuse.
        // The contract should never own any Buildings (except very briefly
        // after a era0 building is created and before it goes on auction).
        require(_to != address(this));
        // Disallow transfers to the auction contracts to prevent accidental
        // misuse. Auction contracts should only take ownership of buildings.
        // through the allow + transferFrom flow.
        require(_to != address(saleAuction));
        require(_to != address(blueprintingAuction));

        // You can only send your own buildings. 
        require(_owns(msg.sender, _tokenId));

        // Reassign ownership, clear pending approvals, emit Transfer event.
        _transfer(msg.sender, _to, _tokenId);
    }

    /// @notice Grant another address the right to transfer a specific Building via
    ///  transferFrom(). This is the preferred flow for transfering NFTs to contracts.
    /// @param _to The address to be granted transfer approval. Pass address(0) to
    ///  clear all approvals.
    /// @param _tokenId The ID of the Building that can be transferred if this call succeeds.
    /// @dev Required for ERC-721 compliance.
    function approve(
        address _to,
        uint256 _tokenId
    )
        external
        whenNotPaused
    {
        // Only an owner can grant transfer approval.
        require(_owns(msg.sender, _tokenId));

        // Register the approval (replacing any previous approval).
        _approve(_tokenId, _to);

        // Emit approval event.
        Approval(msg.sender, _to, _tokenId);
    }

    /// @notice Transfer a Building owned by another address, for which the calling address
    ///  has previously been granted transfer approval by the owner.
    /// @param _from The address that owns the Building to be transfered.
    /// @param _to The address that should take ownership of the Building. Can be any address,
    ///  including the caller.
    /// @param _tokenId The ID of the Building to be transferred.
    /// @dev Required for ERC-721 compliance.
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    )
        external
        whenNotPaused
    {
        // Safety check to prevent against an unexpected 0x0 default.
        require(_to != address(0));
        // Disallow transfers to this contract to prevent accidental misuse.
        // The contract should never own any Buildings (except very briefly
        // after a era0 building is created and before it goes on auction).
        require(_to != address(this));
        // Check for approval and valid ownership
        require(_approvedFor(msg.sender, _tokenId));
        require(_owns(_from, _tokenId));

        // Reassign ownership (also clears pending approvals and emits Transfer event).
        _transfer(_from, _to, _tokenId);
    }

    /// @notice Returns the total number of Buildings currently in existence.
    /// @dev Required for ERC-721 compliance.
    function totalSupply() public view returns (uint) {
        return buildings.length - 1;
    }

    /// @notice Returns the address currently assigned ownership of a given Building.
    /// @dev Required for ERC-721 compliance.
    function ownerOf(uint256 _tokenId)
        external
        view
        returns (address owner)
    {
        owner = buildingIndexToOwner[_tokenId];

        require(owner != address(0));
    }

    /// @notice Returns a list of all Building IDs assigned to an address.
    /// @param _owner The owner whose Buildings we are interested in.
    /// @dev This method MUST NEVER be called by smart contract code. ******  First, it's fairly
    ///  expensive (it walks the entire Building array looking for building belonging to owner),
    ///  but it also returns a dynamic array, which is only supported for web3 calls, and
    ///  not contract-to-contract calls.
    function tokensOfOwner(address _owner) external view returns(uint256[] ownerTokens) {
        uint256 tokenCount = balanceOf(_owner);

        if (tokenCount == 0) {
            // Return an empty array
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            uint256 totalBuildings = totalSupply();
            uint256 resultIndex = 0;

            // We count on the fact that all buildings have IDs starting at 1 and increasing
            // sequentially up to the totalBuildings count.
            // BlockCities note: this seems slow from original CK code, will see if we can improve on this.
            uint256 buildingId;

            for (buildingId = 1; buildingId <= totalBuildings; buildingId++) {
                if (buildingIndexToOwner[buildingId] == _owner) {
                    result[resultIndex] = buildingId;
                    resultIndex++;
                }
            }

            return result;
        }
    }

    /// @dev Adapted from memcpy() by @arachnid (Nick Johnson <arachnid@notdot.net>)
    ///  This method is licenced under the Apache License.
    ///  Ref: https://github.com/Arachnid/solidity-stringutils/blob/2f6ca9accb48ae14c66f1437ec50ed19a0616f78/strings.sol
    function _memcpy(uint _dest, uint _src, uint _len) private view {
        // Copy word-length chunks while possible
        for(; _len >= 32; _len -= 32) {
            assembly {
                mstore(_dest, mload(_src))
            }
            _dest += 32;
            _src += 32;
        }

        // Copy remaining bytes
        uint256 mask = 256 ** (32 - _len) - 1;
        assembly {
            let srcpart := and(mload(_src), not(mask))
            let destpart := and(mload(_dest), mask)
            mstore(_dest, or(destpart, srcpart))
        }
    }
// This encrypts the building back to a number
    /// @dev Adapted from toString(slice) by @arachnid (Nick Johnson <arachnid@notdot.net>)
    ///  This method is licenced under the Apache License.
    ///  Ref: https://github.com/Arachnid/solidity-stringutils/blob/2f6ca9accb48ae14c66f1437ec50ed19a0616f78/strings.sol
    function _toString(bytes32[4] _rawBytes, uint256 _stringLength) private view returns (string) {
        var outputString = new string(_stringLength);
        uint256 outputPtr;
        uint256 bytesPtr;

        assembly {
            outputPtr := add(outputString, 32)
            bytesPtr := _rawBytes
        }

        _memcpy(outputPtr, bytesPtr, _stringLength);

        return outputString;
    }

    /// @notice Returns a URI pointing to a metadata package for this token conforming to
    ///  ERC-721 (https://github.com/ethereum/EIPs/issues/721)
    /// @param _tokenId The ID number of the Building whose metadata should be returned.
    function tokenMetadata(uint256 _tokenId, string _preferredTransport) external view returns (string infoUrl) {
        require(erc721Metadata != address(0));
        bytes32[4] memory buffer;
        uint256 count;
        (buffer, count) = erc721Metadata.getMetadata(_tokenId, _preferredTransport);

        return _toString(buffer, count);
    }
}

/// @title A facet of BuildingCore that manages Building blueprinting, gestation, and birth.
/// @author Axiom Zen (https://www.axiomzen.co)
/// @dev See the BuildingCore contract documentation to understand how the various contract facets are arranged.
contract BuildingBlueprinting is BuildingOwnership {

    /// @dev The Constructing event is fired when two buildings successfully breed and the pregnancy
    ///  timer begins for the constructing.
    event Constructing(address owner, uint256 constructingId, uint256 blueprintId, uint256 cooldownEndBlock);

    /// @notice The minimum payment required to use constructWithAuto(). This fee goes towards
    ///  the gas cost paid by whatever calls giveBirth(), and can be dynamically updated by
    ///  the COO role as the gas price changes.
    uint256 public autoBirthFee = 2 finney;
    // Keeps track of number of Constructing buidings. ** check if this is double for both buildings involved in a blueprint session. 
    uint256 public ConstructingBuildings;

    /// @dev The address of the sibling contract that is used to implement the sooper-sekret genetic combination algorithm.
    BlueprintMixing public BlueprintInfo;

    /// @dev Update the address of the genetic contract, can only be called by the CEO.
    /// @param _address An address of a BuildingFormula contract instance to be used from this point forward.
    // ** May have used the wrong BlueprintFormula DOUBLE CHECK IF THIS IS CORRECT
    function setBuildingFormulaAddress(address _address) external onlyCEO {
        BlueprintMixing candidateContract = BlueprintMixing(_address);

        // NOTE: verify that a contract is what we expect - https://github.com/Lunyr/crowdsale-contracts/blob/cfadd15986c30521d8ba7d5b6f57b4fefcc7ac38/contracts/LunyrToken.sol#L117
        require(candidateContract.isBlueprintPlan());
        // Set the new contract address
        BlueprintInfo = candidateContract;
    }

    /// @dev Checks that a given Building is able to breed. Requires that the
    ///  current cooldown is finished (for blueprints) and also checks that there is
    ///  no pending pregnancy.
    function _isReadyToConstruct(Building _built) internal view returns (bool) {
        // In addition to checking the cooldownEndBlock, we also need to check to see if
        // the building has a pending birth; there can be some period of time between the end
        // of the pregnacy timer and the birth event.
        return (_built.blueprintingWithId == 0) && (_built.cooldownEndBlock <= uint64(block.number));
    }

    /// @dev Check if a constructinghas authorized blueprinting with this constructing. True if both blueprint
    ///  and constructing have the same owner, or if the constructinghas given blueprinting permission to
    ///  the constructing's owner (via approveblueprinting()).
    function _isblueprintingPermitted(uint256 _blueprintId, uint256 _constructingId) internal view returns (bool) {
        address constructingOwner = buildingIndexToOwner[_constructingId];
        address blueprintOwner = buildingIndexToOwner[_blueprintId];

        // blueprinting is okay if they have same owner, or if the constructing's owner was given
        // permission to breed with this blueprint.
        return (constructingOwner == blueprintOwner || blueprintAllowedToAddress[_blueprintId] == constructingOwner);
    }

    /// @dev Set the cooldownEndTime for the given building, based on its current cooldownIndex.
    ///  Also increments the cooldownIndex (unless it has hit the cap).
    /// @param _Building A reference to the Building in storage which needs its timer started.
    function _triggerCooldown(Building storage _building) internal {
        // Compute an estimation of the cooldown time in blocks (based on current cooldownIndex).
        _building.cooldownEndBlock = uint64((cooldowns[_building.cooldownIndex]/secondsPerBlock) + block.number);

        // Increment the blueprinting count, clamping it at 13, which is the length of the
        // cooldowns array. We could check the array size dynamically, but hard-coding
        // this as a constant saves gas. Yay, Solidity!
        if (_building.cooldownIndex < 13) {
            _building.cooldownIndex += 1;
        }
    }

    /// @notice Grants approval to another user to bleuprint with one of your buildings.
    /// @param _addr The address that will be able to blueprint with your Building. Set to
    ///  address(0) to clear all blueprinting approvals for this Building.
    /// @param _blueprintId A Building that you own that _addr will now be able to bleuprint with.
    function approveblueprinting(address _addr, uint256 _blueprintId)
        external
        whenNotPaused
    {
        require(_owns(msg.sender, _blueprintId));
        blueprintAllowedToAddress[_blueprintId] = _addr;
    }

    /// @dev Updates the minimum payment required for calling giveBirthAuto(). Can only
    ///  be called by the COO address. (This fee is used to offset the gas cost incurred by the autobirth daemon).
    function setAutoBirthFee(uint256 val) external onlyCOO {
        autoBirthFee = val;
    }

    /// @dev Checks to see if a given Building is Constructing and (if so) if the gestation
    ///  period has passed.
    function _isReadyToGiveBirth(Building _constructing) private view returns (bool) {
        return (_constructing.blueprintingWithId != 0) && (_constructing.cooldownEndBlock <= uint64(block.number));
    }

    /// @notice Checks that a given Building is able to breed (i.e. it is not Constructing or
    ///  in the middle of a blueprinting cooldown).
    /// @param _buildingId reference the id of the building, any user can inquire about it
    function isReadyToConstruct(uint256 _buildingId)
        public
        view
        returns (bool)
    {
        require(_buildingId > 0);
        Building storage built = buildings[_buildingId];
        return _isReadyToConstruct(built);
    }

    /// @dev Checks whether a Building is currently Constructing.
    /// @param _buildingId reference the id of the building (public)
    function isConstructing(uint256 _buildingId)
        public
        view
        returns (bool)
    {
        require(_buildingId > 0);
        // A Building is Constructing if and only if this field is set
        return buildings[_buildingId].blueprintingWithId != 0;
    }

    /// @dev Internal check to see if a given constructingand constructing are a valid constructing pair. DOES NOT
    ///  check ownership permissions (that is up to the caller).
    /// @param _constructing A reference to the Building struct of the potential constructing.
    /// @param _constructingId The constructing's ID.
    /// @param _building A reference to the Building struct of the potential blueprint.
    /// @param _blueprintId The blueprint's ID
    function _isValidConstructingPair(
        Building storage constructing,
        uint256 _constructingId,
        Building storage blueprint,
        uint256 _blueprintId
    )
        private
        view
        returns(bool)
    {
        // A Building can't breed with itself!
        if (_constructingId == _blueprintId) {
            return false;
        }

        // Buildings can't breed with their parents.
        if (constructing.constructingId == _blueprintId || constructing.blueprintId == _blueprintId) {
            return false;
        }
        if (blueprint.constructingId == _constructingId || blueprint.blueprintId == _constructingId) {
            return false;
        }

        // We can short circuit the sibling check (below) if either building is
        // gen zero (has a constructing ID of zero).
        if (blueprint.constructingId == 0 || constructing.constructingId == 0) {
            return true;
        }

        // Buildings can't breed with full or half siblings.
        if (blueprint.constructingId == constructing.constructingId || blueprint.constructingId == constructing.blueprintId) {
            return false;
        }
        if (blueprint.blueprintId == constructing.constructingId || blueprint.blueprintId == constructing.blueprintId) {
            return false;
        }

        // Everything seems cool! Let's get DTF.
        return true;
    }

    /// @dev Internal check to see if a given constructingand constructing are a valid constructing pair for
    ///  blueprinting via auction (i.e. skips ownership and blueprinting approval checks).
    function _canconstructWithViaAuction(uint256 _constructingId, uint256 _blueprintId)
        internal
        view
        returns (bool)
    {
        Building storage constructing = buildings[_constructingId];
        Building storage blueprinting = buildings[_blueprintId];
        return _isValidConstructingPair(constructing, _constructingId, blueprinting, _blueprintId);
    }

    /// @notice Checks to see if two buildings can breed together, including checks for
    ///  ownership and blueprinting approvals. Does NOT check that both buildings are ready for
    ///  blueprinting (i.e. constructWith could still fail until the cooldowns are finished).
    ///  TODO: Shouldn't this check pregnancy and cooldowns?!? ***
    /// @param _constructingId The ID of the proposed constructing.
    /// @param _blueprintId The ID of the proposed blueprint.
    function canconstructWith(uint256 _constructingId, uint256 _blueprintId)
        external
        view
        returns(bool)
    {
        require(_constructingId > 0);
        require(_blueprintId > 0);
        Building storage constructing = buildings[_constructingId];
        Building storage blueprinting = buildings[_blueprintId];
        return _isValidConstructingPair(constructing, _constructingId, blueprinting, _blueprintId) &&
            _isblueprintingPermitted(_blueprintId, _constructingId);
    }

    /// @dev Internal utility function to initiate blueprinting, assumes that all blueprinting
    ///  requirements have been checked.
    function _constructWith(uint256 _constructingId, uint256 _blueprintId) internal {
        // Grab a reference to the Buildings from storage.
        Building storage constructing= buildings[_blueprintId];
        Building storage blueprinting = buildings[_constructingId];

        // Mark the constructing as Constructing, keeping track of who the constructingis.
        constructing.blueprintingWithId = uint32(_blueprintId);

        // Trigger the cooldown for both parents.
        _triggerCooldown(blueprinting);
        _triggerCooldown(constructing);

        // Clear blueprinting permission for both parents. This may not be strictly necessary
        // but it's likely to avoid confusion!
        delete blueprintAllowedToAddress[_constructingId];
        delete blueprintAllowedToAddress[_blueprintId];

        // Every time a Building gets Constructing, counter is incremented.
        ConstructingBuildings++;

        // Emit the pregnancy event.
        Constructing(buildingIndexToOwner[_constructingId], _constructingId, _blueprintId, constructing.cooldownEndBlock);
    }

    /// @notice Breed a Building you own (as constructing) with a constructingthat you own, or for which you
    ///  have previously been given blueprinting approval. Will either allow your building to begin constructing, or will
    ///  fail entirely. Requires a pre-payment of the fee given out to the first caller of giveBirth()
    /// @param _constructingId The ID of the Building acting as constructing (will end up Constructing if successful)
    /// @param _blueprintId The ID of the Building acting as constructing(will begin its blueprinting cooldown if successful)
    function constructWithAuto(uint256 _constructingId, uint256 _blueprintId)
        external
        payable
        whenNotPaused
    {
        // Checks for payment.
        require(msg.value >= autoBirthFee);

        // Caller must own the constructing.
        require(_owns(msg.sender, _constructingId));

        // Neither constructing nor building2 are allowed to be on auction during a normal
        // blueprinting operation, but we don't need to check that explicitly.
        // For constructing: The caller of this function can't be the owner of the constructing
        //   because the owner of a Building on auction is the auction house, and the
        //   auction house will never call constructWith().
        // For blueprint: Similarly, a building2 on auction will be owned by the auction house
        //   and the act of transferring ownership will have cleared any oustanding
        //   blueprinting approval.
        // Thus we don't need to spend gas explicitly checking to see if either building 
        // is on auction.

        // Check that constructing and building2 are both owned by caller, or that the blueprinter
        // has given blueprinting permission to caller (i.e. constructing's owner).
        // Will fail for _blueprintId = 0
        require(_isblueprintingPermitted(_blueprintId, _constructingId));

        // Grab a reference to the potential constructing
        Building storage constructing = buildings[_constructingId];

        // Make sure constructing isn't Constructing, or in the middle of a blueprinting cooldown
        require(_isReadyToConstruct(constructing));

        // Grab a reference to the potential blueprint
        Building storage blueprinting = buildings[_blueprintId];

        // Make sure constructing isn't Constructing, or in the middle of a blueprinting cooldown
        require(_isReadyToGiveBirth(buildings[_blueprintId]));

        // Test that these buildings are a valid constructing pair.
        require(_isValidConstructingPair(
            constructing,
            _constructingId,
            blueprinting,
            _blueprintId
        ));

        // All checks passed, Building gets Constructing!
        _constructWith(_constructingId, _blueprintId);
    }

    /// @notice Have a Constructing Building blueprinting!
    /// @param _constructingId A Building ready to give birth.
    /// @return The Building ID of the new building.
    /// @dev Looks at a given Building and, if Constructing and if the gestation period has passed,
    ///  combines the DNA of the two parents to create a new building. The new Building is assigned
    ///  to the current owner of the constructing. Upon successful completion, both the constructing and the
    ///  new Building will be ready to breed again. Note that anyone can call this function (if they
    ///  are willing to pay the gas!), but the new Building always goes to the mother (constructing)'s owner.
    function giveBirth(uint256 _constructingId)
        external
        whenNotPaused
        returns(uint256)
    {
        // Grab a reference to the constructing in storage.
        Building storage constructing = buildings[_constructingId];

        // Check that the constructing is a valid building.
        require(constructing.constructTime != 0);

        // Check that the constructing is Constructing, and that its time has come!
        require(_isReadyToGiveBirth(constructing));

        // Grab a reference to the constructingin storage.
        uint256 blueprintId = constructing.blueprintingWithId;
        Building storage blueprinting= buildings[blueprintId];

        // Determine the higher era number of the two parents
        uint16 parentGen = constructing.era;
        if (blueprinting.era > constructing.era) {
            parentGen = blueprinting.era;
        }

        // Call the sooper-sekret gene mixing operation.
        uint256 childDNA = BlueprintMixing.mixBlueprints(constructing.DNA, blueprinting.DNA, constructing.cooldownEndBlock - 1);

        // Make the new building!
        address owner = buildingIndexToOwner[_constructingId];
        uint256 buildingId = _createBuilding(_constructingId, constructing.blueprintingWithId, parentGen + 1, childDNA, owner);

        // Clear the reference to constructingfrom the constructing (REQUIRED! Having blueprintingWithId
        // set is what marks a constructing as being Constructing.)
        delete constructing.blueprintingWithId;

        // Every time a Building gives birth counter is decremented.
        ConstructingBuildings--;

        // Send the balance fee to the person who made birth happen.
        msg.sender.send(autoBirthFee);

        // return the new building's ID
        return buildingId;
    }
}


/// @title Auction Core
/// @dev Contains models, variables, and internal methods for the auction.
/// @notice We omit a fallback function to prevent accidental sends to this contract.
contract ClockAuctionBase {
    // Represents an auction on an NFT
    struct Auction {
        // Current owner of NFT
        address seller;
        // Price (in wei) at beginning of auction
        uint128 startingPrice;
        // Price (in wei) at end of auction
        uint128 endingPrice;
        // Duration (in seconds) of auction
        uint64 duration;
        // Time when auction started
        // NOTE: 0 if this auction has been concluded
        uint64 startedAt;
    }

    // Reference to contract tracking NFT ownership
    ERC721 public nonFungibleContract;
    // Cut owner takes on each auction, measured in basis points (1/100 of a percent).
    // Values 0-10,000 map to 0%-100%
    uint256 public ownerCut;

    // Map from token ID to their corresponding auction.
    mapping (uint256 => Auction) tokenIdToAuction;

    event AuctionCreated(uint256 tokenId, uint256 startingPrice, uint256 endingPrice, uint256 duration);
    event AuctionSuccessful(uint256 tokenId, uint256 totalPrice, address winner);
    event AuctionCancelled(uint256 tokenId);

    /// @dev Returns true if the claimant owns the token.
    /// @param _claimant - Address claiming to own the token.
    /// @param _tokenId - ID of token whose ownership to verify.
    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return (nonFungibleContract.ownerOf(_tokenId) == _claimant);
    }

    /// @dev Escrows the NFT, assigning ownership to this contract.
    /// Throws if the escrow fails.
    /// @param _owner - Current owner address of token to escrow.
    /// @param _tokenId - ID of token whose approval to verify.
    function _escrow(address _owner, uint256 _tokenId) internal {
        // it will throw if transfer fails
        nonFungibleContract.transferFrom(_owner, this, _tokenId);
    }

    /// @dev Transfers an NFT owned by this contract to another address.
    /// Returns true if the transfer succeeds.
    /// @param _receiver - Address to transfer NFT to.
    /// @param _tokenId - ID of token to transfer.
    function _transfer(address _receiver, uint256 _tokenId) internal {
        // it will throw if transfer fails
        nonFungibleContract.transfer(_receiver, _tokenId);
    }

    /// @dev Adds an auction to the list of open auctions. Also fires the
    ///  AuctionCreated event.
    /// @param _tokenId The ID of the token to be put on auction.
    /// @param _auction Auction to add.
    function _addAuction(uint256 _tokenId, Auction _auction) internal {
        // Require that all auctions have a duration of
        // at least one minute. (Keeps our math from getting hairy!)
        require(_auction.duration >= 1 minutes);

        tokenIdToAuction[_tokenId] = _auction;

        AuctionCreated(
            uint256(_tokenId),
            uint256(_auction.startingPrice),
            uint256(_auction.endingPrice),
            uint256(_auction.duration)
        );
    }

    /// @dev Cancels an auction unconditionally.
    function _cancelAuction(uint256 _tokenId, address _seller) internal {
        _removeAuction(_tokenId);
        _transfer(_seller, _tokenId);
        AuctionCancelled(_tokenId);
    }

    /// @dev Computes the price and transfers winnings.
    /// Does NOT transfer ownership of token.
    function _bid(uint256 _tokenId, uint256 _bidAmount)
        internal
        returns (uint256)
    {
        // Get a reference to the auction struct
        Auction storage auction = tokenIdToAuction[_tokenId];

        // Explicitly check that this auction is currently live.
        // (Because of how Ethereum mappings work, we can't just count
        // on the lookup above failing. An invalid _tokenId will just
        // return an auction object that is all zeros.)
        // ** seems like something we can improve on
        require(_isOnAuction(auction));

        // Check that the bid is greater than or equal to the current price
        uint256 price = _currentPrice(auction);
        require(_bidAmount >= price);

        // Grab a reference to the seller before the auction struct
        // gets deleted.
        address seller = auction.seller;

        // The bid is good! Remove the auction before sending the fees
        // to the sender so we can't have a reentrancy attack.
        _removeAuction(_tokenId);

        // Transfer proceeds to seller (if there are any!)
        if (price > 0) {
            // Calculate the auctioneer's cut.
            // (NOTE: _computeCut() is guaranteed to return a
            // value <= price, so this subtraction can't go negative.)
            uint256 auctioneerCut = _computeCut(price);
            uint256 sellerProceeds = price - auctioneerCut;

            // NOTE: Doing a transfer() in the middle of a complex
            // method like this is generally discouraged because of
            // reentrancy attacks and DoS attacks if the seller is
            // a contract with an invalid fallback function. We explicitly
            // guard against reentrancy attacks by removing the auction
            // before calling transfer(), and the only thing the seller
            // can DoS is the sale of their own asset! (And if it's an
            // accident, they can call cancelAuction(). )
            seller.transfer(sellerProceeds);
        }

        // Calculate any excess funds included with the bid. If the excess
        // is anything worth worrying about, transfer it back to bidder.
        // NOTE: We checked above that the bid amount is greater than or
        // equal to the price so this cannot underflow.
        uint256 bidExcess = _bidAmount - price;

        // Return the funds. Similar to the previous transfer, this is not susceptible 
        // to a re-entry attack because the auction is removed before any transfers occur.
        msg.sender.transfer(bidExcess);

        // Tell the world!
        AuctionSuccessful(_tokenId, price, msg.sender);

        return price;
    }

    /// @dev Removes an auction from the list of open auctions. 
    /// @param _tokenId - ID of NFT on auction.
    function _removeAuction(uint256 _tokenId) internal {
        delete tokenIdToAuction[_tokenId];
    }

    /// @dev Returns true if the NFT is on auction.
    /// @param _auction - Auction to check.
    function _isOnAuction(Auction storage _auction) internal view returns (bool) {
        return (_auction.startedAt > 0);
    }

    /// @dev Returns current price of an NFT on auction. Broken into two
    ///  functions (this one, that computes the duration from the auction
    ///  structure, and the other that does the price computation) so we
    ///  can easily test that the price computation works correctly.
    function _currentPrice(Auction storage _auction)
        internal
        view
        returns (uint256)
    {
        uint256 secondsPassed = 0;

        // A bit of insurance against negative values (or wraparound).
        // Probably not necessary (since Ethereum guarnatees that the
        // now variable doesn't ever go backwards).
        if (now > _auction.startedAt) {
            secondsPassed = now - _auction.startedAt;
        }

        return _computeCurrentPrice(
            _auction.startingPrice,
            _auction.endingPrice,
            _auction.duration,
            secondsPassed
        );
    }

    /// @dev Computes the current price of an auction. Factored out
    ///  from _currentPrice so we can run extensive unit tests.
    ///  When testing, make this function public and turn on
    ///  `Current price computation` test suite.
    function _computeCurrentPrice(
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration,
        uint256 _secondsPassed
    )
        internal
        pure
        returns (uint256)
    {
        // NOTE: We don't use SafeMath (or similar) in this function because
        //  all of our public functions carefully cap the maximum values for
        //  time (at 64-bits) and currency (at 128-bits). _duration is
        //  also known to be non-zero (see the require() statement in _addAuction())
        //  ** Maybe something to take a look at in the future 
        if (_secondsPassed >= _duration) {
            // We've reached the end of the dynamic pricing portion
            // of the auction, just return the end price that is fixed as a floor.
            return _endingPrice;
        } else {
            // Starting price can be higher than ending price (and often is!), so
            // this delta can be negative.
            int256 totalPriceChange = int256(_endingPrice) - int256(_startingPrice);

            // This multiplication can't overflow, _secondsPassed will easily fit within
            // 64-bits, and totalPriceChange will easily fit within 128-bits, their product
            // will always fit within 256-bits.
            int256 currentPriceChange = totalPriceChange * int256(_secondsPassed) / int256(_duration);

            // currentPriceChange can be negative, but if so, will have a magnitude
            // less that _startingPrice. Thus, this result will always end up positive.
            int256 currentPrice = int256(_startingPrice) + currentPriceChange;

            return uint256(currentPrice);
        }
    }

    /// @dev Computes owner's cut of a sale.
    /// @param _price - Sale price of NFT.
    function _computeCut(uint256 _price) internal view returns (uint256) {
        // NOTE: We don't use SafeMath (or similar) in this function because
        //  all of our entry functions carefully cap the maximum values for
        //  currency (at 128-bits), and ownerCut <= 10000 (see the require()
        //  statement in the ClockAuction constructor). The result of this
        //  function is always guaranteed to be <= _price.
        return _price * ownerCut / 10000;
    }

}
 // @title Pausable
 // @dev Base contract which allows children to implement an emergency stop mechanism.
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;

  // @dev modifier to allow actions only when the contract IS paused
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  // @dev modifier to allow actions only when the contract IS NOT paused
  modifier whenPaused {
    require(paused);
    _;
  }

  // @dev called by the owner to pause, triggers stopped state
  function pause() onlyOwner public whenNotPaused returns (bool) {
    paused = true;
    Pause();
    return true;
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner public whenPaused returns (bool) {
    paused = false;
    Unpause();
    return true;
  }
}

/// @title Clock auction for non-fungible tokens.
/// @notice We omit a fallback function to prevent accidental sends to this contract.
contract ClockAuction is Pausable, ClockAuctionBase {

    /// @dev The ERC-165 interface signature for ERC-721.
    ///  Ref: https://github.com/ethereum/EIPs/issues/165
    ///  Ref: https://github.com/ethereum/EIPs/issues/721
    bytes4 constant InterfaceSignature_ERC721 = bytes4(0x9a20483d);

    /// @dev Constructor creates a reference to the NFT ownership contract
    ///  and verifies the owner cut is in the valid range.
    /// @param _nftAddress - address of a deployed contract implementing
    ///  the Nonfungible Interface.
    /// @param _cut - percent cut the owner takes on each auction, must be
    ///  between 0-10,000.
    function ClockAuction(address _nftAddress, uint256 _cut) public {
        require(_cut <= 10000);
        ownerCut = _cut;
        ERC721 candidateContract = ERC721(_nftAddress);
        require(candidateContract.supportsInterface(InterfaceSignature_ERC721));
        nonFungibleContract = candidateContract;
    }

    /// @dev Remove all Ether from the contract, which is the owner's cut
    ///  as well as any Ether sent directly to the contract address.
    ///  Always transfers to the NFT contract, but can be called either by
    ///  the owner or the NFT contract.
    function withdrawBalance() external {
        address nftAddress = address(nonFungibleContract);

        require(
            msg.sender == owner ||
            msg.sender == nftAddress
        );
        // We are using this boolean method to make sure that even if one fails it will still work
        bool res = nftAddress.send(this.balance);
    }

    /// @dev Creates and begins a new auction.
    /// @param _tokenId - ID of token to auction, sender must be owner.
    /// @param _startingPrice - Price of item (in wei) at beginning of auction.
    /// @param _endingPrice - Price of item (in wei) at end of auction.
    /// @param _duration - Length of time to move between starting
    ///  price and ending price (in seconds).
    /// @param _seller - Seller, if not the message sender
    function createAuction(
        uint256 _tokenId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration,
        address _seller
    )
        external
        whenNotPaused
    {
        // Sanity check that no inputs overflow how many bits we've allocated
        // to store them in the auction struct.
        require(_startingPrice == uint256(uint128(_startingPrice)));
        require(_endingPrice == uint256(uint128(_endingPrice)));
        require(_duration == uint256(uint64(_duration)));

        require(_owns(msg.sender, _tokenId));
        _escrow(msg.sender, _tokenId);
        Auction memory auction = Auction(
            _seller,
            uint128(_startingPrice),
            uint128(_endingPrice),
            uint64(_duration),
            uint64(now)
        );
        _addAuction(_tokenId, auction);
    }

    /// @dev Bids on an open auction, completing the auction and transferring
    ///  ownership of the NFT if enough Ether is supplied.
    /// @param _tokenId - ID of token to bid on.
    function bid(uint256 _tokenId)
        external
        payable
        whenNotPaused
    {
        // _bid will throw if the bid or funds transfer fails
        _bid(_tokenId, msg.value);
        _transfer(msg.sender, _tokenId);
    }

    /// @dev Cancels an auction that hasn't been won yet.
    ///  Returns the NFT to original owner.
    /// @notice This is a state-modifying function that can
    ///  be called while the contract is paused.
    /// @param _tokenId - ID of token on auction
    function cancelAuction(uint256 _tokenId)
        external
    {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction));
        address seller = auction.seller;
        require(msg.sender == seller);
        _cancelAuction(_tokenId, seller);
    }

    /// @dev Cancels an auction when the contract is paused.
    ///  Only the owner may do this, and NFTs are returned to
    ///  the seller. This should only be used in emergencies.
    /// @param _tokenId - ID of the NFT on auction to cancel.
    function cancelAuctionWhenPaused(uint256 _tokenId)
        whenPaused
        onlyOwner
        external
    {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction));
        _cancelAuction(_tokenId, auction.seller);
    }

    /// @dev Returns auction info for an NFT on auction.
    /// @param _tokenId - ID of NFT on auction.
    function getAuction(uint256 _tokenId)
        external
        view
        returns
    (
        address seller,
        uint256 startingPrice,
        uint256 endingPrice,
        uint256 duration,
        uint256 startedAt
    ) {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction));
        return (
            auction.seller,
            auction.startingPrice,
            auction.endingPrice,
            auction.duration,
            auction.startedAt
        );
    }

    /// @dev Returns the current price of an auction.
    /// @param _tokenId - ID of the token price we are checking.
    function getCurrentPrice(uint256 _tokenId)
        external
        view
        returns (uint256)
    {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction));
        return _currentPrice(auction);
    }
}

/// @title Reverse auction modified for blueprinting
/// @notice We omit a fallback function to prevent accidental sends to this contract.
contract blueprintingClockAuction is ClockAuction {

    // @dev Sanity check that allows us to ensure that we are pointing to the
    //  right auction in our setblueprintingAuctionAddress() call.
    bool public isblueprintingClockAuction = true;

    // Delegate constructor
    function blueprintingClockAuction(address _nftAddr, uint256 _cut) public
        ClockAuction(_nftAddr, _cut) {}

    /// @dev Creates and begins a new auction. Since this function is wrapped,
    /// require sender to be BuildingCore contract.
    /// @param _tokenId - ID of token to auction, sender must be owner.
    /// @param _startingPrice - Price of item (in wei) at beginning of auction.
    /// @param _endingPrice - Price of item (in wei) at end of auction.
    /// @param _duration - Length of auction (in seconds).
    /// @param _seller - Seller, if not the message sender
    function createAuction(
        uint256 _tokenId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration,
        address _seller
    )
        external
    {
        // Sanity check that no inputs overflow how many bits we've allocated
        // to store them in the auction struct.
        require(_startingPrice == uint256(uint128(_startingPrice)));
        require(_endingPrice == uint256(uint128(_endingPrice)));
        require(_duration == uint256(uint64(_duration)));

        require(msg.sender == address(nonFungibleContract));
        _escrow(_seller, _tokenId);
        Auction memory auction = Auction(
            _seller,
            uint128(_startingPrice),
            uint128(_endingPrice),
            uint64(_duration),
            uint64(now)
        );
        _addAuction(_tokenId, auction);
    }

    /// @dev Places a bid for blueprinting. Requires the sender
    /// use the BuildingCore contract because all bid methods
    /// should be wrapped. Also returns the Building to the seller rather than the winner.
    function bid(uint256 _tokenId)
        external
        payable
    {
        require(msg.sender == address(nonFungibleContract));
        address seller = tokenIdToAuction[_tokenId].seller;
        // _bid checks that token ID is valid and will throw if bid fails
        _bid(_tokenId, msg.value);
        // We transfer the Building back to the seller, the winner will get
        // the offspring
        _transfer(seller, _tokenId);
    }

}

/// @title Clock auction modified for sale of buildings. 
/// @notice We omit a fallback function to prevent accidental sends to this contract.
contract SaleClockAuction is ClockAuction {
    // @dev Sanity check that allows us to ensure that we are pointing to the
    //  right auction in our setSaleAuctionAddress() call.
    bool public isSaleClockAuction = true;

    // Tracks last 5 sale price of era0 Building sales
    uint256 public era0SaleCount;
    uint256[5] public lastEra0SalePrices;

    // Delegate constructor
    function SaleClockAuction(address _nftAddr, uint256 _cut) public
        ClockAuction(_nftAddr, _cut) {}

    /// @dev Creates and begins a new auction.
    /// @param _tokenId - ID of token to auction, sender must be owner.
    /// @param _startingPrice - Price of item (in wei) at beginning of auction.
    /// @param _endingPrice - Price of item (in wei) at end of auction.
    /// @param _duration - Length of auction (in seconds).
    /// @param _seller - Seller, if not the message sender
    function createAuction(
        uint256 _tokenId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration,
        address _seller
    )
        external
    {
        // Sanity check that no inputs overflow how many bits we've allocated
        // to store them in the auction struct.
        require(_startingPrice == uint256(uint128(_startingPrice)));
        require(_endingPrice == uint256(uint128(_endingPrice)));
        require(_duration == uint256(uint64(_duration)));

        require(msg.sender == address(nonFungibleContract));
        _escrow(_seller, _tokenId);
        Auction memory auction = Auction(
            _seller,
            uint128(_startingPrice),
            uint128(_endingPrice),
            uint64(_duration),
            uint64(now)
        );
        _addAuction(_tokenId, auction);
    }

    /// @dev Updates lastSalePrice if seller is the nft contract
    /// Otherwise, works the same as default bid method.
    function bid(uint256 _tokenId)
        external
        payable
    {
        // _bid verifies token ID size
        address seller = tokenIdToAuction[_tokenId].seller;
        uint256 price = _bid(_tokenId, msg.value);
        _transfer(msg.sender, _tokenId);

        // If not a era0 auction, exit
        if (seller == address(nonFungibleContract)) {
            // Track era0 sale prices
            lastEra0SalePrices[era0SaleCount % 5] = price;
            era0SaleCount++;
        }
    }

    function averageEra0SalePrice() external view returns (uint256) {
        uint256 sum = 0;
        for (uint256 i = 0; i < 5; i++) {
            sum += lastEra0SalePrices[i];
        }
        return sum / 5;
    }
}
/// @title Handles creating auctions for sale and blueprinting of buildings.
///  This wrapper of ReverseAuction exists only so that users can create
///  auctions with only one transaction.
contract BuildingAuction is BuildingBlueprinting {

    // @notice The auction contract variables are defined in BuildingBase to allow
    //  us to refer to them in BuildingOwnership to prevent accidental transfers.
    // `saleAuction` refers to the auction for era0 and p2p sale of buildings.
    // `blueprintingAuction` refers to the auction for blueprinting rights of buildings.

    /// @dev Sets the reference to the sale auction.
    /// @param _address - Address of sale contract.
    function setSaleAuctionAddress(address _address) external onlyCEO {
        SaleClockAuction candidateContract = SaleClockAuction(_address);

        // NOTE: verify that a contract is what we expect - https://github.com/Lunyr/crowdsale-contracts/blob/cfadd15986c30521d8ba7d5b6f57b4fefcc7ac38/contracts/LunyrToken.sol#L117
        require(candidateContract.isSaleClockAuction());

        // Set the new contract address
        saleAuction = candidateContract;
    }

    /// @dev Sets the reference to the blueprinting auction.
    /// @param _address - Address of blueprinting contract.
    function setblueprintingAuctionAddress(address _address) external onlyCEO {
        blueprintingClockAuction candidateContract = blueprintingClockAuction(_address);

        // NOTE: verify that a contract is what we expect - https://github.com/Lunyr/crowdsale-contracts/blob/cfadd15986c30521d8ba7d5b6f57b4fefcc7ac38/contracts/LunyrToken.sol#L117
        require(candidateContract.isblueprintingClockAuction());

        // Set the new contract address
        blueprintingAuction = candidateContract;
    }

    /// @dev Put a Building up for auction.
    ///  Does some ownership trickery to create auctions in one tx. ***** Check this again for safety
    function createSaleAuction(
        uint256 _buildingId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration
    )
        external
        whenNotPaused
    {
        // Auction contract checks input sizes
        // If Building is already on any auction, this will throw
        // because it will be owned by the auction contract.
        require(_owns(msg.sender, _buildingId));
        // Ensure the Building is not Constructing to prevent the auction
        // contract accidentally receiving ownership of the child.
        // NOTE: the Building IS allowed to be in a cooldown.
        require(!isConstructing(_buildingId));
        _approve(_buildingId, saleAuction);
        // Sale auction throws if inputs are invalid and clears
        // transfer and constructingapproval after escrowing the Building.
        saleAuction.createAuction(
            _buildingId,
            _startingPrice,
            _endingPrice,
            _duration,
            msg.sender
        );
    }

    /// @dev Put a Building up for auction to blueprint. Performs checks to ensure the Building can be blueprinted, then
    ///  delegates to reverse auction.
    function createBlueprintingAuction(
        uint256 _buildingId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration
    )
        external
        whenNotPaused
    {
        // Auction contract checks input sizes
        // If Building is already on any auction, this will throw because it will be owned by the auction contract.
        require(_owns(msg.sender, _buildingId));
        require(isReadyToConstruct(_buildingId));
        _approve(_buildingId, blueprintingAuction);
        // blueprinting auction throws if inputs are invalid and clears
        // transfer and constructingapproval after escrowing the Building.
        blueprintingAuction.createAuction(
            _buildingId,
            _startingPrice,
            _endingPrice,
            _duration,
            msg.sender
        );
    }

    /// @dev Completes a blueprinting auction by bidding.
    ///  Immediately breeds the winning constructing with the building2 on auction.
    /// @param _blueprintId - ID of the building2 on auction.
    /// @param _constructingId - ID of the constructing owned by the bidder.
    function bidOnBlueprintingAuction(
        uint256 _blueprintId,
        uint256 _constructingId
    )
        external
        payable
        whenNotPaused
    {
        // Auction contract checks input sizes
        require(_owns(msg.sender, _constructingId));
        require(isReadyToConstruct(_constructingId));
        require(_canconstructWithViaAuction(_constructingId, _blueprintId));

        // Define the current price of the auction.
        uint256 currentPrice = blueprintingAuction.getCurrentPrice(_blueprintId);
        require(msg.value >= currentPrice + autoBirthFee);

        // blueprinting auction will throw if the bid fails.
        blueprintingAuction.bid.value(msg.value - autoBirthFee)(_blueprintId);
        _constructWith(uint32(_constructingId), uint32(_blueprintId));
    }

    /// @dev Transfers the balance of the sale auction contract
    /// to the BuildingCore contract. We use two-step withdrawal to
    /// prevent two transfer calls in the auction bid function.
    function withdrawAuctionBalances() external onlyCLevel {
        saleAuction.withdrawBalance();
        blueprintingAuction.withdrawBalance();
    }
}


/// @title all functions related to creating buildings
contract BuildingMinting is BuildingAuction {

    // Limits the number of buildings the contract owner can ever create.
    uint256 public constant PROMO_CREATION_LIMIT = 5000;
    uint256 public constant ERA0_CREATION_LIMIT = 45000;

    // Constants for era0 auctions. *** NOTE SEEMS ARBITRARY *** 
    uint256 public constant ERA0_STARTING_PRICE = 10 finney;
    uint256 public constant ERA0_AUCTION_DURATION = 1 days;

    // Counts the number of buildings the contract owner has created.
    uint256 public promoCreatedCount;
    uint256 public era0CreatedCount;

    /// @dev we can create promo buildings, up to a limit. Only callable by COO
    /// @param _DNA the encoded DNA of the Building to be created, any value is accepted
    /// @param _owner the future owner of the created buildings. Default to contract COO
    function createPromoBuilding(uint256 _DNA, address _owner) external onlyCOO {
        address buildingOwner = _owner;
        if (buildingOwner == address(0)) {
             buildingOwner = cooAddress;
        }
        require(promoCreatedCount < PROMO_CREATION_LIMIT);

        promoCreatedCount++;
        _createBuilding(0, 0, 0, _DNA, buildingOwner);
    }

    /// @dev Creates a new era0 Building with the given DNA and
    ///  creates an auction for it.
    function createEra0Auction(uint256 _DNA) external onlyCOO {
        require(era0CreatedCount < ERA0_CREATION_LIMIT);

        uint256 buildingId = _createBuilding(0, 0, 0, _DNA, address(this));
        _approve(buildingId, saleAuction);

        saleAuction.createAuction(
            buildingId,
            _computeNextEra0Price(),
            0,
            ERA0_AUCTION_DURATION,
            address(this)
        );
        era0CreatedCount++;
    }

    /// @dev Computes the next era0 auction starting price, given
    ///  the average of the past 5 prices + 50%.
    function _computeNextEra0Price() internal view returns (uint256) {
        uint256 avePrice = saleAuction.averageEra0SalePrice();

        // Sanity check to ensure we don't overflow arithmetic
        require(avePrice == uint256(uint128(avePrice)));
        uint256 nextPrice = avePrice + (avePrice / 2);

        // We never auction for less than starting price
        if (nextPrice < ERA0_STARTING_PRICE) {
            nextPrice = ERA0_STARTING_PRICE;
        }
        return nextPrice;
    }
}

/// @title Forked from CryptoKitties
/// @author Axiom Zen (https://www.axiomzen.co)
/// @dev The main contract, keeps track of buildings so they don't wander around and get lost.
contract BuildingCore is BuildingMinting {

    // This is the main contract. In order to keep our code seperated into logical sections,
    // we've broken it up in two ways. First, we have several seperately-instantiated sibling contracts
    // that handle auctions and our super-top-secret genetic combination algorithm. The auctions are
    // seperate since their logic is somewhat complex and there's always a risk of subtle bugs. By keeping
    // them in their own contracts, we can upgrade them without disrupting the main contract that tracks
    // Building ownership. The genetic combination algorithm is kept seperate so we can open-source all of
    // the rest of our code without making it _too_ easy for folks to figure out how the genetics work.
    // Don't worry, I'm sure someone will reverse engineer it soon enough!
    //
    // Secondly, we break the core contract into multiple files using inheritence, one for each major
    // facet of functionality . This allows us to keep related code bundled together while still
    // avoiding a single giant file with everything in it. The breakdown is as follows:
    //
    //      - BUildingBase: This is where we define the most fundamental code shared throughout the core
    //             functionality. This includes our main data storage, constants and data types, plus
    //             internal functions for managing these items.
    //
    //      - BuildingAccessControl: This contract manages the various addresses and constraints for operations
    //             that can be executed only by specific roles. Namely CEO, CFO and COO.
    //
    //      - buildingOwnership: This provides the methods required for basic non-fungible token
    //             transactions, following the draft ERC-721 spec (https://github.com/ethereum/EIPs/issues/721).
    //
    //      - Buildingblueprinting: This file contains the methods necessary to breed buildings together, including
    //             keeping track of blueprinting offers, and relies on an external genetic combination contract.
    //
    //      - BuildingAuctions: Here we have the public methods for auctioning or bidding on buildings or blueprinting
    //             services. The actual auction functionality is handled in two sibling contracts (one
    //             for sales and one for blueprinting), while auction creation and bidding is mostly mediated
    //             through this facet of the core contract.
    //
    //      - BuildingMinting: This final facet contains the functionality we use for creating new era0 buildings.
    //             We can make up to 5000 "promo" buildings that can be given away (especially important when
    //             the community is new), and all others can only be created and then immediately put up
    //             for auction via an algorithmically determined starting price. Regardless of how they
    //             are created, there is a hard limit of 50k era0 buildings. If we make that many designs even. **
    //  After that, it's all up to the
    //             community to breed, breed, breed!

    // Set in case the core contract is broken and an upgrade is required
    address public newContractAddress;

    /// @notice Creates the main smart contract instance.
    function BuildingCore() public {
        // Starts paused.
        paused = true;
        // the creator of the contract is the initial CEO
        ceoAddress = msg.sender;
        // the creator of the contract is also the initial COO
        cooAddress = msg.sender;
        // start with the mythical Building 0 - so we don't have era-0 parent issues
        _createBuilding(0, 0, 0, uint256(-1), address(0));
    }

    /// @dev Used to mark the smart contract as upgraded, in case there is a serious
    ///  breaking bug. This method does nothing but keep track of the new contract and
    ///  emit a message indicating that the new address is set. It's up to clients of this
    ///  contract to update to the new contract address in that case. (This contract will
    ///  be paused indefinitely if such an upgrade takes place.)
    /// @param _v2Address new address
    function setNewAddress(address _v2Address) external onlyCEO whenPaused {
        newContractAddress = _v2Address;
        ContractUpgrade(_v2Address);
    }
    /// @notice No tipping! ****
    /// @dev Reject all Ether from being sent here, unless it's from one of the
    ///  two auction contracts. (Hopefully, we can prevent user accidents.)
    function() external payable {
        require(
            msg.sender == address(saleAuction) ||
            msg.sender == address(blueprintingAuction)
        );
    }

    /// @notice Returns all the relevant information about a specific Building.
    /// @param _id The ID of the Building of interest.
    function getBuilding(uint256 _id)
        external
        view
        returns (
        bool isConstructing,
        bool isReady,
        uint256 cooldownIndex,
        uint256 nextActionAt,
        uint256 blueprintingWithId,
        uint256 constructTime,
        uint256 constructingId,
        uint256 blueprintId,
        uint256 era,
        uint256 DNA
    ) {
        Building storage built = buildings[_id];

        // if this variable is 0 then it's not gestating
        isConstructing = (built.blueprintingWithId != 0);
        isReady = (built.cooldownEndBlock <= block.number);
        cooldownIndex = uint256(built.cooldownIndex);
        nextActionAt = uint256(built.cooldownEndBlock);
        blueprintingWithId = uint256(built.blueprintingWithId);
        constructTime = uint256(built.constructTime);
        constructingId = uint256(built.constructingId);
        blueprintId = uint256(built.blueprintId);
        era = uint256(built.era);
        DNA = built.DNA;
    }

    /// @dev Override unpause so it requires all external contract addresses
    ///  to be set before contract can be unpaused. Also, we can't have
    ///  newContractAddress set either, because then the contract was upgraded.
    /// @notice This is public rather than external so we can call super.unpause
    ///  without using an expensive CALL.
    function unpause() public onlyCEO whenPaused {
        require(saleAuction != address(0));
        require(blueprintingAuction != address(0));
        require(BlueprintInfo != address(0));
        require(newContractAddress == address(0));

        // Actually unpause the contract.
        super.unpause();
    }

    // @dev Allows the CFO to capture the balance available to the contract.
    function withdrawBalance() external onlyCFO {
        uint256 balance = this.balance;
        // Subtract all the currently Constructing buildings we have, plus 1 of margin.
        uint256 subtractFees = (ConstructingBuildings + 1) * autoBirthFee;

        if (balance > subtractFees) {
            cfoAddress.transfer(balance - subtractFees);
        }
    }
}
