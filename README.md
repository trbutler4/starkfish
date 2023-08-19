
# starkfish -- starknet chess engine 

## resources 
 - chess programming wiki - https://www.chessprogramming.org/Move_Generation
 - bitboard representation - https://pages.cs.wisc.edu/~psilord/blog/data/chess-pages/rep.html
 - generating moves - https://peterellisjones.com/posts/generating-legal-chess-moves-efficiently/
 - lichess board editor - https://lichess.org/editor
 - rust stockfish rewrite - https://github.com/pleco-rs/Pleco
 - bitboard calculator - https://gekomad.github.io/Cinnamon/BitboardCalculator/



 bitboard -> 64 bit number 
 LSB -> A1 on chess board 
 MSB -> H8 on chess board

 example: white pawns -> 00000000 00000000 00000000 00000000 00000000 00000000 11111111 00000000

 white pawns as a bitboard:

        00000000 MSB
        00000000
        00000000
        00000000
        00000000
        00000000
        11111111
    LSB 00000000

 there is a direct mapping between bit index and board position: 
    A1 -> 0 
    B1 -> 1 
    C1 -> 3 
    ...
    G8 -> 62
    H8 -> 63








