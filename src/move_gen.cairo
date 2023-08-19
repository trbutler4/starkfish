use debug::PrintTrait;
use starkfish::board::BoardImpl;
use starkfish::board::BoardTrait;

use starkfish::utils::shift_rank_up;
use starkfish::utils::shift_rank_down;

const RANK3: u64 = 0x0000000000ff0000;
const RANK4: u64 = 0x00000000ff000000;
const RANK5: u64 = 0x000000ff00000000;
const RANK6: u64 = 0x0000ff0000000000;

// ---------------------------------------------------
// -------- PAWN MOVES -------------------------------
// ---------------------------------------------------
// https://www.chessprogramming.org/Pawn_Pushes_(Bitboards)

// returns target for moving all pawns one forward
// NOTE: currently will overflow at end of board
fn white_pawn_single_push_targets(wpawns: u64, empty: u64) -> u64 {
    shift_rank_up(wpawns) & empty
}

// returns targets for moving all eligible pawns two forward
fn white_pawn_double_push_targets(wpawns: u64, empty: u64) -> u64 {
    let single_push = white_pawn_single_push_targets(wpawns, empty);
    shift_rank_up(single_push) & empty & RANK4
}

fn white_pawns_single_push_eligible(wpawns: u64, empty: u64) -> u64 {
    shift_rank_down(empty) & wpawns
}

fn white_pawns_double_push_eligible(wpawns: u64, empty: u64) -> u64 {
    let empty_rank3 = shift_rank_down(empty & RANK4) & empty;
    white_pawns_single_push_eligible(wpawns, empty_rank3)
}

fn black_pawn_single_push_targets(bpawns: u64, empty: u64) -> u64 {
    shift_rank_down(bpawns) & empty
}

// returns targets for moving all eligible pawns two forward
fn black_pawn_double_push_targets(bpawns: u64, empty: u64) -> u64 {
    let single_push = black_pawn_single_push_targets(bpawns, empty);
    shift_rank_down(single_push) & empty & RANK5
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

#[test]
#[available_gas(9999999)]
fn test_white_pawn_double_push_targets() {
    let mut new_board = BoardTrait::new();
    let pawns = new_board.white_pawns;
    let empty = new_board.empty_squares();
    assert(white_pawn_double_push_targets(pawns, empty) == RANK4, 'all pawns can push twice');

    // some pawns already moved once
    let pawns = 0x55aa00;
    let target = white_pawn_double_push_targets(pawns, empty);
    assert(target == 0xaa000000, 'only eligible double pushes');
}

#[test]
fn test_white_pawns_single_push_eligible() {
    // with new board 
    let mut new_board = BoardTrait::new();
}

#[test]
#[available_gas(9999999)]
fn test_black_pawn_single_push_targets() {
    // with new board 
    let mut new_board = BoardTrait::new();
    let pawns = new_board.black_pawns;
    let empty = new_board.empty_squares();
    assert(black_pawn_single_push_targets(pawns, empty) == RANK6, 'all pawns can push up one')
}


#[test]
#[available_gas(9999999)]
fn test_black_pawn_double_push_targets() {
    let mut new_board = BoardTrait::new();
    let pawns = new_board.black_pawns;
    let empty = new_board.empty_squares();
    let target = black_pawn_double_push_targets(pawns, empty);
    assert(target == RANK5, 'all pawns can push twice');

    // some pawns already moved once
    let pawns = 0xaa550000000000;
    let target = black_pawn_double_push_targets(pawns, empty);
    assert(target == 0xaa00000000, 'only eligible double pushes');
}
