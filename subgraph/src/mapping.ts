import { Swap } from "../generated/AMMPair/AMMPair";
import { AMMSwap } from "../generated/schema";

export function handleSwap(event: Swap): void {
  let id = event.transaction.hash.toHex() + "-" + event.logIndex.toString();
  let entity = new AMMSwap(id);
  entity.pair = event.address;
  entity.sender = event.params.sender;
  entity.tokenIn = event.params.tokenIn;
  entity.tokenOut = event.params.tokenOut;
  entity.amountIn = event.params.amountIn;
  entity.amountOut = event.params.amountOut;
  entity.timestamp = event.block.timestamp;
  entity.save();
}
