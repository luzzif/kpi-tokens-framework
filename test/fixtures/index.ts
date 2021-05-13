import { MockProvider } from "ethereum-waffle";
import { ethers } from "hardhat";
import {
    BooleanKPITokensFactory,
    BooleanKPITokensFactory__factory,
    ConditionalTokens,
    ConditionalTokens__factory,
    ERC1155PositionWrapper,
    ERC1155PositionWrapperFactory,
    ERC1155PositionWrapperFactory__factory,
    ERC1155PositionWrapper__factory,
    ERC20PresetMinterPauser,
    ERC20PresetMinterPauser__factory,
} from "../../typechain";

export const fixture = async (_: any, provider: MockProvider) => {
    const [, testAccount, oracleAccount] = provider.getWallets();

    const ctfFactory = (await ethers.getContractFactory(
        "ConditionalTokens"
    )) as ConditionalTokens__factory;
    const ctf = (await ctfFactory.deploy()) as ConditionalTokens;

    const erc1155WrapperImplementationFactory = (await ethers.getContractFactory(
        "ERC1155PositionWrapper"
    )) as ERC1155PositionWrapper__factory;
    const erc1155WrapperImplementation = (await erc1155WrapperImplementationFactory.deploy()) as ERC1155PositionWrapper;

    const erc1155PositionWrapperFactoryFactory = (await ethers.getContractFactory(
        "ERC1155PositionWrapperFactory"
    )) as ERC1155PositionWrapperFactory__factory;
    const erc1155PositionWrapperFactory = (await erc1155PositionWrapperFactoryFactory.deploy(
        erc1155WrapperImplementation.address,
        ctf.address
    )) as ERC1155PositionWrapperFactory;

    const kpiTokensFactoryFactory = (await ethers.getContractFactory(
        "BooleanKPITokensFactory"
    )) as BooleanKPITokensFactory__factory;
    const kpiTokensFactory = (await kpiTokensFactoryFactory.deploy(
        ctf.address,
        erc1155PositionWrapperFactory.address
    )) as BooleanKPITokensFactory;

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
        ctf,
        erc1155WrapperImplementation,
        erc1155PositionWrapperFactory,
        kpiTokensFactory,
        collateralToken,
    };
};
