use debug::PrintTrait;
use starkfish::board::BoardImpl;
use starkfish::board::BoardTrait;

use starkfish::utils::shift_rank_up;
use starkfish::utils::shift_rank_down;
use starkfish::utils::shift_left;
use starkfish::utils::shift_right;


const RANK3: u64 =          0x0000000000ff0000;
const RANK4: u64 =          0x00000000ff000000;
const RANK5: u64 =          0x000000ff00000000;
const RANK6: u64 =          0x0000ff0000000000;

const NOT_A_FILE: u64 =     0xfefefefefefefefe;
const NOT_H_FILE: u64 =     0x7f7f7f7f7f7f7f7f;

// ---------------------------------------------------
// -------- PAWN MOVES -------------------------------
// ---------------------------------------------------
// https://www.chessprogramming.org/Pawn_Pattern_and_Properties

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

// TODO white pawn attacks 
// east side == king side
//  white pawns       white pawns << 9  &       notAFile     ==   wPawnEastAttacks
//  . . . . . . . .     . . . . . . . .      . 1 1 1 1 1 1 1      . . . . . . . . 
//  . . . . . . . .     . . . . . . . .      . 1 1 1 1 1 1 1      . . . . . . . . 
//  . . . . . . . .     . . . . . . . .      . 1 1 1 1 1 1 1      . . . . . . . . 
//  . . . . . . . .     . . . . . . . .      . 1 1 1 1 1 1 1      . . . . . . . . 
//  . . . . . . . .     h . . c . . . .      . 1 1 1 1 1 1 1      . . . c . . . . 
//  . . c . . . . .     . a b . d . f g      . 1 1 1 1 1 1 1      . a b . d . f g 
//  a b . d . f g h     . . . . . . . .      . 1 1 1 1 1 1 1      . . . . . . . . 
//  . . . . . . . .     / . . . . . . .      . 1 1 1 1 1 1 1      / . . . . . . .

fn white_pawn_ks_attacks(wpawns: u64) -> u64 {
    shift_left(wpawns, 9) & NOT_A_FILE
}

fn white_pawn_qs_attacks(wpawns: u64) -> u64 {
    shift_left(wpawns, 7) & NOT_H_FILE
}

fn white_pawn_all_attacks(wpawns: u64) -> u64 {
    white_pawn_ks_attacks(wpawns) | white_pawn_qs_attacks(wpawns)
}

fn white_pawn_double_attacks(wpawns: u64) -> u64 {
    white_pawn_ks_attacks(wpawns) & white_pawn_qs_attacks(wpawns)
}

fn white_pawn_single_attacks(wpawns: u64) -> u64 {
    white_pawn_ks_attacks(wpawns) ^ white_pawn_qs_attacks(wpawns)
}

fn black_pawn_single_push_targets(bpawns: u64, empty: u64) -> u64 {
    shift_rank_down(bpawns) & empty
}

// returns targets for moving all eligible pawns two forward
fn black_pawn_double_push_targets(bpawns: u64, empty: u64) -> u64 {
    let single_push = black_pawn_single_push_targets(bpawns, empty);
    shift_rank_down(single_push) & empty & RANK5
}

fn black_pawns_single_push_eligible(bpawns: u64, empty: u64) -> u64 {
    shift_rank_up(empty) & bpawns
}

fn black_pawns_double_push_eligible(bpawns: u64, empty: u64) -> u64 {
    let empty_rank6 = shift_rank_up(empty & RANK5) & empty;
    black_pawns_single_push_eligible(bpawns, empty_rank6)
}

fn black_pawn_qs_attacks(bpawns: u64) -> u64 {
    shift_right(bpawns, 9) & NOT_H_FILE
}

fn black_pawn_ks_attacks(bpawns: u64) -> u64 {
    shift_right(bpawns, 7) & NOT_A_FILE
}

fn black_pawn_all_attacks(bpawns: u64) -> u64 {
    black_pawn_ks_attacks(bpawns) | black_pawn_qs_attacks(bpawns)
}

fn black_pawn_double_attacks(bpawns: u64) -> u64 {
    black_pawn_ks_attacks(bpawns) & black_pawn_qs_attacks(bpawns)
}

