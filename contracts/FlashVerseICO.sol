// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interface/AggregatorV3Interface.sol";

contract ICOUpgradeable is Initializable, OwnableUpgradeable, ReentrancyGuardUpgradeable, UUPSUpgradeable {
    /// @notice The token being sold (FVC)
    IERC20 public fvcToken;

    /// @notice Price in USD per token (decimals = 6), e.g., $0.008 = 8000
    uint256 public tokenPrice; // 6 decimals

    /// @notice Chainlink price feeds per accepted token
    mapping(address => address) public priceFeeds;

    /// @notice Accepted payment tokens
    mapping(address => bool) public isAcceptedToken;

    /// @notice ICO timing
    uint256 public startTime;
    uint256 public endTime;

    /// @notice Pause state
    bool public isPaused;

    /// @notice User purchased balances (not yet transferred)
    mapping(address => uint256) public userTokenBalances;

    /// @notice Referral logic
    bool public isReferralEnabled;
    uint256 public referralBonusPercent; // 500 = 5%
    mapping(address => address) public referrerOf;
    mapping(address => bool) public hasPurchased;

    /// @notice Bonus tiers (in USD, decimals = 6)
    struct BonusTier {
        uint256 minAmountUsd;
        uint256 bonusPercent;
    }

    BonusTier[] public bonusTiers;

    /// ---------------- EVENTS ----------------
    event TokenPurchased(address indexed buyer, address indexed token, uint256 amount, uint256 tokensBought, uint256 bonus, address referrer);
    event ReferralBonusGiven(address indexed referrer, address indexed referred, uint256 bonus);
    event Withdrawn(address indexed to, address token, uint256 amount);

    /// ---------------- INITIALIZER ----------------
    function initialize(address _fvcToken, uint256 _price) public initializer {
        __Ownable_init(msg.sender);
        __ReentrancyGuard_init();
        __UUPSUpgradeable_init();

        fvcToken = IERC20(_fvcToken);
        tokenPrice = _price; // $0.008 = 8000 (6 decimals)
        isPaused = false;
        isReferralEnabled = false;
    }

    /// ---------------- BUY FUNCTIONS ----------------

    function buyWithToken(address paymentToken, uint256 amount, address referrer) external nonReentrant {
        require(!isPaused, "ICO is paused");
        require(block.timestamp >= startTime && block.timestamp <= endTime, "ICO inactive");
        require(isAcceptedToken[paymentToken], "Token not accepted");
        require(amount > 0, "Amount must be > 0");

        IERC20(paymentToken).transferFrom(msg.sender, address(this), amount);

        uint256 usdValue = _getUsdValue(paymentToken, amount);
        _processPurchase(msg.sender, usdValue, referrer);
    }

    function buyWithETH(address referrer) external payable nonReentrant {
        require(!isPaused, "ICO is paused");
        require(block.timestamp >= startTime && block.timestamp <= endTime, "ICO inactive");
        require(isAcceptedToken[address(0)], "ETH not accepted");
        require(msg.value > 0, "No ETH sent");

        uint256 usdValue = _getUsdValue(address(0), msg.value);
        _processPurchase(msg.sender, usdValue, referrer);
    }

    /// ---------------- INTERNAL PURCHASE LOGIC ----------------

    function _processPurchase(address buyer, uint256 usdValue, address referrer) internal {
        uint256 baseTokens = (usdValue * 1e18) / tokenPrice;
        uint256 bonus = _calculateBonus(usdValue);
        uint256 totalTokens = baseTokens + bonus;

        // update buyer balance
        userTokenBalances[buyer] += totalTokens;

        // Handle referral logic (one-time only)
        if (isReferralEnabled && referrer != address(0) && referrer != buyer && !hasPurchased[buyer]) {
            uint256 refBonus = (baseTokens * referralBonusPercent) / 10000;
            userTokenBalances[referrer] += refBonus;
            referrerOf[buyer] = referrer;
            emit ReferralBonusGiven(referrer, buyer, refBonus);
        }

        hasPurchased[buyer] = true;

        emit TokenPurchased(buyer, msg.sender, usdValue, baseTokens, bonus, referrerOf[buyer]);
    }

    function _calculateBonus(uint256 usdValue) internal view returns (uint256) {
        uint256 bonusPercent;
        for (uint256 i = bonusTiers.length; i > 0; i--) {
            if (usdValue >= bonusTiers[i - 1].minAmountUsd) {
                bonusPercent = bonusTiers[i - 1].bonusPercent;
                break;
            }
        }
        return (usdValue * 1e18 * bonusPercent) / (tokenPrice * 100);
    }

    function _getUsdValue(address token, uint256 amount) internal view returns (uint256) {
        address feed = priceFeeds[token];
        require(feed != address(0), "Price feed not set");

        (, int256 price,,,) = AggregatorV3Interface(feed).latestRoundData();
        require(price > 0, "Invalid price");

        uint8 decimals = AggregatorV3Interface(feed).decimals();
        return (amount * uint256(price)) / (10 ** decimals);
    }

    /// ---------------- ADMIN FUNCTIONS ----------------

    function setPriceFeeds(address[] calldata tokens, address[] calldata feeds) external onlyOwner {
        require(tokens.length == feeds.length, "Length mismatch");
        for (uint256 i = 0; i < tokens.length; i++) {
            priceFeeds[tokens[i]] = feeds[i];
        }
    }

    function setAcceptedToken(address token, bool accepted) external onlyOwner {
        isAcceptedToken[token] = accepted;
    }

    function setTokenPrice(uint256 price) external onlyOwner {
        tokenPrice = price;
    }

    function setBonusTiers(BonusTier[] calldata tiers) external onlyOwner {
        delete bonusTiers;
        for (uint256 i = 0; i < tiers.length; i++) {
            bonusTiers.push(tiers[i]);
        }
    }

    function setReferral(bool enabled, uint256 percent) external onlyOwner {
        isReferralEnabled = enabled;
        referralBonusPercent = percent;
    }

    function resetReferral(address user, address newReferrer) external onlyOwner {
        referrerOf[user] = newReferrer;
    }

    function setICOTime(uint256 start, uint256 end) external onlyOwner {
        startTime = start;
        endTime = end;
    }

    function pauseICO(bool paused) external onlyOwner {
        isPaused = paused;
    }

    function withdrawETH(address to) external onlyOwner {
        uint256 bal = address(this).balance;
        require(bal > 0, "No ETH");
        payable(to).transfer(bal);
        emit Withdrawn(to, address(0), bal);
    }

    function withdrawToken(address token, address to) external onlyOwner {
        uint256 bal = IERC20(token).balanceOf(address(this));
        require(bal > 0, "No token");
        IERC20(token).transfer(to, bal);
        emit Withdrawn(to, token, bal);
    }

    /// ---------------- UUPS ----------------
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    /// ---------------- VIEW HELPERS ----------------
    function getBonusTiers() external view returns (BonusTier[] memory) {
        return bonusTiers;
    }
}
