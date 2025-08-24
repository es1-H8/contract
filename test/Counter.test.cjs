const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Counter", function () {
  let Counter;
  let counter;
  let owner;
  let addr1;
  let addr2;

  beforeEach(async function () {
    // Get the ContractFactory and Signers here.
    Counter = await ethers.getContractFactory("Counter");
    [owner, addr1, addr2] = await ethers.getSigners();

    // Deploy a new Counter contract before each test
    counter = await Counter.deploy();
    await counter.waitForDeployment();
  });

  describe("Deployment", function () {
    it("Should start with count at 0", async function () {
      expect(await counter.getCount()).to.equal(0);
    });
  });

  describe("Increment Functions", function () {
    it("Should increment by 1", async function () {
      await counter.increment();
      expect(await counter.getCount()).to.equal(1);
    });

    it("Should increment by specific amount", async function () {
      await counter.incrementBy(5);
      expect(await counter.getCount()).to.equal(5);
    });

    it("Should emit Incremented event", async function () {
      await expect(counter.increment())
        .to.emit(counter, "Incremented")
        .withArgs(1);
    });

    it("Should emit Incremented event with amount", async function () {
      await expect(counter.incrementBy(3))
        .to.emit(counter, "Incremented")
        .withArgs(3);
    });
  });

  describe("Validation", function () {
    it("Should revert when incrementing by 0", async function () {
      await expect(counter.incrementBy(0))
        .to.be.revertedWith("Amount must be greater than 0");
    });
  });

  describe("Multiple Operations", function () {
    it("Should handle multiple increments correctly", async function () {
      await counter.increment();
      await counter.increment();
      await counter.incrementBy(5);
      expect(await counter.getCount()).to.equal(7);
    });

    it("Should allow anyone to increment", async function () {
      await counter.connect(addr1).increment();
      await counter.connect(addr2).incrementBy(3);
      expect(await counter.getCount()).to.equal(4);
    });
  });
}); 