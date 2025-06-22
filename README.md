

# FlashVerse Token (FVC)

FlashVerse Token (FVC) is a fixed-supply, ERC-20 compliant token deployed on the Polygon zkEVM network. The token is upgradeable using OpenZeppelin's proxy pattern and supports manual token burns by whitelisted addresses.


## 🛠 Features

- ✅ ERC-20 standard with 18 decimals
- ✅ Fixed total supply: 18,000,000,000 FVC
- ✅ Upgradeable via OpenZeppelin Transparent Proxy
- ✅ Burn functionality for whitelisted addresses
- ✅ Whitelist management by the contract owner

---

## 🧱 Contract Structure

- **`FlashVerseToken.sol`**: Upgradeable ERC-20 contract with burn and whitelist support

---

## 📂 Folder Structure

```

flashverse-token/
├── contracts/
│   └── FlashVerseToken.sol
├── scripts/
│   ├── deploy-localhost.js
│   └── deploy-polygon-testnet.js
├── test/
│   └── FlashVerseToken.test.js
├── hardhat.config.js
├── .env
└── README.md

````

---

## 🚀 Deployment

### 1. Install Dependencies

```bash
npm install
````

### 2. Compile Contracts

```bash
npx hardhat compile
```

### 3. Deploy to Localhost

Start a local node:

```bash
npx hardhat node
```

Then run:

```bash
npx hardhat run scripts/deploy.js --network localhost
```

### 4. Deploy to Polygon zkEVM Testnet

Add your private key in a `.env` file:

```
PRIVATE_KEY=your_private_key_here
```

Then run:

```bash
npx hardhat run scripts/deploy.js --network polygonTestnet
```

---

## 🧪 Run Tests

```bash
npx hardhat test
```

---

## 🔒 Environment Variables

`.env` file should include:

```
PRIVATE_KEY=your_wallet_private_key
```

---

## 🧬 License

This project is licensed under the MIT License.

```

---

Let me know if you want to add:
- Badges (e.g., for Polygon, Hardhat, OpenZeppelin)
- Extended usage instructions for whitelist/burn
- GitHub Actions CI/CD or verification scripts
```
