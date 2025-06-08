# Ethereum Address Linker

## Overview

Ethereum Address Linker is a tool that analyzes blockchain transactions to identify potential connections between Ethereum addresses.
This solution is focusing on addresses that have interacted with Tornado Cash mixers.
By constructing a graph of transaction relationships, it can reveal likely links between deposit and withdrawal addresses, helping to trace fund flows despite privacy mechanisms.

## Features

- Analyzes transaction patterns to identify connected addresses
- Constructs a graph of address relationships based on transaction history
- Identifies pairs of deposit and withdrawal addresses that are likely connected
- Exports results to CSV for further analysis
- Caches blockchain data to improve performance on subsequent runs

## Prerequisites

Before you begin, ensure you have the following:

- **Dart SDK**: Version 3.8.1 or higher
- **Etherscan API Key**: Required to fetch transaction data from the Ethereum blockchain
  - Create a free account at [etherscan.io](https://etherscan.io)
  - Generate an API key in your account dashboard
- **Tornado Cash Transaction Data**: CSV files containing transaction records from Tornado Cash mixers
  - These should be placed in the `assets/data/` directory with the following naming convention:
    - `tornadoFullHistoryMixer_0.1ETH.csv`
    - `tornadoFullHistoryMixer_1ETH.csv`
    - `tornadoFullHistoryMixer_10ETH.csv`
    - `tornadoFullHistoryMixer_100ETH.csv`

## Installation

1. Clone the repository:
   ```
   git clone https://github.com/vladdan16/eth_address_linker.git
   cd eth_address_linker
   ```

2. Install dependencies:
   ```
   dart pub get
   dart pub global activate dotenv
   dart pub global run dotenv
   ```

3. Create a `.env` file in the project root with your Etherscan API key:
   ```
   ETHERSCAN_API_KEY=your_api_key_here
   ```

## Usage

Run the address linker with the following command:

```
dart bin/address_linker.dart run
```

## Important Notes

- **First Run Performance**: The first time you run the application, it will fetch data from the Etherscan API, which can take a significant amount of time (potentially hours depending on the number of addresses being analyzed).
- **Caching**: After the initial run, transaction data is cached locally, making subsequent runs much faster.
- **Output**: The results are saved as CSV files in the `assets/data/` directory:
  - `address_pairs.csv`: Contains pairs of deposit and withdrawal addresses that are likely connected

## How It Works

1. The tool loads transaction data from Tornado Cash mixer contracts
2. It constructs a graph of address relationships based on transaction history
3. Using a Union-Find algorithm, it identifies connected components in the graph
4. It generates pairs of deposit and withdrawal addresses that belong to the same connected component
5. The results are saved to a CSV file for further analysis

## Limitations

- Analysis is based on on-chain transaction patterns and may not capture all relationships
- Performance depends on the number of addresses being analyzed and your Etherscan API rate limits
- The tool focuses on Tornado Cash transactions and may not identify other privacy mechanisms
