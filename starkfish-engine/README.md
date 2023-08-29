
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



// board layout 	
//  8   56	57	58	59	60	61	62	63
//  7   48	49	50	51	52	53	54	55
//  6   40	41	42	43	44	45	46	47
//  5   32	33	34	35	36	37	38	39
//  4   24	25	26	27	28	29	30	31
//  3   16	17	18	19	20	21	22	23
//  2   08	09	10	11	12	13	14	15
//  1   00	01	02	03	04	05	06	07
//      A   B   C   D   E   F   G   H







