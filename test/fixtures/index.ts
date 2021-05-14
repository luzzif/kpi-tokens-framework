import { MockProvider } from "ethereum-waffle";
import { ethers } from "hardhat";
import {
    KPITokensFactory,
    KPITokensFactory__factory,
    KPIToken,
    KPIToken__factory,
    Realitio,
    Realitio__factory,
    ERC20PresetMinterPauser,
    ERC20PresetMinterPauser__factory,
    Reality,
    Reality__factory,
} from "../../typechain";

export const fixture = async (_: any, provider: MockProvider) => {
    const [, testAccount, oracleAccount] = provider.getWallets();

    const realitioFactory = (await ethers.getContractFactory(
        "Realitio"
    )) as Realitio__factory;
    const realitio = (await realitioFactory.deploy()) as Realitio;

    const realityFactory = (await ethers.getContractFactory(
        "Reality"
    )) as Reality__factory;
    const reality = (await realityFactory.deploy(realitio.address)) as Reality;

    const kpiTokenFactory = (await ethers.getContractFactory(
        "KPIToken"
    )) as KPIToken__factory;
    const kpiToken = (await kpiTokenFactory.deploy()) as KPIToken;

    const kpiTokensFactoryFactory = (await ethers.getContractFactory(
        "KPITokensFactory"
    )) as KPITokensFactory__factory;
    const kpiTokensFactory = (await kpiTokensFactoryFactory.deploy(
        kpiToken.address,
        reality.address
    )) as KPITokensFactory;

    const collateralTokenFactory = (await ethers.getContractFactory(
        "ERC20PresetMinterPauser"
    )) as ERC20PresetMinterPauser__factory;
    const collateralToken = (await collateralTokenFactory.deploy(
        "Collateral",
        "CLT"
    )) as ERC20PresetMinterPauser;

    return {
        testAccount,
        oracleAccount,
        kpiToken,
        kpiTokensFactory,
        collateralToken,
    };
};
