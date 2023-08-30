use starkfish::board::{Board, BoardTrait};
use core::ArrayTrait;
use starkfish::constants::{
    BLACK, WHITE, EMPTY, PAWN, ROOK, KNIGHT, BISHOP, QUEEN, KING,
    ONE_COL, ONE_RANK, TWO_RANKS, RIGHT_SINGLE_DIAG, LEFT_SINGLE_DIAG};
use starkfish::utils::{get_rank_index, get_file_index};
use debug::PrintTrait;

#[derive(Drop, Serde)]
struct Move {
    from: usize,
    to: usize,
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


// TODO: this branching logic is horrendus. Should probably try to optimize 
// with enums and matching?
fn generate_moves(board: Board, turn: felt252) -> Array<Move> {
    // TODO: generate moves for otherwise empty board
    // TODO: add logic for detecting checks 
    // TODO: add logic for detecting pins
    // TODO: add logic for pawn promotion
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
        let rank = get_rank_index(sq_index);
        let file = get_file_index(sq_index);

        // only need to generate moves for the current player
        if (color == turn) {
           
            // -------------------------
            // ----- pawn moves -------- 
            // -------------------------
            if (piece == PAWN) {
                if (turn == WHITE) {
                    if (// pawn can single push 
                        *board.pieces.at(sq_index + ONE_RANK) == EMPTY
                    ) {
                        moves.append(Move { 
                            from: sq_index, 
                            to: sq_index + ONE_RANK
                        });
                    }
                    if (// white pawn can double push
                        rank == 1 && 
                        *board.pieces.at(sq_index + ONE_RANK) == EMPTY &&
                        *board.pieces.at(sq_index + TWO_RANKS) == EMPTY 
                    ) {
                        moves.append(Move { 
                            from: sq_index, to: sq_index + TWO_RANKS
                        });
                    }
                    if (// white pawn can take to the left
                        file > 0 && 
                        *board.pieces.at(sq_index + RIGHT_SINGLE_DIAG) == BLACK
                    ) {
                        moves.append(Move {
                            from: sq_index, to: sq_index + RIGHT_SINGLE_DIAG
                        })
                    }
                    if (// white pawn can take to the right 
                        file < 7 && 
                        *board.pieces.at(sq_index + RIGHT_SINGLE_DIAG) == BLACK
                    ) {
                        moves.append(Move {
                            from: sq_index, to: sq_index + RIGHT_SINGLE_DIAG
                        })
                    }
                } else {
                    if (// pawn can single push 
                        rank > 0 && // prevent overflow
                        *board.pieces.at(sq_index - ONE_RANK) == EMPTY
                    ) {
                        moves.append(Move { 
                            from: sq_index, 
                            to: sq_index - ONE_RANK
                        });
                    }
                    if (// white pawn can double push
                        rank == 6 && 
                        *board.pieces.at(sq_index - ONE_RANK) == EMPTY &&
                        *board.pieces.at(sq_index - TWO_RANKS) == EMPTY 
                    ) {
                        moves.append(Move { 
                            from: sq_index, to: sq_index - TWO_RANKS
                        });
                    }
                    if (// black pawn can take to the left
                        rank > 0 && // prevent overflow
                        file > 0 && 
                        *board.pieces.at(sq_index - LEFT_SINGLE_DIAG) == BLACK
                    ) {
                        moves.append(Move {
                            from: sq_index, to: sq_index - LEFT_SINGLE_DIAG
                        })
                    }
                    if (// black pawn can take to the right 
                        rank > 0 && // prevent overflow
                        file < 7 && 
                        *board.pieces.at(sq_index - RIGHT_SINGLE_DIAG) == BLACK
                    ) {
                        moves.append(Move {
                            from: sq_index, to: sq_index - RIGHT_SINGLE_DIAG
                        })
                    }

                }
            }

            // -------------------------
            // ----- knight moves ------
            // -------------------------
            if (piece == KNIGHT) {
                // TODO
            }

            // -------------------------
            // ----- rook moves ------
            // -------------------------
            if (piece == ROOK) {
                // TODO
            }

            // -------------------------
            // ----- bishop moves ------
            // -------------------------
            if (piece == BISHOP) {
                // TODO
            }

            // -------------------------
            // ----- queen moves -------
            // -------------------------
            if (piece == QUEEN) {
                // TODO
            }

        }

        sq_index += 1;
    };

    moves
}

// ------------------------------------------------------------
// ----------------- PAWN MOVE TESTS --------------------------
// ------------------------------------------------------------
#[test]
#[available_gas(999999999)]
fn test_white_pawn_push_home_row() {
    let pawn = array![
        EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY,
        EMPTY, EMPTY, PAWN, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY,
        EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY,
        EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY,
        EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY,
        EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY,
        EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY,
        EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY,
    ];
    let pawn_color = array![
        EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY,
        EMPTY, EMPTY, WHITE, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY,
        EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY,
        EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY,
        EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY,
        EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY,
        EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY,
        EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY,
    ];

    let pawn_board = Board { pieces: pawn, colors: pawn_color};

    let generated_moves = generate_moves(pawn_board, WHITE);

    assert(generated_moves.len() == 2, 'single and double push');
}

#[test]
#[available_gas(999999999)]
fn test_black_pawn_push_home_row() {
    let pawn = array![
        EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY,
        EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY,
        EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY,
        EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY,
        EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY,
        EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY,
        EMPTY, EMPTY, PAWN, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY,
        EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY,
    ];
    let pawn_color = array![
        EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY,
        EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY,
        EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY,
        EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY,
        EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY,
        EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY,
        EMPTY, EMPTY, BLACK, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY,
        EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY,
    ];

    let pawn_board = Board { pieces: pawn, colors: pawn_color};

    let generated_moves = generate_moves(pawn_board, BLACK);

    assert(generated_moves.len() == 2, 'single and double push');
}
