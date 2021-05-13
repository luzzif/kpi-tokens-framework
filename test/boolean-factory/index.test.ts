import { expect, use } from "chai";
import { formatBytes32String, parseEther } from "ethers/lib/utils";
import { waffle } from "hardhat";
import { fixture } from "../fixtures";
import { getExpectedWrapperAddress } from "../utils";

const { solidity, loadFixture } = waffle;
use(solidity);

describe("BooleanKPITokensFactory", () => {
    it("should succeed when creating simple KPI tokens", async () => {
        const {
            kpiTokensFactory,
            erc1155PositionWrapperFactory,
            erc1155WrapperImplementation,
            ctf,
            oracleAccount,
            testAccount,
            collateralToken,
        } = await loadFixture(fixture);
        const collateralAmount = parseEther("10");

        // mint collateral to caller
        await collateralToken.mint(testAccount.address, collateralAmount);

        // approving collateral to factory
        await collateralToken
            .connect(testAccount)
            .approve(kpiTokensFactory.address, collateralAmount);

        // creating kpi tokens
        const questionId = formatBytes32String("test-question");
        await kpiTokensFactory
            .connect(testAccount)
            .createBooleanKpiTokens(
                oracleAccount.address,
                questionId,
                collateralToken.address,
                collateralAmount,
                ["KPI reached", "KPI not reached"],
                ["KPI-YES", "KPI-NO"]
            );

        const conditionId = await ctf.getConditionId(
            oracleAccount.address,
            questionId,
            2
        );
        for (let i = 0; i < 2; i++) {
            const collectionId = await ctf.getCollectionId(
                formatBytes32String(""),
                conditionId,
                1 << i
            );
            const positionId = await ctf.getPositionId(
                collateralToken.address,
                collectionId
            );
            const erc20WrapperAddress = getExpectedWrapperAddress(
                erc1155PositionWrapperFactory.address,
                erc1155WrapperImplementation.address,
                positionId
            );
            expect(
                await erc1155WrapperImplementation
                    .attach(erc20WrapperAddress)
                    .balanceOf(testAccount.address)
            ).to.be.equal(collateralAmount);
        }
    });
});
