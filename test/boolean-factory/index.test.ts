import { use } from "chai";
import {
    defaultAbiCoder,
    formatBytes32String,
    parseEther,
} from "ethers/lib/utils";
import { ethers, waffle } from "hardhat";
import { fixture } from "../fixtures";
import { encodeRealityQuestion } from "../utils";
import { DateTime, Duration } from "luxon";
import { Wallet } from "ethers";

const { solidity, loadFixture } = waffle;
use(solidity);

describe("BooleanKPITokensFactory", () => {
    it("should succeed when creating simple KPI tokens", async () => {
        const {
            kpiTokensFactory,
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
        const oracleData = defaultAbiCoder.encode(
            ["string", "address", "uint32", "uint32", "uint256"],
            [
                encodeRealityQuestion("Will this test pass?"),
                Wallet.createRandom().address, // random arbitrator just to make the test go through
                Math.floor(
                    Duration.fromObject({ minutes: 2 }).toMillis() / 1000
                ),
                Math.floor(DateTime.now().plus({ seconds: 2 }).toSeconds()),
                1,
            ]
        );
        await kpiTokensFactory
            .connect(testAccount)
            .createKpiToken(
                collateralToken.address,
                collateralAmount,
                "Test KPI",
                "KPI",
                parseEther("10000"),
                oracleData
            );
    });
});
