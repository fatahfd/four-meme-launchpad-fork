// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./interfaces/IPancakeRouter.sol";
import "./interfaces/IPancakeFactory.sol";
import "./interfaces/IPancakePair.sol";

/**
 * @title ProfessionalMemeToken
 * @dev Enhanced meme token with professional features and security
 * @notice This contract provides a secure, feature-rich token implementation
 */
contract ProfessionalMemeToken is ERC20, ERC20Burnable, ERC20Pausable, Ownable, ReentrancyGuard {
    using Address for address payable;

    // Token metadata
    string public tokenImage;
    string public tokenDescription;
    string public tokenWebsite;
    string public tokenTwitter;
    string public tokenTelegram;
    string public tokenTag;
    uint256 public tokenStartTime;
    
    // Trading and liquidity
    address public pancakePair;
    address public pancakeRouter;
    address public pancakeFactory;
    address public WBNB;
    
    // Fee configuration
    uint256 public constant MAX_FEE = 1000; // 10% maximum fee
    uint256 public tradingFee = 200; // 2% trading fee (200/10000)
    uint256 public liquidityFee = 100; // 1% liquidity fee (100/10000)
    uint256 public platformFee = 100; // 1% platform fee (100/10000)
    
    // Fee recipients
    address public liquidityFeeRecipient;
    address public platformFeeRecipient;
    
    // Trading controls
    bool public tradingEnabled = false;
    bool public antiBotEnabled = true;
    uint256 public maxTransactionAmount;
    uint256 public maxWalletAmount;
    
    // Anti-bot and MEV protection
    mapping(address => bool) public isExcludedFromFee;
    mapping(address => bool) public isExcludedFromMaxTransaction;
    mapping(address => bool) public isExcludedFromMaxWallet;
    mapping(address => bool) public blacklisted;
    
    // Liquidity management
    bool public swapEnabled = true;
    uint256 public swapThreshold = 1000 * 10**18; // Minimum tokens to swap
    
    // Events
    event TradingEnabled();
    event TradingDisabled();
    event FeesUpdated(uint256 tradingFee, uint256 liquidityFee, uint256 platformFee);
    event FeeRecipientsUpdated(address liquidityRecipient, address platformRecipient);
    event ExcludedFromFee(address account, bool excluded);
    event ExcludedFromMaxTransaction(address account, bool excluded);
    event ExcludedFromMaxWallet(address account, bool excluded);
    event Blacklisted(address account, bool blacklisted);
    event SwapThresholdUpdated(uint256 oldThreshold, uint256 newThreshold);
    event SwapEnabled(bool enabled);
    event AntiBotToggled(bool enabled);
    
    constructor(
        string memory name,
        string memory symbol,
        uint256 totalSupply,
        address initialOwner,
        address _platformFeeRecipient,
        string memory _tokenImage,
        string memory _tokenDescription,
        string memory _tokenWebsite,
        string memory _tokenTwitter,
        string memory _tokenTelegram,
        string memory _tokenTag,
        uint256 _tokenStartTime,
        address _liquidityFeeRecipient,
        uint256 liquidityAmount
    ) ERC20(name, symbol) Ownable(initialOwner) {
        /* Contact Me */
    }
    
    /**
     * @dev Set PancakeSwap addresses
     * @param _pancakeRouter PancakeSwap router address
     * @param _pancakeFactory PancakeSwap factory address
     * @param _pancakePair PancakeSwap pair address
     */
    function setPancakeAddresses(
        address _pancakeRouter,
        address _pancakeFactory,
        address _pancakePair
    ) external onlyOwner {
        require(_pancakeRouter != address(0), "Invalid router address");
        require(_pancakeFactory != address(0), "Invalid factory address");
        require(_pancakePair != address(0), "Invalid pair address");
        
        pancakeRouter = _pancakeRouter;
        pancakeFactory = _pancakeFactory;
        pancakePair = _pancakePair;
        WBNB = IPancakeRouter(_pancakeRouter).WETH();
    }
    
    /**
     * @dev Enable or disable trading
     * @param _enabled Whether trading should be enabled
     */
    function setTradingEnabled(bool _enabled) external onlyOwner {
        require(block.timestamp >= tokenStartTime, "Token start time not reached");
        tradingEnabled = _enabled;
        
        if (_enabled) {
            emit TradingEnabled();
        } else {
            emit TradingDisabled();
        }
    }
    
    /**
     * @dev Update fee structure
     * @param _tradingFee Trading fee (in basis points)
     * @param _liquidityFee Liquidity fee (in basis points)
     * @param _platformFee Platform fee (in basis points)
     */
    function updateFees(
        uint256 _tradingFee,
        uint256 _liquidityFee,
        uint256 _platformFee
    ) external onlyOwner {
        require(_tradingFee <= MAX_FEE, "Trading fee too high");
        require(_liquidityFee <= MAX_FEE, "Liquidity fee too high");
        require(_platformFee <= MAX_FEE, "Platform fee too high");
        require(_tradingFee + _liquidityFee + _platformFee <= MAX_FEE, "Total fees too high");
        
        tradingFee = _tradingFee;
        liquidityFee = _liquidityFee;
        platformFee = _platformFee;
        
        emit FeesUpdated(_tradingFee, _liquidityFee, _platformFee);
    }
    
    /**
     * @dev Update fee recipients
     * @param _liquidityRecipient New liquidity fee recipient
     * @param _platformRecipient New platform fee recipient
     */
    function updateFeeRecipients(
        address _liquidityRecipient,
        address _platformRecipient
    ) external onlyOwner {
        require(_liquidityRecipient != address(0), "Invalid liquidity recipient");
        require(_platformRecipient != address(0), "Invalid platform recipient");
        
        liquidityFeeRecipient = _liquidityRecipient;
        platformFeeRecipient = _platformRecipient;
        
        emit FeeRecipientsUpdated(_liquidityRecipient, _platformRecipient);
    }
    
    /**
     * @dev Exclude account from fees
     * @param account Account to exclude
     * @param excluded Whether to exclude
     */
    function excludeFromFee(address account, bool excluded) external onlyOwner {
        isExcludedFromFee[account] = excluded;
        emit ExcludedFromFee(account, excluded);
    }
    
    /**
     * @dev Exclude account from max transaction
     * @param account Account to exclude
     * @param excluded Whether to exclude
     */
    function excludeFromMaxTransaction(address account, bool excluded) external onlyOwner {
        isExcludedFromMaxTransaction[account] = excluded;
        emit ExcludedFromMaxTransaction(account, excluded);
    }
    
    /**
     * @dev Exclude account from max wallet
     * @param account Account to exclude
     * @param excluded Whether to exclude
     */
    function excludeFromMaxWallet(address account, bool excluded) external onlyOwner {
        isExcludedFromMaxWallet[account] = excluded;
        emit ExcludedFromMaxWallet(account, excluded);
    }
    
    /**
     * @dev Blacklist or whitelist account
     * @param account Account to blacklist/whitelist
     * @param _blacklisted Whether to blacklist
     */
    function setBlacklisted(address account, bool _blacklisted) external onlyOwner {
        blacklisted[account] = _blacklisted;
        emit Blacklisted(account, _blacklisted);
    }
    
    /**
     * @dev Update swap threshold
     * @param _threshold New swap threshold
     */
    function updateSwapThreshold(uint256 _threshold) external onlyOwner {
        uint256 oldThreshold = swapThreshold;
        swapThreshold = _threshold;
        emit SwapThresholdUpdated(oldThreshold, _threshold);
    }
    
    /**
     * @dev Enable or disable swap
     * @param _enabled Whether swap should be enabled
     */
    function setSwapEnabled(bool _enabled) external onlyOwner {
        swapEnabled = _enabled;
        emit SwapEnabled(_enabled);
    }
    
    /**
     * @dev Toggle anti-bot protection
     * @param _enabled Whether anti-bot should be enabled
     */
    function setAntiBotEnabled(bool _enabled) external onlyOwner {
        antiBotEnabled = _enabled;
        emit AntiBotToggled(_enabled);
    }
    
    /**
     * @dev Override transfer function to include fee logic
     */
    function _transfer(address from, address to, uint256 amount) internal override(ERC20, ERC20Pausable) {
        /* Contact Me */
    }
    
    /**
     * @dev Distribute fees to recipients
     * @param feeAmount Total fee amount
     */
    function _distributeFees(uint256 feeAmount) internal {
        if (feeAmount == 0) return;
        
        uint256 liquidityAmount = (feeAmount * liquidityFee) / (tradingFee + liquidityFee + platformFee);
        uint256 platformAmount = (feeAmount * platformFee) / (tradingFee + liquidityFee + platformFee);
        uint256 tradingAmount = feeAmount - liquidityAmount - platformAmount;
        
        if (liquidityAmount > 0) {
            _transfer(address(this), liquidityFeeRecipient, liquidityAmount);
        }
        
        if (platformAmount > 0) {
            _transfer(address(this), platformFeeRecipient, platformAmount);
        }
        
        if (tradingAmount > 0) {
            _transfer(address(this), owner(), tradingAmount);
        }
    }
    
    /**
     * @dev Pause token transfers
     */
    function pause() external onlyOwner {
        _pause();
    }
    
    /**
     * @dev Unpause token transfers
     */
    function unpause() external onlyOwner {
        _unpause();
    }
    
    /**
     * @dev Get token metadata
     */
    function getTokenMetadata() external view returns (
        string memory image,
        string memory description,
        string memory website,
        string memory twitter,
        string memory telegram,
        string memory tag,
        uint256 startTime
    ) {
        return (
            tokenImage,
            tokenDescription,
            tokenWebsite,
            tokenTwitter,
            tokenTelegram,
            tokenTag,
            tokenStartTime
        );
    }
    
    /**
     * @dev Get fee information
     */
    function getFeeInfo() external view returns (
        uint256 _tradingFee,
        uint256 _liquidityFee,
        uint256 _platformFee,
        address _liquidityRecipient,
        address _platformRecipient
    ) {
        return (
            tradingFee,
            liquidityFee,
            platformFee,
            liquidityFeeRecipient,
            platformFeeRecipient
        );
    }
    
    /**
     * @dev Get trading information
     */
    function getTradingInfo() external view returns (
        bool _tradingEnabled,
        bool _antiBotEnabled,
        uint256 _maxTransactionAmount,
        uint256 _maxWalletAmount,
        uint256 _swapThreshold,
        bool _swapEnabled
    ) {
        return (
            tradingEnabled,
            antiBotEnabled,
            maxTransactionAmount,
            maxWalletAmount,
            swapThreshold,
            swapEnabled
        );
    }
}
