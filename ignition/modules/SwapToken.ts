import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const SwapToken = buildModule("SwapToken", (m) => {
  const swapToken= m.contract("SwapToken");

  return { swapToken };
});

export default SwapToken;
