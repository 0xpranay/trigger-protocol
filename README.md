# Trigger Protocol
Trigger protocol democratises on chain actions, fixing fragmented actions/bot merkets.

## The problem
1. Many on chain platforms like 1Inch and Instadapp offer actions to their users like limit orders and aave position protection. 
2. This leads to fragmented actions market. Specialized platform bots have a closed actions/order book and don't encourage healthy competition and innovation.
3. If the actions market was directly profitable to any bots that can plug into it, it ensures that their strategies remove innovative and the users offered best service.

## The solution
1. We aim to democratize this actions market by introducing trigger protocol. 
2. Users can specify ANY `Condition` that's computable on-chain.
3. They can also pass in ANY `Action` that's executable when that condition is satisfied
4. Bots or executors are then rewarded by a `Payout` that the user has set. This can be an ERC20 reward or a premium over gas fee.

## The Pros
1. Since the `Actions` and `Conditions` can be anything executable, the protocol becomes highly composable.
2. Any existing strategies can be easily plugged in.
3. Bots are directly rewarded a `Payout` that's viewable on chain by the executor any time

## The Cons
1. The actions book is entirely on-chain, which is throttled by the blockchain's gas fees. But we don't think this can be an issue since the solution is aimed at L2s like Polygon
