// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract FlashVerseToken is Initializable, ERC20Upgradeable, OwnableUpgradeable {
    uint256 public constant INITIAL_SUPPLY = 18_000_000_000 * 10 ** 18;

    mapping(address => bool) private whitelistedBurners;

    event BurnerWhitelisted(address indexed account, bool isWhitelisted);
    event TokensBurned(address indexed burner, uint256 amount);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address owner_) public initializer {
        __ERC20_init("FlashVerse Token", "FVC");
        __Ownable_init(owner_);

        _mint(owner_, INITIAL_SUPPLY);
        transferOwnership(owner_);
    }

    function setBurnerWhitelist(address account, bool status) external onlyOwner {
        whitelistedBurners[account] = status;
        emit BurnerWhitelisted(account, status);
    }

    function isBurnerWhitelisted(address account) external view returns (bool) {
        return whitelistedBurners[account];
    }

    function burn(uint256 amount) external {
        require(whitelistedBurners[msg.sender], "Not whitelisted to burn");
        _burn(msg.sender, amount);
        emit TokensBurned(msg.sender, amount);
    }
}
