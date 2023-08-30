use starkfish::board::Board;
use core::ArrayTrait;
use starkfish::constants::{BLACK, WHITE, EMPTY, PAWN, ROOK, KNIGHT, BISHOP, QUEEN, KING};

#[derive(Drop, Serde)]
struct Move {
    from: usize,
    to: usize
}


// ---------------------------------------------------------------------
// -------------- MOVE GENERATOR ---------------------------------------
// ---------------------------------------------------------------------

// board indexes
//  56	57	58	59	60	61	62	63
//  48	49	50	51	52	53	54	55
//  40	41	42	43	44	45	46	47
//  32	33	34	35	36	37	38	39
//  24	25	26	27	28	29	30	31
//  16	17	18	19	20	21	22	23
//  08	09	10	11	12	13	14	15
//  00	01	02	03	04	05	06	07

fn generate_moves(board: Board, turn: felt252) -> Array<Move> {
    // TODO: generate moves for otherwise empty board
    // TODO: add logic for detecting checks 
    // TODO: add logic for detecting pins
    // TODO: add logic for castling 
    // TODO: add logic for en-passant 
    
    // for storing moves
    let mut moves: Array<Move> = ArrayTrait::new();

    
    // iterating once through the squares to 
    //  generate all legal moves for the given board and color
    let mut sq_index = 0_usize;
    loop {
        if (sq_index > 63) { break; }

        let piece = *board.pieces.at(sq_index);
        let color = *board.colors.at(sq_index);
        let row = sq_index / 7;

        // only need to generate moves for the current player
        if (color == turn) {
           
            // -------------------------
            // ----- pawn moves -------- 
            // -------------------------
            if (piece == PAWN) {

            }

            // -------------------------
            // ----- knight moves ------
            // -------------------------
            if (piece == KNIGHT) {

            }

            // -------------------------
            // ----- rook moves ------
            // -------------------------
            if (piece == ROOK) {

            }

            // -------------------------
            // ----- bishop moves ------
            // -------------------------
            if (piece == BISHOP) {

            }

            // -------------------------
            // ----- queen moves -------
            // -------------------------
            if (piece == QUEEN) {

            }

        }

        sq_index += 1;
    };

    moves
}
