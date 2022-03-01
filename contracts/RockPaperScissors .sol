//SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;
import "hardhat/console.sol";

contract RockPaperScissors {
  Game[] public games;

  enum GameStatus {
    OPEN,
    CLOSED,
    AWAITING_REVEAL,
    INVALID_MOVE
  }

  enum Result {
    AWAITING,
    DRAW,
    PLAYER1,
    PLAYER2
  }

  enum Move {
    ROCK,
    PAPER,
    SCISSORS,
    AWAITING
  }
  struct Player {
    address addr;
    Move move;
    bytes32 hashedMove;
  }

  struct Game {
    Player player1;
    Player player2;
    uint256 bet;
    GameStatus status;
    Result result;
  }

  modifier validBet(uint256 bet) {
    require(bet > 0, "Invalid bet value");
    _;
  }
  modifier validHashedMove(bytes32 hashedMove) {
    require(hashedMove.length > 0, "Empty move");
    _;
  }
  modifier validGame(uint256 gameIndex) {
    require(gameIndex <= games.length, "Invalid game number");
    _;
  }

  function createGame(uint256 bet, bytes32 hashedMove) external validBet(bet) validHashedMove(hashedMove) {
    Player memory player1 = Player(msg.sender, Move.AWAITING, hashedMove);
    Player memory player2 = Player(address(0), Move.AWAITING, "");
    games.push(Game(player1, player2, bet, GameStatus.OPEN, Result.AWAITING));
  }

  function playerJoin(uint256 gameIndex, bytes32 hashedMove) external validGame(gameIndex) {
    require(games[gameIndex].player1.addr != msg.sender, "Cannot play against yourself.");
    require(games[gameIndex].status == GameStatus.OPEN, "Cannot join game");
    games[gameIndex].player2 = Player(msg.sender, Move.AWAITING, hashedMove);
    games[gameIndex].status = GameStatus.AWAITING_REVEAL;
  }

  function revealChoice(
    string memory salt,
    Move move,
    uint256 gameIndex
  ) external validGame(gameIndex) {
    Game memory game = games[gameIndex];
    require(game.status == GameStatus.AWAITING_REVEAL, "Cannot join game");
    require(game.player1.addr == msg.sender || game.player2.addr == msg.sender, "Invalid Player");

    if (game.player1.addr == msg.sender) {
      require(game.player1.hashedMove == keccak256(abi.encodePacked(move, salt)), "Invalid Salt 1");
      game.player1.move = move;
    } else {
      require(game.player2.hashedMove == keccak256(abi.encodePacked(move, salt)), "Invalid Salt 2");
      game.player2.move = move;
    }
    games[gameIndex] = game;
    if (game.player1.move != Move.AWAITING && game.player2.move != Move.AWAITING) endgame(gameIndex);
  }

  function endgame(uint256 gameIndex) internal {
    Game memory game = games[gameIndex];
    if (game.player1.move == game.player2.move) {
      game.status = GameStatus.CLOSED;
      game.result = Result.DRAW;
      games[gameIndex] = game;
      return;
    }
    if (
      (game.player1.move == Move.ROCK && game.player2.move == Move.SCISSORS) ||
      (game.player1.move == Move.PAPER && game.player2.move == Move.ROCK) ||
      (game.player1.move == Move.SCISSORS && game.player2.move == Move.PAPER)
    ) {
      game.result = Result.PLAYER1;
    } else {
      game.result = Result.PLAYER2;
    }
    game.status = GameStatus.CLOSED;
    games[gameIndex] = game;
  }
}

//0x5dfcac834f61c0314cc9e5b4b6491434c720ff9e25caf85f8e6faa3991d15fda
