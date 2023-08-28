import { Chessboard } from "react-chessboard";
import { useState } from "react";
import { Chess } from "chess.js";

export default function ChessBoard() {
  const [game, setGame] = useState(new Chess());
  const [boardPos, setBoardPos] = useState(game.fen());

  function onDrop(sourceSquare: string, targetSquare: string) {
    try {
      game.move({
        from: sourceSquare,
        to: targetSquare,
        promotion: "q", // always promote to a queen for example simplicity
      })

      setBoardPos(game.fen())

    } catch(e) {
      alert(e)
    }
  }

  return (
    <div>
      <Chessboard id="BasicBoard" onPieceDrop={onDrop} position={game.fen()}/>
    </div>
  );
}