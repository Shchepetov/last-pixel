// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./game.sol";

contract Factory is Owned {

    Game[] public games;

    event GameCreated(address gameAddress);
    event GameDeleted(address gameAddress);

    function createGame() external payable isOwner {
        Game game = new Game{value: msg.value}(games.length);
        games.push(game);

        emit GameCreated(address(game));
    }

    function deleteGame(uint i) external isOwner {
        require (games.length > i);
        require (games[i].isEnabled() == true);

        games[i].closeGame();
        
        emit GameDeleted(address(games[i]));
    }

    function closeFactory() external isOwner {

        for (uint i=0; i < games.length; i++){
            if (games[i].isEnabled() == true){
                games[i].closeGame();
            }
        }
        selfdestruct(owner); 
 }
}