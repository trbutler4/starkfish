import { Chessboard } from "react-chessboard";
import { useState } from "react";
import { Chess } from "chess.js";

export default function ChessBoard() {
  const [game, setGame] = useState(new Chess());
  const [boardPos, setBoardPos] = useState(game.fen());

  function onDrop(sourceSquare: string, targetSquare: string) {
    console.log(game)
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
      {
        game.isGameOver() ? (
          <div style={{position: 'relative'}}>
            <h1>Game Over</h1>
            <div style={{ 
              position: 'absolute', 
              top: '0', 
              left: '0', 
              width: '100%', 
              height: '100%',
              zIndex: '10',
              pointerEvents: 'auto'
            }} /> 
            <Chessboard id="BasicBoard" position={game.fen()}/>
          </div>
        ) : (
          <Chessboard id="BasicBoard" onPieceDrop={onDrop} position={game.fen()}/>
        )
      }
    </div>
  );
}