fn black_pawn_single_attacks(bpawns: u64) -> u64 {
    black_pawn_ks_attacks(bpawns) ^ black_pawn_qs_attacks(bpawns)
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
#[available_gas(9999999)]
fn test_white_pawns_single_push_eligible() {
    // with new board 
    let mut new_board = BoardTrait::new();
    let pawns = new_board.white_pawns;
    let empty = new_board.empty_squares();
    assert(white_pawns_single_push_eligible(pawns, empty) == 0xff00, 'all pawns single push eligible')
}

#[test]
#[available_gas(99999999)]
fn test_white_pawns_double_push_eligble() {
    // with new board 
    let mut new_board = BoardTrait::new();
    let pawns = new_board.white_pawns;
    let empty = new_board.empty_squares();
    assert(white_pawns_double_push_eligible(pawns, empty) == 0xff00, 'all pawns double push eligible')
}

#[test]
#[available_gas(9999999)]
fn test_black_pawns_single_push_targets() {
    // with new board 
    let mut new_board = BoardTrait::new();
    let pawns = new_board.black_pawns;
    let empty = new_board.empty_squares();
    assert(black_pawn_single_push_targets(pawns, empty) == RANK6, 'all pawns can push up one')
}


#[test]
#[available_gas(9999999)]
fn test_black_pawns_double_push_targets() {
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

#[test]
#[available_gas(999999999)]
fn test_black_pawns_single_push_eligible() {
    let mut new_board = BoardTrait::new();
    let pawns = new_board.black_pawns;
    let empty = new_board.empty_squares();
    let eligible = black_pawns_single_push_eligible(pawns, empty);
    assert(eligible == 0xff000000000000, 'all pawns single push eligible')
}

#[test]
#[available_gas(9999999)]
fn test_black_pawns_double_push_eligible() {
    let mut new_board = BoardTrait::new();
    let pawns = new_board.black_pawns;
    let empty = new_board.empty_squares();
    let eligible = black_pawns_double_push_eligible(pawns, empty);
    assert(eligible == 0xff000000000000, 'all pawns double push eligible')
}

#[test]
#[available_gas(9999999)]
fn test_white_pawn_attacks() {
    let mut new_board = BoardTrait::new();
    let pawns = new_board.white_pawns;
    let ks_attacks = white_pawn_ks_attacks(pawns);
    let qs_attacks = white_pawn_qs_attacks(pawns);

    assert(ks_attacks == 0xfe0000, 'all can attack except a file');
    assert(qs_attacks == 0x7f0000, 'all can attack except h file');

    // diamond setup
    let pawns = 0x55aa00;
    let ks_attacks = white_pawn_ks_attacks(pawns);
    let qs_attacks = white_pawn_qs_attacks(pawns);

    assert(ks_attacks == 0xaa540000, 'failed diamond pawns');
    assert(qs_attacks == 0x2a550000, 'failed diamond pawns');

    //  white pawns       
    //  . . . . . . . .   
    //  . . . . . . . .   
    //  . . . . . . . .   
    //  . . . . . . . .   
    //  . . . . . . . .   
    //  . . c . . . . .   
    //  a b . d . f g h   
    //  . . . . . . . .   
    let pawns = 0x4eb00;
    let all_attacks = white_pawn_all_attacks(pawns);
    let single_attacks = white_pawn_single_attacks(pawns);
    let double_attacks = white_pawn_double_attacks(pawns);

    assert(all_attacks == 0xaf70000, 'failed all attack');
    assert(single_attacks == 0xaa30000, 'failed single attack');
    assert(double_attacks == 0x540000, 'failed double attack')
}

#[test]
#[available_gas(9999999)]
fn test_black_pawn_attacks() {
    let mut new_board = BoardTrait::new();
    let pawns = new_board.black_pawns;
    let ks_attacks = black_pawn_ks_attacks(pawns);
    let qs_attacks = black_pawn_qs_attacks(pawns);

    assert(ks_attacks == 0xfe0000000000, 'all can attack except a file');
    assert(qs_attacks == 0x7f0000000000, 'all can attack except h file');

    let pawns = 0xaa550000000000;
    let ks_attacks = black_pawn_ks_attacks(pawns);
    let qs_attacks = black_pawn_qs_attacks(pawns);

    assert(ks_attacks == 0x54aa00000000, 'ks wrong');
    assert(qs_attacks == 0x552a00000000, 'qs wrong');

    //  black pawns       
    //  . . . . . . . .   
    //  a b . d . f g h   
    //  . . c . . . . .   
    //  . . . . . . . .   
    //  . . . . . . . .   
    //  . . . . . . . .   
    //  . . . . . . . .   
    //  . . . . . . . .   
    let pawns = 0xeb040000000000;
    let all_attacks = black_pawn_all_attacks(pawns);
    let double_attacks = black_pawn_double_attacks(pawns);
    let single_attacks = black_pawn_single_attacks(pawns);

    assert(all_attacks == 0xf70a00000000, 'failed all attacks');
    assert(double_attacks == 0x540000000000, 'failed double attacks');
    assert(single_attacks == 0xa30a00000000, 'failed single attacks');

}


// ---------------------------------------------------
// -------- ROOK MOVE TESTS --------------------------
// ---------------------------------------------------

// ---------------------------------------------------
// -------- KNIGHT MOVE TESTS ------------------------
// ---------------------------------------------------

// ---------------------------------------------------
// -------- BISHOP MOVE TESTS ------------------------
// ---------------------------------------------------

// ---------------------------------------------------
// -------- QUEEN MOVE TESTS -------------------------
// ---------------------------------------------------

// ---------------------------------------------------
// -------- KING MOVE TESTS --------------------------
// ---------------------------------------------------
