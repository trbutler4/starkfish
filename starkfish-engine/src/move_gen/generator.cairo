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
    // TODO: add logic for detecting checks 
    // TODO: add logic for detecting pins
    // TODO: add logic for pawn promotion
    // TODO: add logic for castling 
    // TODO: add logic for en-passant 
    
    // for storing moves
    let mut moves: Array<Move> = ArrayTrait::new();

    // TODO: store captures seperately?

    
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

            // TODO: optimize these --> this is really gross 


            if (piece == KNIGHT) {

                // board indexes
                //  56	57	58	59	60	61	62	63
                //  48	49	50	51	52	53	54	55
                //  40	41	42	43	44	45	46	47
                //  32	33	34	35	36	37	38	39
                //  24	25	26	27	28	29	30	31
                //  16	17	18	19	20	21	22	23
                //  08	09	10	11	12	13	14	15
                //  00	01	02	03	04	05	06	07

                // +15 _ _ +17
                //      |  
                // +6   |   + 10 
                // | -- K -- |
                // -10  |   - 6
                //     _|_ 
                // -17    -15

                // knight has all moves available 
                if (
                    rank > 1 && rank < 6 && 
                    file > 1 && file < 6
                ) {
                    moves.append(Move {
                        from: sq_index, to: sq_index + 15
                    });
                    moves.append(Move {
                        from: sq_index, to: sq_index + 17
                    });
                    moves.append(Move {
                        from: sq_index, to: sq_index + 6
                    });
                    moves.append(Move {
                        from: sq_index, to: sq_index + 10 
                    });
                    moves.append(Move {
                        from: sq_index, to: sq_index - 10 
                    });
                    moves.append(Move {
                        from: sq_index, to: sq_index - 6
                    });
                    moves.append(Move {
                        from: sq_index, to: sq_index - 17
                    });
                    moves.append(Move {
                        from: sq_index, to: sq_index - 15
                    });
                }
                else if ( 
                    // knight on a file
                    file == 0
                ) {
                    if (rank < 7) {
                        moves.append(Move {
                            from: sq_index, to: sq_index + 10
                        });
                    }
                    if ( rank < 6) {
                        moves.append(Move {
                            from: sq_index, to: sq_index + 17
                        });
                    }
                    if ( rank > 0) {
                        moves.append(Move {
                            from: sq_index, to: sq_index - 6
                        })
                    }
                    if ( rank > 1) {
                        moves.append(Move {
                            from: sq_index, to: sq_index - 15
                        })
                    }
                    
                }
                else if (
                    // knight on b file 
                    file == 1
                ) {
                    if ( rank > 1 && rank < 6) {
                        moves.append(Move {
                            from: sq_index, to: sq_index + 15 
                        });
                        moves.append(Move {
                            from: sq_index, to: sq_index + 17
                        });
                        moves.append(Move {
                            from: sq_index, to: sq_index + 10
                        });
                        moves.append(Move {
                            from: sq_index, to: sq_index - 6
                        });
                        moves.append(Move {
                            from: sq_index, to: sq_index - 17 
                        });
                        moves.append(Move {
                            from: sq_index, to: sq_index - 15
                        });
                    }
                    else if ( rank == 0) {
                        moves.append(Move {
                            from: sq_index, to: sq_index + 15
                        });
                        moves.append(Move {
                            from: sq_index, to: sq_index + 17    
                        });
                        moves.append(Move {
                            from: sq_index, to: sq_index + 10
                        });
                    }
                    else if ( rank == 1) {
                        moves.append(Move {
                            from: sq_index, to: sq_index + 15
                        });
                        moves.append(Move {
                            from: sq_index, to: sq_index + 17    
                        });
                        moves.append(Move {
                            from: sq_index, to: sq_index + 10
                        });
                        moves.append(Move {
                            from: sq_index, to: sq_index - 6
                        });
                    }
                    else if ( rank == 7) {
                        moves.append(Move {
                            from: sq_index, to: sq_index - 17
                        });
                        moves.append(Move {
                            from: sq_index, to: sq_index - 15
                        });
                        moves.append(Move {
                            from: sq_index, to: sq_index - 6
                        });
                    }
                    else if ( rank == 6) {
                        moves.append(Move {
                            from: sq_index, to: sq_index - 17
                        });
                        moves.append(Move {
                            from: sq_index, to: sq_index - 15
                        });
                        moves.append(Move {
                            from: sq_index, to: sq_index - 6
                        });
                        moves.append(Move {
                            from: sq_index, to: sq_index + 10 
                        });
                    }
                }
                else if ( 
                    // knight on g file 
                    file == 6
                ) {
                    if ( rank > 1 && rank < 6) {
                        moves.append(Move {
                            from: sq_index, to: sq_index + 15 
                        });
                        moves.append(Move {
                            from: sq_index, to: sq_index + 17
                        });
                        moves.append(Move {
                            from: sq_index, to: sq_index - 10
                        });
                        moves.append(Move {
                            from: sq_index, to: sq_index + 6
                        });
                        moves.append(Move {
                            from: sq_index, to: sq_index - 17 
                        });
                        moves.append(Move {
                            from: sq_index, to: sq_index - 15
                        });
                    }
                    else if ( rank == 0) {
                        moves.append(Move {
                            from: sq_index, to: sq_index + 15 
                        });
                        moves.append(Move {
                            from: sq_index, to: sq_index + 17
                        });
                        moves.append(Move {
                            from: sq_index, to: sq_index + 6
                        });
                    }
                    else if ( rank == 1) {
                        moves.append(Move {
                            from: sq_index, to: sq_index + 15 
                        });
                        moves.append(Move {
                            from: sq_index, to: sq_index + 17
                        });
                        moves.append(Move {
                            from: sq_index, to: sq_index + 6
                        });
                        moves.append(Move {
                            from: sq_index, to: sq_index - 10 
                        });
                    }
                    else if ( rank == 7) {
                        moves.append(Move {
                            from: sq_index, to: sq_index - 17 
                        });
                        moves.append(Move {
                            from: sq_index, to: sq_index - 15
                        });
                        moves.append(Move {
                            from: sq_index, to: sq_index - 10
                        });
                    }
                    else if ( rank == 6) {
                        moves.append(Move {
                            from: sq_index, to: sq_index - 17 
                        });
                        moves.append(Move {
                            from: sq_index, to: sq_index - 15
                        });
                        moves.append(Move {
                            from: sq_index, to: sq_index - 10
                        });
                        moves.append(Move {
                            from: sq_index, to: sq_index + 6
                        });
                    }
                }
                else if ( 
                    // knight on h file
                    file == 7
                ) {
                    if (rank < 7) {
                        moves.append(Move {
                            from: sq_index, to: sq_index + 6
                        });
                    }
                    if ( rank < 6) {
                        moves.append(Move {
                            from: sq_index, to: sq_index + 15
                        });
                    }
                    if ( rank > 0) {
                        moves.append(Move {
                            from: sq_index, to: sq_index - 10 
                        });
                    }
                    if ( rank > 1) {
                        moves.append(Move {
                            from: sq_index, to: sq_index - 17
                        });
                    }
                }


            }

            // -------------------------
            // ----- rook moves ------
            // -------------------------
            if (piece == ROOK) {
                let mut cur_index = sq_index;

                // calculate vertical targets
                loop {
                    if (get_rank_index(cur_index) >= 7) { break; }

                    cur_index += ONE_RANK;
                    moves.append(Move { from: sq_index, to: cur_index });
                };
                loop {
                    if (get_rank_index(cur_index) <= 0) { break; }

                    cur_index -= ONE_RANK;
                    moves.append(Move { from: sq_index, to: cur_index });
                };

                // calculate horizontal moves
                loop {
                    if (get_file_index(cur_index) >= 7) { break; }

                    cur_index += ONE_COL;
                    moves.append(Move { from: sq_index, to: cur_index });
                };
                loop {
                    // prevent sub overflow
                    if (get_file_index(cur_index) <= 0) { break; }

                    cur_index -= ONE_COL;
                    moves.append(Move { from: sq_index, to: cur_index });
                }
            }

            // -------------------------
            // ----- bishop moves ------
            // -------------------------
            if (piece == BISHOP) {
                let mut cur_index = sq_index;

                // calculate right diagonal targets
                loop {
                    cur_index += RIGHT_SINGLE_DIAG;
                    if (get_file_index(cur_index) > 7) { break; }
                    moves.append(Move { from: sq_index, to: cur_index });
                };

                // calculate left diagonal targets
                loop {
                    cur_index += LEFT_SINGLE_DIAG;
                    if (get_file_index(cur_index) < 0) { break; }
                    moves.append(Move { from: sq_index, to: cur_index });
                };
            }

            // -------------------------
            // ----- queen moves -------
            // -------------------------
            if (piece == QUEEN) {
                // TODO: currently just combining rook and bishop moves, this is
                // duplicated code and should be refactored 
                let mut cur_index = sq_index;

                // calculate vertical targets
                loop {
                    cur_index += ONE_RANK;
                    if (get_rank_index(cur_index) > 7) { break; }
                    moves.append(Move { from: sq_index, to: cur_index });
                };

                // calculate horizontal moves
                loop {
                    cur_index += ONE_COL;
                    if (get_file_index(cur_index) > 7) { break; }
                    moves.append(Move { from: sq_index, to: cur_index });
                };


                // calculate right diagonal targets
                loop {
                    cur_index += RIGHT_SINGLE_DIAG;
                    if (get_file_index(cur_index) > 7) { break; }
                    moves.append(Move { from: sq_index, to: cur_index });
                };

                // calculate left diagonal targets
                loop {
                    cur_index += LEFT_SINGLE_DIAG;
                    if (get_file_index(cur_index) < 0) { break; }
                    moves.append(Move { from: sq_index, to: cur_index });
                };
            }

        }

        sq_index += 1;
    };

    moves
}
