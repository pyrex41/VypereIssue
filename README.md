# VypereIssue

under contracts/Core.vy, if you make the function `functest` payable with the `@payable` decorator, compilation fails.

Note that the interface file for Coin is constructed as follows: `vyper -f json contracts/Coin.vy > interfaces/Coin.json`
