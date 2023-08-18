
use starkfish::board::BoardImpl;
use starkfish::board::BoardTrait;

use starkfish::utils::shift_rank_up;
use starkfish::utils::shift_rank_down;


// https://www.chessprogramming.org/Pawn_Pushes_(Bitboards)

// ---------------------------------------------------
// -------- PAWN MOVES -------------------------------
// ---------------------------------------------------

// input is bitboard representing 1 - 8 pawns 
fn white_pawn_single_push_targets(w_pawns: u64, empty: u64) -> u64 {
    shift_rank_up(w_pawns) & empty
}


// ---------------------------------------------------
// -------- ROOK MOVES -------------------------------
// ---------------------------------------------------

// ---------------------------------------------------
// -------- KNIGHT MOVES -----------------------------
// ---------------------------------------------------

// ---------------------------------------------------
// -------- BISHOP MOVES -----------------------------
// ---------------------------------------------------

// ---------------------------------------------------
// -------- QUEEN MOVES ------------------------------
// ---------------------------------------------------

// ---------------------------------------------------
// -------- KING MOVES -------------------------------
// ---------------------------------------------------

// ---------------------------------------------------
// -------- PAWN MOVE TESTS --------------------------
// ---------------------------------------------------
#[test]
#[available_gas(9999999)]
fn test_white_pawn_single_push_targets() {
    // with new board 
    let mut new_board = BoardTrait::new();
    let pawns = new_board.white_pawns;
    let empty = new_board.empty_squares();
    assert(white_pawn_single_push_targets(pawns, empty) == 0xff0000, 'all pawns can push up one')
}

