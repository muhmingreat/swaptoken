import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const UsaToken = buildModule("UsaToken", (m) => {
  const usaToken= m.contract("SwapToken",["USA","USD"]);

  return { usaToken };
});

export default UsaToken;
