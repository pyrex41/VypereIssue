#Vyper Issue

under contracts/Core.vy, if you make the function `functest` payable with the `@payable` decorator, compilation fails.

Note that the interface file for Coin is constructed as follows: `vyper -f json contracts/Coin.vy > interfaces/Coin.json`

Note that `vyper -v == 0.2.16`, and compilation is performed using `brownie compile`, using brownie v1.16.4
