#Vyper Issue

under contracts/Core.vy, compilation fails.

Note that the interface file for Coin is constructed as follows: `vyper -f json contracts/Coin.vy > interfaces/Coin.json`

Note that `vyper -v == 0.2.16`, and compilation is performed using `brownie compile`, test using brownie v1.16.4 and v1.17.0
