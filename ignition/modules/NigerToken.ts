import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const NigerToken = buildModule("NigerToken", (m) => {
  const nigerToken = m.contract("NigerToken", ["NigerToken",'NGN']);

  return { nigerToken };
});

export default NigerToken;
