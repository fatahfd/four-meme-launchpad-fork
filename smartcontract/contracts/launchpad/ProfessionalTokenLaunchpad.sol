// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./tokens/ProfessionalMemeToken.sol";
import "./interfaces/IPancakeRouter.sol";
import "./interfaces/IPancakeFactory.sol";
import "./interfaces/IPancakePair.sol";
import "./security/AccessControl.sol";
import "./utils/SafeMath.sol";

/**
 * @title ProfessionalTokenLaunchpad
 * @dev Enhanced token launchpad with professional features and security
 * @notice This contract provides a secure, feature-rich token launch platform
 */
contract ProfessionalTokenLaunchpad is Ownable, ReentrancyGuard, Pausable, AccessControl {
    using Address for address payable;
    using Counters for Counters.Counter;
    using SafeMath for uint256;

    // Token creation fee (in BNB)
    uint256 public tokenCreationFee = 0.005 ether; // 0.005 BNB
    
    // PancakeSwap integration
    IPancakeRouter public pancakeRouter;
    IPancakeFactory public pancakeFactory;
    address public WBNB;
    
    // Platform configuration
    address public platformFeeRecipient;
    address public liquidityFeeRecipient;
    uint256 public platformFeePercentage = 100; // 1% (100/10000)
    uint256 public liquidityFeePercentage = 100; // 1% (100/10000)
    
    // Liquidity configuration
    uint256 public constant LIQUIDITY_PERCENTAGE = 80; // 80% of tokens go to liquidity
    uint256 public constant LIQUIDITY_DENOMINATOR = 100;
    uint256 public minimumLiquidityBNB = 0.1 ether; // 0.1 BNB minimum
    uint256 public maximumLiquidityBNB = 10 ether; // 10 BNB maximum
    
    // Token registry
    struct TokenInfo {
        address tokenAddress;
        address creator;
        string name;
        string symbol;
        uint256 totalSupply;
        uint256 creationTime;
        bool active;
        address pairAddress;
        uint256 liquidityAmount;
        bool tradingEnabled;
        uint256 marketCap;
        uint256 volume24h;
        uint256 holders;
        string category;
        bool verified;
        uint256 launchPrice;
    }
    
    mapping(address => TokenInfo) public tokens;
    mapping(address => address[]) public creatorTokens;
    mapping(string => address[]) public categoryTokens;
    address[] public allTokens;
    Counters.Counter private _tokenIdCounter;
    
    // LP token tracking
    mapping(address => uint256) public tokenLPBalance;
    mapping(address => uint256) public tokenLockTime;
    
    // Statistics
    uint256 public totalTokensCreated;
    uint256 public totalCreationFeesCollected;
    uint256 public totalLiquidityProvided;
    uint256 public totalVolumeTraded;
    
    // Launchpad settings
    bool public launchpadActive = true;
    uint256 public maxTokensPerCreator = 10;
    mapping(address => uint256) public creatorTokenCount;
    
    // Events
    event TokenCreated(
        address indexed tokenAddress,
        address indexed creator,
        string name,
        string symbol,
        uint256 totalSupply,
        uint256 creationFee,
        address indexed pairAddress,
        uint256 liquidityAmount,
        string category
    );
    
    event LiquidityAdded(
        address indexed tokenAddress,
        address indexed pairAddress,
        uint256 tokenAmount,
        uint256 bnbAmount,
        uint256 liquidity
    );
    
    event TradingEnabled(address indexed tokenAddress, address indexed pairAddress);
    event TokenVerified(address indexed tokenAddress, bool verified);
    event TokenCategoryUpdated(address indexed tokenAddress, string oldCategory, string newCategory);
    
    event CreationFeeUpdated(uint256 oldFee, uint256 newFee);
    event PlatformFeeRecipientUpdated(address indexed oldRecipient, address indexed newRecipient);
    event LiquidityFeeRecipientUpdated(address indexed oldRecipient, address indexed newRecipient);
    event TokenDeactivated(address indexed tokenAddress);
    event MinimumLiquidityUpdated(uint256 oldMinimum, uint256 newMinimum);
    event MaximumLiquidityUpdated(uint256 oldMaximum, uint256 newMaximum);
    event LaunchpadToggled(bool active);
    event MaxTokensPerCreatorUpdated(uint256 oldMax, uint256 newMax);
    
    constructor(
        address _platformFeeRecipient,
        address _liquidityFeeRecipient,
        address _pancakeRouter,
        address _pancakeFactory
    ) Ownable(msg.sender) {
        require(_platformFeeRecipient != address(0), "Invalid platform fee recipient");
        require(_liquidityFeeRecipient != address(0), "Invalid liquidity fee recipient");
        require(_pancakeRouter != address(0), "Invalid router address");
        require(_pancakeFactory != address(0), "Invalid factory address");
        
        platformFeeRecipient = _platformFeeRecipient;
        liquidityFeeRecipient = _liquidityFeeRecipient;
        pancakeRouter = IPancakeRouter(_pancakeRouter);
        pancakeFactory = IPancakeFactory(_pancakeFactory);
        WBNB = pancakeRouter.WETH();
        
        // Initialize access control
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MODERATOR_ROLE, msg.sender);
    }
    
    /**
     * @dev Create a new professional meme token with automatic PancakeSwap integration
     * @param name Token name
     * @param symbol Token symbol
     * @param totalSupply Total supply of tokens
     * @param tokenImage Token image URL
     * @param tokenDescription Token description
     * @param tokenWebsite Token website URL
     * @param tokenTwitter Token Twitter handle
     * @param tokenTelegram Token Telegram group
     * @param tokenTag Token category tag
     * @param tokenStartTime Token trading start time
     * @param liquidityBNB Amount of BNB to add as liquidity
     * @param category Token category
     */
    function createTokenWithLiquidity(
        string memory name,
        string memory symbol,
        uint256 totalSupply,
        string memory tokenImage,
        string memory tokenDescription,
        string memory tokenWebsite,
        string memory tokenTwitter,
        string memory tokenTelegram,
        string memory tokenTag,
        uint256 tokenStartTime,
        uint256 liquidityBNB,
        string memory category
    ) external payable nonReentrant whenNotPaused returns (address) {
        /* Contact Me */
    }
    
    /**
     * @dev Enable trading for a token
     * @param tokenAddress Token to enable trading for
     */
    function enableTrading(address tokenAddress) external {
        /* Contact Me */
    }
    
    /**
     * @dev Verify a token (moderator only)
     * @param tokenAddress Token to verify
     * @param verified Whether to verify
     */
    function verifyToken(address tokenAddress, bool verified) external onlyRole(MODERATOR_ROLE) {
        require(tokens[tokenAddress].active, "Token not active");
        tokens[tokenAddress].verified = verified;
        emit TokenVerified(tokenAddress, verified);
    }
    
    /**
     * @dev Update token category
     * @param tokenAddress Token address
     * @param newCategory New category
     */
    function updateTokenCategory(address tokenAddress, string memory newCategory) external {
        TokenInfo storage tokenInfo = tokens[tokenAddress];
        require(tokenInfo.active, "Token not active");
        require(msg.sender == tokenInfo.creator || hasRole(MODERATOR_ROLE, msg.sender), "Not authorized");
        require(bytes(newCategory).length > 0, "Invalid category");
        
        string memory oldCategory = tokenInfo.category;
        tokenInfo.category = newCategory;
        
        // Remove from old category and add to new category
        _removeFromCategory(oldCategory, tokenAddress);
        categoryTokens[newCategory].push(tokenAddress);
        
        emit TokenCategoryUpdated(tokenAddress, oldCategory, newCategory);
    }
    
    /**
     * @dev Get token information with DEX data
     * @param tokenAddress Token contract address
     * @return TokenInfo struct with DEX integration data
     */
    function getTokenInfoWithDEX(address tokenAddress) external view returns (TokenInfo memory) {
        return tokens[tokenAddress];
    }
    
    /**
     * @dev Get pair information for a token
     * @param tokenAddress Token address
     * @return pairAddress PancakeSwap pair address
     * @return reserve0 Token reserve
     * @return reserve1 BNB reserve
     * @return totalSupply Total LP token supply
     */
    function getPairInfo(address tokenAddress) external view returns (
        address pairAddress,
        uint112 reserve0,
        uint112 reserve1,
        uint256 totalSupply
    ) {
        TokenInfo memory tokenInfo = tokens[tokenAddress];
        pairAddress = tokenInfo.pairAddress;
        
        if (pairAddress != address(0)) {
            IPancakePair pair = IPancakePair(pairAddress);
            (reserve0, reserve1,) = pair.getReserves();
            totalSupply = pair.totalSupply();
        }
    }
    
    /**
     * @dev Get tokens by category
     * @param category Category to filter by
     * @return tokenAddresses Array of token addresses in category
     */
    function getTokensByCategory(string memory category) external view returns (address[] memory) {
        return categoryTokens[category];
    }
    
    /**
     * @dev Get platform statistics
     * @return totalTokens Total tokens created
     * @return totalFees Total fees collected
     * @return platformBalance Platform BNB balance
     * @return totalLiquidity Total liquidity provided
     * @return totalVolume Total volume traded
     */
    function getPlatformStats() external view returns (
        uint256 totalTokens,
        uint256 totalFees,
        uint256 platformBalance,
        uint256 totalLiquidity,
        uint256 totalVolume
    ) {
        return (
            totalTokensCreated,
            totalCreationFeesCollected,
            address(this).balance,
            totalLiquidityProvided,
            totalVolumeTraded
        );
    }
    
    // Admin functions
    function updateCreationFee(uint256 newFee) external onlyOwner {
        uint256 oldFee = tokenCreationFee;
        tokenCreationFee = newFee;
        emit CreationFeeUpdated(oldFee, newFee);
    }
    
    function updatePlatformFeeRecipient(address newRecipient) external onlyOwner {
        require(newRecipient != address(0), "Invalid recipient address");
        address oldRecipient = platformFeeRecipient;
        platformFeeRecipient = newRecipient;
        emit PlatformFeeRecipientUpdated(oldRecipient, newRecipient);
    }
    
    function updateLiquidityFeeRecipient(address newRecipient) external onlyOwner {
        require(newRecipient != address(0), "Invalid recipient address");
        address oldRecipient = liquidityFeeRecipient;
        liquidityFeeRecipient = newRecipient;
        emit LiquidityFeeRecipientUpdated(oldRecipient, newRecipient);
    }
    
    function updateMinimumLiquidity(uint256 newMinimum) external onlyOwner {
        uint256 oldMinimum = minimumLiquidityBNB;
        minimumLiquidityBNB = newMinimum;
        emit MinimumLiquidityUpdated(oldMinimum, newMinimum);
    }
    
    function updateMaximumLiquidity(uint256 newMaximum) external onlyOwner {
        uint256 oldMaximum = maximumLiquidityBNB;
        maximumLiquidityBNB = newMaximum;
        emit MaximumLiquidityUpdated(oldMaximum, newMaximum);
    }
    
    function toggleLaunchpad() external onlyOwner {
        launchpadActive = !launchpadActive;
        emit LaunchpadToggled(launchpadActive);
    }
    
    function updateMaxTokensPerCreator(uint256 newMax) external onlyOwner {
        uint256 oldMax = maxTokensPerCreator;
        maxTokensPerCreator = newMax;
        emit MaxTokensPerCreatorUpdated(oldMax, newMax);
    }
    
    function deactivateToken(address tokenAddress) external onlyRole(MODERATOR_ROLE) {
        require(tokens[tokenAddress].active, "Token not active");
        tokens[tokenAddress].active = false;
        emit TokenDeactivated(tokenAddress);
    }
    
    function pause() external onlyOwner {
        _pause();
    }
    
    function unpause() external onlyOwner {
        _unpause();
    }
    
    // Internal functions
    function _removeFromCategory(string memory category, address tokenAddress) internal {
        address[] storage categoryList = categoryTokens[category];
        for (uint i = 0; i < categoryList.length; i++) {
            if (categoryList[i] == tokenAddress) {
                categoryList[i] = categoryList[categoryList.length - 1];
                categoryList.pop();
                break;
            }
        }
    }
    
    // Receive function to accept BNB
    receive() external payable {}
}
