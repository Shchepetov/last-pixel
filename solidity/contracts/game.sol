// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./owner.sol";
import {ShareMapping} from "./keymap.sol";

contract Game is Owned {
  using ShareMapping for ShareMapping.Map; 
  
  uint8 constant public FIELD_SIDE = 7;
  uint constant public TIME_OUT = 600;
  uint8 constant public NUM_COLOURS = 10;

  uint8 constant private TIME_BANK_SHARE = 80; // 80%
  uint8 constant private MOVE_PRICE_UPRATE = 103; // 103%
  uint8 constant private NUM_CELLS = FIELD_SIDE * FIELD_SIDE;
  uint constant private INIT_MOVE_PRICE = 10000000000000000; // 0.01 eth

  uint public index;
  bool public isEnabled;
  uint public timeBank = 0;
  uint public colourBank = 0;
  mapping(address => uint) public retainedPrizes;
  uint public currentMovePrice = INIT_MOVE_PRICE;
  uint8 public bannedColour = 1;

  uint256 public lastChangeTime;
  address payable public lastChanger;
  
  ShareMapping.Map[NUM_COLOURS] private paintHistory;

  struct Cell {
    uint8 colour;
    address payable lastChanger;
  }

  Cell[NUM_CELLS] public gameField;

  event NewMove(address indexed player, uint8 n, uint8 _colour);
  event ColourBankWin(address[] indexed players, uint amount);
  event TimeBankWin(address indexed player, uint amount);
  event GameIsOverThanksToEveryone();

  constructor(uint _index) payable {

    index = _index;
    isEnabled = true;
    if (msg.value > 0){
      timeBank = msg.value / 100 * TIME_BANK_SHARE;
      colourBank = msg.value - timeBank;
    }

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

    (bool success,) = lastChanger.call{value:timeBank}("");
    require(success, "Time reward failed.");

    emit TimeBankWin(lastChanger, timeBank);

    timeBank = 0;
  }

  function paintCell(uint8 _n, uint8 _colour) external payable checkTimeWinner {

    require (msg.value == currentMovePrice, "Insufficient deposit");
    require (0 < _n && _n <= NUM_CELLS, "Cell number is out of range");
    require (0 < _colour && _colour <= NUM_COLOURS, "Incorrect colour number");
    require (_colour != bannedColour, "This colour is banned");

    timeBank += msg.value / 100 * TIME_BANK_SHARE;
    colourBank +=  msg.value / 100 * (100 - TIME_BANK_SHARE);

    _updateHistory(_n-1);

    lastChanger = payable(msg.sender);
    lastChangeTime = block.timestamp;
    gameField[_n-1] = Cell(_colour, lastChanger);
    currentMovePrice = currentMovePrice / 100 * MOVE_PRICE_UPRATE;

    emit NewMove(msg.sender, _n, _colour);

    if (_fieldIsPlain())
      _rewardColourBank(gameField[0].colour);
  }

  function _updateHistory(uint8 n) internal {
    Cell memory lastPaint = gameField[n];
    if (lastPaint.colour != bannedColour){
      paintHistory[lastPaint.colour].increment(lastPaint.lastChanger);
    }
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

  function _rewardColourBank(uint8 colour) internal {

    require(address(this).balance >= colourBank, "Address: insufficient balance");

    for (uint8 i = 0; i < NUM_CELLS; i++){
      _updateHistory(i);
    }

    uint colourBankCopy = colourBank;
    uint bankSegment = colourBank / paintHistory[colour].shares;

    address winner;
    uint winnerPrize;

    uint winnersCount = paintHistory[colour].keys.length;
    address[] memory winners = new address[](winnersCount);

    for (uint8 i = 0; i < winnersCount; i++) {
      winner = paintHistory[colour].keys[i];
      winnerPrize = paintHistory[colour].data[winner] * bankSegment;

      retainedPrizes[winner] += winnerPrize;

      colourBank -= winnerPrize;
      winners[i] = winner;
    }

    paintHistory[colour].clear();
    bannedColour = colour;

    emit ColourBankWin(winners, colourBankCopy - colourBank);
  }

  function checkOutcome() external payable checkTimeWinner {

    if (retainedPrizes[msg.sender] > 0){
      (bool success,) = msg.sender.call{value:retainedPrizes[msg.sender]}("");

      require(success, "Bank reward failed.");

      delete retainedPrizes[msg.sender];
    }
  }

  function closeGame() external isOwner {

    emit GameIsOverThanksToEveryone();

    isEnabled = false;
    selfdestruct(owner); 
 }
}
