// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./owner.sol";

contract Game is Owned {
  
  uint8 constant public FIELD_SIDE = 7;
  uint constant public TIME_OUT = 600;
  uint8 constant public NUM_COLOURS = 10;

  uint8 constant TIME_BANK_SHARE = 80; // 80%
  uint8 constant MOVE_PRICE_UPRATE = 103; // 103%
  uint8 constant NUM_CELLS = FIELD_SIDE * FIELD_SIDE;
  uint constant INIT_MOVE_PRICE = 10000000000000000; // 0.01 eth

  uint public timeBank = 0;
  uint public colourBank = 0;
  uint public currentMovePrice = INIT_MOVE_PRICE;
  uint8 public bannedColour = 1;

  uint256 public lastChangeTime;
  address payable public lastChanger;
    
  struct Cell {
    uint8 colour;
    address payable lastChanger;
  }

  Cell[NUM_CELLS] public gameField;

  event newMove(address indexed player, uint8 n, uint8 _colour);
  event colourBankWin(address[NUM_CELLS] indexed player, uint amount);
  event timeBankWin(address indexed player, uint amount);
  event gameIsOverThanksToEveryone();

  constructor() {

    for (uint8 i = 0; i < NUM_CELLS; i++)
      gameField[i] = Cell(bannedColour, payable(address(this)));
    lastChanger = gameField[0].lastChanger;
    lastChangeTime = block.timestamp;
  }

  modifier checkTimeWinner {

    if (timeBank != 0 && _timeIsOver())
      _rewardTimeBank();
    _;
  }

  function _timeIsOver() internal view returns (bool) {

    if (block.timestamp - lastChangeTime >= TIME_OUT)
      return true;
    return false;
  }

  function _rewardTimeBank() internal {

    require(address(this).balance >= timeBank, "Address: insufficient balance");

    (bool success,) = lastChanger.call{value:timeBank}('');
  
    require(success, "Time reward failed.");

    emit timeBankWin(lastChanger, timeBank);

    timeBank = 0;
  }

  function paintCell(uint8 _n, uint8 _colour) external payable checkTimeWinner {

    require (msg.value == currentMovePrice, "Insufficient deposit");
    require (0 < _n && _n <= NUM_CELLS, "Cell number is out of range");
    require (0 < _colour && _colour <= NUM_COLOURS, "Incorrect colour number");

    timeBank += msg.value / 100 * TIME_BANK_SHARE;
    colourBank +=  msg.value / 100 * (100 - TIME_BANK_SHARE);

    lastChanger = payable(msg.sender);
    lastChangeTime = block.timestamp;
    gameField[_n-1] = Cell(_colour, lastChanger);
    currentMovePrice = currentMovePrice / 100 * MOVE_PRICE_UPRATE;

    emit newMove(msg.sender, _n, _colour);

    if (_fieldIsPlain())
      _rewardColourBank();
  }

  function _fieldIsPlain() internal view returns (bool) {

    uint8 firstCeilColour = gameField[0].colour;

    if (firstCeilColour == bannedColour)
      return false;
      
    for (uint8 i = 1; i < NUM_CELLS; i++)
      if (gameField[i].colour != firstCeilColour)
        return false;

    return true;
  }

  function _rewardColourBank() internal {


    require(address(this).balance >= colourBank, "Address: insufficient balance");
    
    uint bankShare = colourBank / NUM_CELLS;
    address[NUM_CELLS] memory winners;
    address payable winner;
    bool success;
    for (uint8 i = 0; i < NUM_CELLS; i++) {
      winner = gameField[i].lastChanger;
      (success,) = winner.call{value:bankShare}('');

      require(success, "Bank reward failed.");

      winners[i] = winner;
    }
    colourBank -= bankShare * NUM_CELLS;
    bannedColour = gameField[0].colour;

    emit colourBankWin(winners, bankShare);
  }

  function updateTimer() external payable checkTimeWinner {}

  function closeGame() public isOwner {

    emit gameIsOverThanksToEveryone();
    selfdestruct(owner); 
 }
}
