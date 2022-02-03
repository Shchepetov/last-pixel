const { expect } = require("chai").use(require('chai-as-promised'));
const { ethers } = require("hardhat");


async function newFactory() {
  const GameFactory = await ethers.getContractFactory("GameFactory");
  const factory = await GameFactory.deploy();
  await factory.deployed();

  return factory;
}

describe("GameFactory", async function () {
  var factory, game;

  before(async () => {
    factory = await newFactory();

    const createGameTx = await factory.createGame();
    await createGameTx.wait();

    const Game = await ethers.getContractFactory("Game");
    game = Game.attach(await factory.games(0));

  });
  it("Create child games", async function () {

    expect(await game.index()).to.be.equal(0);
  });

  it("Delete child games", async function () {

    const deleteGameTx = await factory.deleteGame("0");
    await deleteGameTx.wait();

    await expect(game.index()).to.be.rejected;
  });
});


describe("Game", async function () {
  var factory, game;

  before(async () => {
    factory = await newFactory();
    const createGameTx = await factory.createGame();
    await createGameTx.wait();

    const Game = await ethers.getContractFactory("Game");
    game = Game.attach(await factory.games(0));
  });

  beforeEach(async () => {
    bannedColour = await game.bannedColour();
    correctColour = (bannedColour == 1) ? 2 : 1;
    currentMovePrice = await game.currentMovePrice();
  });

  it("Deposit should equals to current move price", async function () {
    await expect(game.paintCell(1, correctColour, {value: currentMovePrice.add(1)}))
      .to.be.revertedWith("Insufficient deposit");
    await expect(game.paintCell(1, correctColour, {value: currentMovePrice.add(-1)}))
      .to.be.revertedWith("Insufficient deposit");
  });

  it("Paint colour shouldn't be banned", async function () {
    await expect(game.paintCell(1, bannedColour, {value: currentMovePrice}))
      .to.be.revertedWith("This colour is banned");
  });

  it("Correct deposit should increase bank amount", async function () {
    const colourBank = await game.colourBank();
    const timeBank = await game.timeBank();

    await game.paintCell(1, correctColour, {value: currentMovePrice});

    expect(await game.colourBank()).to.be.gt(colourBank);
    expect(await game.timeBank()).to.be.gt(timeBank);
  });
});
