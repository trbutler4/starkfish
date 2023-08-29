use core::traits::Into;
use debug::PrintTrait;
use starkfish::board::BoardImpl;
use starkfish::board::BoardTrait;

use starkfish::utils::shift_rank_up;
use starkfish::utils::shift_rank_down;
use starkfish::utils::shift_left;
use starkfish::utils::shift_right;
use starkfish::utils::bitboard_shift_left;
use starkfish::utils::bitboard_shift_right;
use starkfish::utils::get_file_index;
use starkfish::utils::get_rank_index;


const RANK3: u64 = 0x0000000000ff0000;
const RANK4: u64 = 0x00000000ff000000;
const RANK5: u64 = 0x000000ff00000000;
const RANK6: u64 = 0x0000ff0000000000;

const NOT_A_FILE: u64 = 0xfefefefefefefefe;
const NOT_H_FILE: u64 = 0x7f7f7f7f7f7f7f7f;
const NOT_G_FILE: u64 = 0xbfbfbfbfbfbfbfbf;
const NOT_AB_FILE: u64 = 0xfcfcfcfcfcfcfcfc;
const NOT_GH_FILE: u64 = 0x3f3f3f3f3f3f3f3f;

const ONE: u64 = 0x0000000000000001;
const MAX: u64 = 0x8000000000000000;


// board layout 	
//  56	57	58	59	60	61	62	63
//  48	49	50	51	52	53	54	55
//  40	41	42	43	44	45	46	47
//  32	33	34	35	36	37	38	39
//  24	25	26	27	28	29	30	31
//  16	17	18	19	20	21	22	23
//  08	09	10	11	12	13	14	15
//  00	01	02	03	04	05	06	07

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

fn all_white_pawn_pushes(wpawns: u64, empty: u64) -> u64 {
    white_pawn_single_push_targets(wpawns, empty) | white_pawn_double_push_targets(wpawns, empty)
}

fn all_white_pawn_attacks(wpawns: u64) -> u64 {
    white_pawn_ks_attacks(wpawns) | white_pawn_qs_attacks(wpawns)
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

fn all_black_pawn_pushes(bpawns: u64, empty: u64) -> u64 {
    black_pawn_single_push_targets(bpawns, empty) | black_pawn_double_push_targets(bpawns, empty)
}

fn all_black_pawn_attacks(bpawns: u64) -> u64 {
    black_pawn_ks_attacks(bpawns) | black_pawn_qs_attacks(bpawns)
}

// ---------------------------------------------------
// -------- KNIGHT MOVES -----------------------------
// ---------------------------------------------------

//          noNoWe    noNoEa
//              +15  +17
//               |     |
//  noWeWe  +6 __|     |__+10  noEaEa
//                \   /
//                 >0<
//             __ /   \ __
//  soWeWe -10   |     |   -6  soEaEa
//               |     |
//              -17  -15
//          soSoWe    soSoEa

fn no_no_ea_knight_target(sq: u8) -> u64 {
    let mut res = bitboard_shift_left(ONE, sq);
    res = bitboard_shift_left( (res & NOT_H_FILE), 17);
    res 
}

fn no_ea_ea_knight_target(sq: u8) -> u64 {
    let mut res = bitboard_shift_left(ONE, sq);
    res = bitboard_shift_left( (res & NOT_GH_FILE), 10);
    res 
}

fn so_ea_ea_knight_target(sq: u8) -> u64 {
    let mut res = bitboard_shift_left(ONE, sq);
    res = bitboard_shift_right( (res & NOT_GH_FILE), 6);
    res 
}

fn so_so_ea_knight_target(sq: u8) -> u64 {
    let mut res = bitboard_shift_left(ONE, sq);
    res = bitboard_shift_right( (res & NOT_H_FILE), 15);
    res 
}

fn no_no_we_knight_target(sq: u8) -> u64 {
    let mut res = bitboard_shift_left(ONE, sq);
    res = bitboard_shift_left( (res & NOT_A_FILE), 15);
    res 
}

fn no_we_we_knight_target(sq: u8) -> u64 {
    let mut res = bitboard_shift_left(ONE, sq);
    res = bitboard_shift_left( (res & NOT_AB_FILE), 6);
    res 
}

fn so_we_we_knight_target(sq: u8) -> u64 {
    let mut res = bitboard_shift_left(ONE, sq);
    res = bitboard_shift_right( (res & NOT_AB_FILE), 10);
    res 
}

fn so_so_we_knight_target(sq: u8) -> u64 {
    let mut res = bitboard_shift_left(ONE, sq);
    res = bitboard_shift_right( (res & NOT_A_FILE), 17);
    res 
}

fn all_knight_targets(sq: u8) -> u64 {
    no_no_ea_knight_target(sq) |
    no_ea_ea_knight_target(sq) |
    so_ea_ea_knight_target(sq) |
    so_so_ea_knight_target(sq) |
    no_no_we_knight_target(sq) |
    no_we_we_knight_target(sq) |
    so_we_we_knight_target(sq) |
    so_so_we_knight_target(sq) 
}

// ---------------------------------------------------
// -------- ROOK MOVES -------------------------------
// ---------------------------------------------------

// board layout 	
//  56	57	58	59	60	61	62	63
//  48	49	50	51	52	53	54	55
//  40	41	42	43	44	45	46	47
//  32	33	34	35	36	37	38	39
//  24	25	26	27	28	29	30	31
//  16	17	18	19	20	21	22	23
//  08	09	10	11	12	13	14	15
//  00	01	02	03	04	05	06	07

fn north_sliding_targets(sq: u8) -> u64 {
    bitboard_shift_left(0x0101010101010100, sq)
}
fn south_sliding_targets(sq: u8) -> u64 {
    bitboard_shift_right(0x80808080808080, (sq ^ 63))
}
fn east_sliding_targets(sq: u8) -> u64 {
    2 * (shift_left(ONE, (sq | 7)) - shift_left(ONE, sq))
}
fn west_sliding_targets(sq: u8) -> u64 {
    shift_left(ONE, sq) - (shift_left(ONE, (sq & 56)))
}

fn rook_targets(sq: u8) -> u64 {
    north_sliding_targets(sq)
        | south_sliding_targets(sq)
        | east_sliding_targets(sq)
        | west_sliding_targets(sq)
}

// ---------------------------------------------------
// -------- BISHOP MOVES -----------------------------
// ---------------------------------------------------

// https://www.chessprogramming.org/Efficient_Generation_of_Sliding_Piece_Attacks

// probably better way to do this 
fn northeast_sliding_targets(sq: u8) -> u64 {
    let mut cur_sq = sq + 9;

    let mut res = 0x0; // blank for us to fill up with bits
    loop {
        if (cur_sq > 63) {
            break;
        }
        if (get_file_index(cur_sq - 9) == 7) {
            break;
        }
        res = res | bitboard_shift_left(ONE, cur_sq);
        cur_sq += 9;
    };

    res
}
fn northwest_sliding_targets(sq: u8) -> u64 {
    let mut cur_sq = sq + 7;

    let mut res = 0x0; // blank for us to fill up with bits
    loop {
        if (cur_sq > 63) {
            break;
        }
        if (get_file_index(cur_sq - 7) == 0) {
            break;
        }
        res = res | bitboard_shift_left(ONE, cur_sq);
        cur_sq += 7;
    };

    res
}
fn southeast_sliding_targets(sq: u8) -> u64 {
    let mut cur_sq = sq - 7;

    let mut res = 0x0;
    loop {
        if (cur_sq < 7) {
            break;
        }
        res = res | bitboard_shift_left(ONE, cur_sq);

        cur_sq -= 7;
    };
    res
}
fn southwest_sliding_targets(sq: u8) -> u64 {
    let mut cur_sq = sq - 9; // 

    let mut res = 0x0;
    loop {
        res = res | bitboard_shift_left(ONE, cur_sq);
        if (cur_sq < 9) {
            break;
        }

        cur_sq -= 9;
    };
    res
}

fn bishop_targets(sq: u8) -> u64 {
    northwest_sliding_targets(sq)
        | northeast_sliding_targets(sq)
        | southwest_sliding_targets(sq)
        | southeast_sliding_targets(sq)
}

// ---------------------------------------------------
// -------- QUEEN MOVES ------------------------------
// ---------------------------------------------------

// just use combination of rook and bishop targets 
fn queen_targets(sq: u8) -> u64 {
    bishop_targets(sq) | rook_targets(sq)
}


// ---------------------------------------------------
// -------- KING MOVES -------------------------------
// ---------------------------------------------------

fn king_targets(sq: u8) -> u64 {
    //
    //    northwest    north   northeast
    //    noWe         nort         noEa
    //
    //           +7    +8    +9
    //               \  |  /
    //   west    -1 <-  0 -> +1    east (king side)
    //  (queen       /  |  \
    //   side)   -9    -8    -7
    //
    //   soWe         sout         soEa
    //   southwest    south   southeast

    // Better way to do this than comparison?
    let mut res = 0x0;
    if (sq == 0_u8) { // A1
        res = res | bitboard_shift_left(ONE, sq + 1);
        res = res | bitboard_shift_left(ONE, sq + 8);
        res = res | bitboard_shift_left(ONE, sq + 9);
    } else if (sq == 7_u8) { // H1
        res = res | bitboard_shift_left(ONE, sq - 1);
        res = res | bitboard_shift_left(ONE, sq + 7);
        res = res | bitboard_shift_left(ONE, sq + 8);
    } else if (sq == 56_u8) { // NW corner 
        res = res | bitboard_shift_left(ONE, sq + 1);
        res = res | bitboard_shift_left(ONE, sq - 8);
        res = res | bitboard_shift_left(ONE, sq - 7);
    } else if (sq == 63_u8) { // NE corner
        res = res | bitboard_shift_left(ONE, sq - 1);
        res = res | bitboard_shift_left(ONE, sq - 8);
        res = res | bitboard_shift_left(ONE, sq - 9);
    } else if (get_file_index(sq) == 0) { // A file 
        res = res | bitboard_shift_left(ONE, sq + 1);
        res = res | bitboard_shift_left(ONE, sq - 7);
        res = res | bitboard_shift_left(ONE, sq + 9);
        res = res | bitboard_shift_left(ONE, sq - 8);
        res = res | bitboard_shift_left(ONE, sq + 8);
    } else if (get_file_index(sq) == 7) { // H file 
        res = res | bitboard_shift_left(ONE, sq - 1);
        res = res | bitboard_shift_left(ONE, sq - 8);
        res = res | bitboard_shift_left(ONE, sq + 8);
        res = res | bitboard_shift_left(ONE, sq - 9);
        res = res | bitboard_shift_left(ONE, sq + 7);
    } else if (get_rank_index(sq) == 0) { // rank 1 
        res = res | bitboard_shift_left(ONE, sq - 1);
        res = res | bitboard_shift_left(ONE, sq + 1);
        res = res | bitboard_shift_left(ONE, sq + 7);
        res = res | bitboard_shift_left(ONE, sq + 8);
        res = res | bitboard_shift_left(ONE, sq + 9);
    } else if (get_rank_index(sq) == 7) { // rank 8 
        res = res | bitboard_shift_left(ONE, sq - 1);
        res = res | bitboard_shift_left(ONE, sq + 1);
        res = res | bitboard_shift_left(ONE, sq - 8);
        res = res | bitboard_shift_left(ONE, sq - 9);
        res = res | bitboard_shift_left(ONE, sq - 7);
    } else {
        res = res | bitboard_shift_left(ONE, sq + 1);
        res = res | bitboard_shift_left(ONE, sq - 1);
        res = res | bitboard_shift_left(ONE, sq - 7);
        res = res | bitboard_shift_left(ONE, sq + 7);
        res = res | bitboard_shift_left(ONE, sq - 8);
        res = res | bitboard_shift_left(ONE, sq + 8);
        res = res | bitboard_shift_left(ONE, sq - 9);
        res = res | bitboard_shift_left(ONE, sq + 9);
    }
    res
}


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
fn test_all_white_pawn_pushes() {
    let mut new_board = BoardTrait::new();
    let pawns = new_board.white_pawns;
    let empty = new_board.empty_squares();
    assert(all_white_pawn_pushes(pawns, empty) == 0xffff0000, 'new board')
}

#[test]
#[available_gas(9999999)]
fn test_all_white_pawn_attacks() {
    let mut new_board = BoardTrait::new();
    let pawns = new_board.white_pawns;
    assert(all_white_pawn_attacks(pawns) == 0xff0000, 'new board')
}

#[test]
#[available_gas(9999999)]
fn test_white_pawns_single_push_eligible() {
    // with new board 
    let mut new_board = BoardTrait::new();
    let pawns = new_board.white_pawns;
    let empty = new_board.empty_squares();
    assert(
        white_pawns_single_push_eligible(pawns, empty) == 0xff00, 'all pawns single push eligible'
    )
}

#[test]
#[available_gas(99999999)]
fn test_white_pawns_double_push_eligble() {
    // with new board 
    let mut new_board = BoardTrait::new();
    let pawns = new_board.white_pawns;
    let empty = new_board.empty_squares();
    assert(
        white_pawns_double_push_eligible(pawns, empty) == 0xff00, 'all pawns double push eligible'
    )
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

#[test]
#[available_gas(9999999)]
fn test_all_black_pawn_pushes() {
    let mut new_board = BoardTrait::new();
    let pawns = new_board.black_pawns;
    let empty = new_board.empty_squares();
    assert(all_black_pawn_pushes(pawns, empty) == 0xffff00000000, 'new board');
}

#[test]
#[available_gas(9999999)]
fn test_all_black_pawn_attacks() {
    let mut new_board = BoardTrait::new();
    let pawns = new_board.black_pawns;
    assert(all_black_pawn_attacks(pawns) == 0xff0000000000, 'new board');
}


// ---------------------------------------------------
// -------- KNIGHT MOVE TESTS ------------------------
// ---------------------------------------------------
#[test]
#[available_gas(9999999)]
fn test_no_no_ea_knight_target() {
    //  8 . . . . . . . .   
    //  7 . . . . 1 . . .   
    //  6 . . . . . . . .   
    //  5 . . . K . . . .   
    //  4 . . . . . . . .   
    //  3 . . . . . . . .   
    //  2 . . . . . . . .   
    //  1 . . . . . . . .   
    //    a b c d e f g h
    let sq = 35_u8;
    let target = no_no_ea_knight_target(sq);
    assert(target == 0x10000000000000, 'knight on d5');

    //  8 . . . . . . . .   
    //  7 . . . . . . . .   
    //  6 . . . . . . . .   
    //  5 . . . . . . . .   
    //  4 . . . . . . . .   
    //  3 . . . . . . . K   
    //  2 . . . . . . . .   
    //  1 . . . . . . . .   
    //    a b c d e f g h
    let sq = 23_u8;
    let target = no_no_ea_knight_target(sq);
    assert(target == 0x0, 'knight on h file');
}


#[test]
#[available_gas(9999999)]
fn test_no_ea_ea_knight_target() {
    //  8 . . . . . . . .   
    //  7 . . . . . . . .   
    //  6 . . . . . 1 . .   
    //  5 . . . K . . . .   
    //  4 . . . . . . . .   
    //  3 . . . . . . . .   
    //  2 . . . . . . . .   
    //  1 . . . . . . . .   
    //    a b c d e f g h
    let sq = 35_u8;
    let target = no_ea_ea_knight_target(sq);
    assert(target == 0x200000000000, 'knight on d5');

    //  8 . . . . . . . .   
    //  7 . . . . . . . .   
    //  6 . . . . . . . .   
    //  5 . . . . . . . .   
    //  4 . . . . . . K .   
    //  3 . . . . . . . .   
    //  2 . . . . . . . .   
    //  1 . . . . . . . .   
    //    a b c d e f g h
    let sq = 30_u8;
    let target = no_ea_ea_knight_target(sq);
    assert(target == 0x0, 'knight on g file');
}

#[test]
#[available_gas(9999999)]
fn test_so_ea_ea_knight_target() {
    //  8 . . . . . . . .   
    //  7 . . . . . . . .   
    //  6 . . . . . . . .   
    //  5 . . . K . . . .   
    //  4 . . . . . 1 . .   
    //  3 . . . . . . . .   
    //  2 . . . . . . . .   
    //  1 . . . . . . . .   
    //    a b c d e f g h
    let sq = 35_u8;
    let target = so_ea_ea_knight_target(sq);
    assert(target == 0x20000000, 'knight on d5');

    //  8 . . . . . . . .   
    //  7 . . . . . . . .   
    //  6 . . . . . . . .   
    //  5 . . . . . . . .   
    //  4 . . . . . . K .   
    //  3 . . . . . . . .   
    //  2 . . . . . . . .   
    //  1 . . . . . . . .   
    //    a b c d e f g h
    let sq = 30_u8;
    let target = no_ea_ea_knight_target(sq);
    assert(target == 0x0, 'knight on g file');
}

#[test]
#[available_gas(9999999)]
fn test_so_so_ea_knight_target() {
    //  8 . . . . . . . .   
    //  7 . . . . . . . .   
    //  6 . . . . . . . .   
    //  5 . . . K . . . .   
    //  4 . . . . . . . .   
    //  3 . . . . 1 . . .   
    //  2 . . . . . . . .   
    //  1 . . . . . . . .   
    //    a b c d e f g h
    let sq = 35_u8;
    let target = so_so_ea_knight_target(sq);
    assert(target == 0x100000, 'knight on d5');

    //  8 . . . . . . . .   
    //  7 . . . . . . . .   
    //  6 . . . . . . . .   
    //  5 . . . . . . . .   
    //  4 . . . . . . . K   
    //  3 . . . . . . . .   
    //  2 . . . . . . . .   
    //  1 . . . . . . . .   
    //    a b c d e f g h
    let sq = 31_u8;
    let target = so_so_ea_knight_target(sq);
    assert(target == 0x0, 'knight on h file');
}

#[test]
#[available_gas(9999999)]
fn test_no_no_we_knight_target() {
    //  8 . . . . . . . .   
    //  7 . . 1 . . . . .   
    //  6 . . . . . . . .   
    //  5 . . . K . . . .   
    //  4 . . . . . . . .   
    //  3 . . . . . . . .   
    //  2 . . . . . . . .   
    //  1 . . . . . . . .   
    //    a b c d e f g h
    let sq = 35_u8;
    let target = no_no_we_knight_target(sq);
    assert(target == 0x4000000000000, 'knight on d5');

    //  8 . . . . . . . .   
    //  7 . . . . . . . .   
    //  6 . . . . . . . .   
    //  5 . . . . . . . .   
    //  4 K . . . . . . .   
    //  3 . . . . . . . .   
    //  2 . . . . . . . .   
    //  1 . . . . . . . .   
    //    a b c d e f g h
    let sq = 24_u8;
    let target = no_no_we_knight_target(sq);
    assert(target == 0x0, 'knight on A file');
}

#[test]
#[available_gas(9999999)]
fn test_no_we_we_knight_target() {
    //  8 . . . . . . . .   
    //  7 . . . . . . . .   
    //  6 . 1 . . . . . .   
    //  5 . . . K . . . .   
    //  4 . . . . . . . .   
    //  3 . . . . . . . .   
    //  2 . . . . . . . .   
    //  1 . . . . . . . .   
    //    a b c d e f g h
    let sq = 35_u8;
    let target = no_we_we_knight_target(sq);
    assert(target == 0x20000000000, 'knight on d5');

    //  8 . . . . . . . .   
    //  7 . . . . . . . .   
    //  6 . . . . . . . .   
    //  5 . . . . . . . .   
    //  4 K . . . . . . .   
    //  3 . . . . . . . .   
    //  2 . . . . . . . .   
    //  1 . . . . . . . .   
    //    a b c d e f g h
    let sq = 24_u8;
    let target = no_we_we_knight_target(sq);
    assert(target == 0x0, 'knight on A file');

    //  8 . . . . . . . .   
    //  7 . . . . . . . .   
    //  6 . . . . . . . .   
    //  5 . . . . . . . .   
    //  4 . K . . . . . .   
    //  3 . . . . . . . .   
    //  2 . . . . . . . .   
    //  1 . . . . . . . .   
    //    a b c d e f g h
    let sq = 25_u8;
    let target = no_we_we_knight_target(sq);
    assert(target == 0x0, 'knight on A file');
}


#[test]
#[available_gas(9999999)]
fn test_so_we_we_knight_target() {
    //  8 . . . . . . . .   
    //  7 . . . . . . . .   
    //  6 . . . . . . . .   
    //  5 . . . K . . . .   
    //  4 . 1 . . . . . .   
    //  3 . . . . . . . .   
    //  2 . . . . . . . .   
    //  1 . . . . . . . .   
    //    a b c d e f g h
    let sq = 35_u8;
    let target = so_we_we_knight_target(sq);
    assert(target == 0x2000000, 'knight on d5');

    //  8 . . . . . . . .   
    //  7 . . . . . . . .   
    //  6 . . . . . . . .   
    //  5 . . . . . . . .   
    //  4 K . . . . . . .   
    //  3 . . . . . . . .   
    //  2 . . . . . . . .   
    //  1 . . . . . . . .   
    //    a b c d e f g h
    let sq = 24_u8;
    let target = so_we_we_knight_target(sq);
    assert(target == 0x0, 'knight on A file');

    //  8 . . . . . . . .   
    //  7 . . . . . . . .   
    //  6 . . . . . . . .   
    //  5 . . . . . . . .   
    //  4 . K . . . . . .   
    //  3 . . . . . . . .   
    //  2 . . . . . . . .   
    //  1 . . . . . . . .   
    //    a b c d e f g h
    let sq = 25_u8;
    let target = so_we_we_knight_target(sq);
    assert(target == 0x0, 'knight on A file');
}

#[test]
#[available_gas(9999999)]
fn test_so_so_we_knight_target() {
    //  8 . . . . . . . .   
    //  7 . . . . . . . .   
    //  6 . . . . . . . .   
    //  5 . . . K . . . .   
    //  4 . . . . . . . .   
    //  3 . . 1 . . . . .   
    //  2 . . . . . . . .   
    //  1 . . . . . . . .   
    //    a b c d e f g h
    let sq = 35_u8;
    let target = so_so_we_knight_target(sq);
    assert(target == 0x40000, 'knight on d5');

    //  8 . . . . . . . .   
    //  7 . . . . . . . .   
    //  6 . . . . . . . .   
    //  5 . . . . . . . .   
    //  4 . . . . . . . .   
    //  3 . . . . . . . .   
    //  2 K . . . . . . .   
    //  1 . . . . . . . .   
    //    a b c d e f g h
    let sq = 8_u8;
    let target = so_so_we_knight_target(sq);
    assert(target == 0x0, 'knight on A file');
}

#[test]
#[available_gas(999999999)]
fn test_knight_moves() {
    //  8 . . . . . . . .   
    //  7 . . 1 . 1 . . .   
    //  6 . 1 . . . 1 . .   
    //  5 . . . K . . . .   
    //  4 . 1 . . . 1 . .   
    //  3 . . 1 . 1 . . .   
    //  2 . . . . . . . .   
    //  1 . . . . . . . .   
    //    a b c d e f g h
    let sq = 35_u8; 
    let targets = all_knight_targets(sq);
    assert(targets == 0x14220022140000, 'knight on d5');

    //  8 . . . . . . . .   
    //  7 . . . . . . . .   
    //  6 . . . . . . . .   
    //  5 . . . . . . . .   
    //  4 . . . . . . . .   
    //  3 . 1 . . . . . .   
    //  2 . . 1 . . . . .   
    //  1 K . . . . . . .   
    //    a b c d e f g h
    let sq = 0_u8; 
    let targets = all_knight_targets(sq);
    assert(targets == 0x20400, 'knight on a1');

    //  8 . . . . . . . .   
    //  7 . . . . . . . .   
    //  6 . . . . . . . .   
    //  5 . . . . . . . .   
    //  4 . . . . . . . .   
    //  3 . . . . . . 1 .   
    //  2 . . . . . 1 . .   
    //  1 . . . . . . . K   
    //    a b c d e f g h
    let sq = 7_u8;
    let targets = all_knight_targets(sq);
    targets.print();
    assert(targets == 0x402000, 'knight on h1');

    //  8 K . . . . . . .   
    //  7 . . 1 . . . . .   
    //  6 . 1 . . . . . .   
    //  5 . . . . . . . .   
    //  4 . . . . . . . .   
    //  3 . . . . . . . .   
    //  2 . . . . . . . .   
    //  1 . . . . . . . .   
    //    a b c d e f g h

    //  8 . . . . . . . K   
    //  7 . . . . . 1 . .   
    //  6 . . . . . . 1 .   
    //  5 . . . . . . . .   
    //  4 . . . . . . . .   
    //  3 . . . . . . . .   
    //  2 . . . . . . . .   
    //  1 . . . . . . . .   
    //    a b c d e f g h
}

// ---------------------------------------------------
// -------- ROOK MOVE TESTS --------------------------
// ---------------------------------------------------

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

#[test]
#[available_gas(9999999)]
fn test_north_sliding_targets() {
    //  8 . . . 1 . . . .   
    //  7 . . . 1 . . . .   
    //  6 . . . 1 . . . .   
    //  5 . . . R . . . .   
    //  4 . . . . . . . .   
    //  3 . . . . . . . .   
    //  2 . . . . . . . .   
    //  1 . . . . . . . .   
    //    a b c d e f g h
    let sq = 35_u8; // D5
    let targets = north_sliding_targets(sq);
    assert(targets == 0x808080000000000, '');
}

#[test]
#[available_gas(9999999)]
fn test_south_sliding_targets() {
    //  8 . . . . . . . .   
    //  7 . . . . . . . .   
    //  6 . . . . . . . .   
    //  5 . . . R . . . .   
    //  4 . . . 1 . . . .   
    //  3 . . . 1 . . . .   
    //  2 . . . 1 . . . .   
    //  1 . . . 1 . . . .   
    //    a b c d e f g h
    let sq = 35_u8; // D5
    let targets = south_sliding_targets(sq);
    assert(targets == 0x8080808, 'rook on d5');

    //  8 . . . . . . . R   
    //  7 . . . . . . . 1   
    //  6 . . . . . . . 1   
    //  5 . . . . . . . 1   
    //  4 . . . . . . . 1   
    //  3 . . . . . . . 1   
    //  2 . . . . . . . 1   
    //  1 . . . . . . . 1   
    //    a b c d e f g h
    let sq = 63_u8; // D5
    let targets = south_sliding_targets(sq);
    assert(targets == 0x80808080808080, 'rook on h8');
}

#[test]
#[available_gas(9999999)]
fn test_east_sliding_targets() {
    //  8 . . . . . . . .   
    //  7 . . . . . . . .   
    //  6 . . . . . . . .   
    //  5 . . . R 1 1 1 1   
    //  4 . . . . . . . .   
    //  3 . . . . . . . .   
    //  2 . . . . . . . .   
    //  1 . . . . . . . .   
    //    a b c d e f g h
    let sq = 35_u8; // D5
    let targets = east_sliding_targets(sq);
    assert(targets == 0xf000000000, 'rook on d5');

    //  8 R 1 1 1 1 1 1 1   
    //  7 . . . . . . . .   
    //  6 . . . . . . . .   
    //  5 . . . . . . . .   
    //  4 . . . . . . . .   
    //  3 . . . . . . . .   
    //  2 . . . . . . . .   
    //  1 . . . . . . . .   
    //    a b c d e f g h
    let sq = 56_u8; // A8
    let targets = east_sliding_targets(sq);
    assert(targets == 0xfe00000000000000, 'rook on a8')
}

#[test]
#[available_gas(9999999)]
fn test_west_sliding_targets() {
    //  8 . . . . . . . .   
    //  7 . . . . . . . .   
    //  6 . . . . . . . .   
    //  5 1 1 1 R . . . .   
    //  4 . . . . . . . .   
    //  3 . . . . . . . .   
    //  2 . . . . . . . .   
    //  1 . . . . . . . .   
    //      a b c d e f g h
    let sq = 35_u8; // D5
    let targets = west_sliding_targets(sq);
    assert(targets == 0x700000000, 'rook on d5');

    //  8 1 1 1 1 1 1 1 R   
    //  7 . . . . . . . .   
    //  6 . . . . . . . .   
    //  5 . . . . . . . .   
    //  4 . . . . . . . .   
    //  3 . . . . . . . .   
    //  2 . . . . . . . .   
    //  1 . . . . . . . .   
    //    a b c d e f g h
    let sq = 63_u8; // h8
    let targets = west_sliding_targets(sq);
    assert(targets == 0x7f00000000000000, 'rook on h8');
}

#[test]
#[available_gas(9999999)]
fn test_rook_targets() {
    //  8 . . . 1 . . . .   
    //  7 . . . 1 . . . .   
    //  6 . . . 1 . . . .   
    //  5 1 1 1 R 1 1 1 1   
    //  4 . . . 1 . . . .   
    //  3 . . . 1 . . . .   
    //  2 . . . 1 . . . .   
    //  1 . . . 1 . . . .   
    //    a b c d e f g h
    let sq = 35_u8; // D5
    let targets = rook_targets(sq);
    assert(targets == 0x80808f708080808, 'rook on d5');

    //  8 . 1 . . . . . .   
    //  7 . 1 . . . . . .   
    //  6 . 1 . . . . . .   
    //  5 . 1 . . . . . .   
    //  4 . 1 . . . . . .   
    //  3 . 1 . . . . . .   
    //  2 1 R 1 1 1 1 1 1   
    //  1 . 1 . . . . . .   
    //    a b c d e f g h
    let sq = 9_u8; // B2
    let targets = rook_targets(sq);
    assert(targets == 0x20202020202fd02, 'rook on b2')
}


// ---------------------------------------------------
// -------- BISHOP MOVE TESTS ------------------------
// ---------------------------------------------------

#[test]
#[available_gas(9999999)]
fn test_northeast_sliding_targets() {
    //  8 . . . . . . 1 .   
    //  7 . . . . . 1 . .   
    //  6 . . . . 1 . . .   
    //  5 . . . B . . . .   
    //  4 . . . . . . . .   
    //  3 . . . . . . . .   
    //  2 . . . . . . . .   
    //  1 . . . . . . . .   
    //    a b c d e f g h
    let sq = 35_u8;
    let targets = northeast_sliding_targets(sq);
    assert(targets == 0x4020100000000000, 'bishop on d5');

    //  8 . . . . . . . .   
    //  7 . . . . . . . .   
    //  6 . . . . . . . 1   
    //  5 . . . . . . 1 .   
    //  4 . . . . . 1 . .   
    //  3 . . . . 1 . . .   
    //  2 . . . B . . . .   
    //  1 . . . . . . . .   
    //    a b c d e f g h
    let sq = 11_u8; // d2
    let targets = northeast_sliding_targets(sq);
    assert(targets == 0x804020100000, 'bishop on d2');

    //  8 . . . . . . . 1   
    //  7 . . . . . . 1 .   
    //  6 . . . . . 1 . .   
    //  5 . . . . 1 . . .   
    //  4 . . . 1 . . . .   
    //  3 . . 1 . . . . .   
    //  2 . 1 . . . . . .   
    //  1 B . . . . . . .   
    //    a b c d e f g h
    let sq = 0_u8;
    let targets = northeast_sliding_targets(sq);
    assert(targets == 0x8040201008040200, 'bishop on a1');

    //  8 . . . . . . . .   
    //  7 . . . . . . . .   
    //  6 . . . . . . . .   
    //  5 . . . . . . . .   
    //  4 . . . . . . . .   
    //  3 . . . . . . . .   
    //  2 . . . . . . . .   
    //  1 . . . . . . . .   
    //    a b c d e f g h2040810204080
    let sq = 63_u8;
    let targets = northeast_sliding_targets(sq);
    assert(targets == 0x0, 'bishop on h8');
}

#[test]
#[available_gas(9999999)]
fn test_northwest_sliding_targets() {
    //  8 1 . . . . . . .   
    //  7 . 1 . . . . . .   
    //  6 . . 1 . . . . .   
    //  5 . . . B . . . .   
    //  4 . . . . . . . .   
    //  3 . . . . . . . .   
    //  2 . . . . . . . .   
    //  1 . . . . . . . .   
    //    a b c d e f g h
    let sq = 35_u8;
    let targets = northwest_sliding_targets(sq);
    assert(targets == 0x102040000000000, 'bishop on d5');

    //  8 . . . . . . . .   
    //  7 . . . . . . . .   
    //  6 . . . . . . . .   
    //  5 1 . . . . . . .   
    //  4 . 1 . . . . . .   
    //  3 . . 1 . . . . .   
    //  2 . . . B . . . .   
    //  1 . . . . . . . .   
    //    a b c d e f g h
    let sq = 11_u8;
    let targets = northwest_sliding_targets(sq);
    assert(targets == 0x102040000, 'bishop on d2');

    //  8 1 . . . . . . .   
    //  7 . 1 . . . . . .   
    //  6 . . 1 . . . . .   
    //  5 . . . 1 . . . .   
    //  4 . . . . 1 . . .   
    //  3 . . . . . 1 . .   
    //  2 . . . . . . 1 .   
    //  1 . . . . . . . B   
    //    a b c d e f g h
    let sq = 7_u8;
    let targets = northwest_sliding_targets(sq);
    assert(targets == 0x102040810204000, 'bishop on h1')
}

#[test]
#[available_gas(9999999)]
fn test_southwest_sliding_targets() {
    //  8 . . . . . . . .   
    //  7 . . . . . . . .   
    //  6 . . . . . . . .   
    //  5 . . . B . . . .   
    //  4 . . 1 . . . . .   
    //  3 . 1 . . . . . .   
    //  2 1 . . . . . . .   
    //  1 . . . . . . . .   
    //    a b c d e f g h
    let sq = 35_u8;
    let targets = southwest_sliding_targets(sq);
    assert(targets == 0x4020100, 'bishop on d5');

    //  8 . . . . . . . B   
    //  7 . . . . . . 1 .   
    //  6 . . . . . 1 . .   
    //  5 . . . . 1 . . .   
    //  4 . . . 1 . . . .   
    //  3 . . 1 . . . . .   
    //  2 . 1 . . . . . .   
    //  1 1 . . . . . . .   
    //    a b c d e f g h
    let sq = 63_u8;
    let targets = southwest_sliding_targets(sq);
    assert(targets == 0x40201008040201, 'bishop on h8');

    //  8 . . . . . . . .   
    //  7 . . . . . . . .   
    //  6 . . . . . . . .   
    //  5 . . . . . . . .   
    //  4 . . . . . . . .   
    //  3 . . . . . . B .   
    //  2 . . . . . 1 . .   
    //  1 . . . . 1 . . .   
    //    a b c d e f g h
    let sq = 22_u8;
    let targets = southwest_sliding_targets(sq);
    assert(targets == 0x2010, 'bishop on g3');
}

#[test]
#[available_gas(9999999)]
fn test_southeast_sliding_targets() {
    //  8 . . . . . . . .   
    //  7 . . . . . . . .   
    //  6 . . . . . . . .   
    //  5 . . . B . . . .   
    //  4 . . . . 1 . . .   
    //  3 . . . . . 1 . .   
    //  2 . . . . . . 1 .   
    //  1 . . . . . . . 1   
    //    a b c d e f g h
    let sq = 35_u8;
    let targets = southeast_sliding_targets(sq);
    assert(targets == 0x10204080, 'bishop on d5');

    //  8 B . . . . . . .   
    //  7 . 1 . . . . . .   
    //  6 . . 1 . . . . .   
    //  5 . . . 1 . . . .   
    //  4 . . . . 1 . . .   
    //  3 . . . . . 1 . .   
    //  2 . . . . . . 1 .   
    //  1 . . . . . . . 1   
    //    a b c d e f g h
    let sq = 56_u8;
    let targets = southeast_sliding_targets(sq);
    assert(targets == 0x2040810204080, 'bishop on a8')
}

#[test]
#[available_gas(9999999)]
fn test_bishop_targets() {
    //  8 1 . . . . . 1 .   
    //  7 . 1 . . . 1 . .   
    //  6 . . 1 . 1 . . .   
    //  5 . . . B . . . .   
    //  4 . . 1 . 1 . . .   
    //  3 . 1 . . . 1 . .   
    //  2 1 . . . . . 1 .   
    //  1 . . . . . . . 1   
    //    a b c d e f g h
    let sq = 35_u8;
    let targets = bishop_targets(sq);
    assert(targets == 0x4122140014224180, 'bishop on d5');
}

// ---------------------------------------------------
// -------- QUEEN MOVE TESTS -------------------------
// ---------------------------------------------------

#[test]
#[available_gas(9999999)]
fn test_queen_targets() {
    //  8 1 . . 1 . . 1 .   
    //  7 . 1 . 1 . 1 . .   
    //  6 . . 1 1 1 . . .   
    //  5 1 1 1 B 1 1 1 1   
    //  4 . . 1 1 1 . . .   
    //  3 . 1 . 1 . 1 . .   
    //  2 1 . . 1 . . 1 .   
    //  1 . . . 1 . . . 1   
    //    a b c d e f g h
    let sq = 35_u8;
    let targets = queen_targets(sq);
    assert(targets == 0x492a1cf71c2a4988, 'queen on d5');
}


// ---------------------------------------------------
// -------- KING MOVE TESTS --------------------------
// ---------------------------------------------------

#[test]
#[available_gas(99999999999)]
fn test_king_moves() {
    //  8 . . . . . . . .   
    //  7 . . . . . . . .   
    //  6 . . 1 1 1 . . .   
    //  5 . . 1 B 1 . . .   
    //  4 . . 1 1 1 . . .   
    //  3 . . . . . . . .   
    //  2 . . . . . . . .   
    //  1 . . . . . . . .   
    //    a b c d e f g h
    let sq = 35_u8;
    let targets = king_targets(sq);
    assert(targets == 0x1c141c000000, 'king on d5');

    //  8 . . . . . . . .   
    //  7 . . . . . . . .   
    //  6 . . . . . . . .   
    //  5 . . . . . . . .   
    //  4 . . . . . . . .   
    //  3 . . . . . . . .   
    //  2 1 1 . . . . . .   
    //  1 K 1 . . . . . .   
    //    a b c d e f g h
    let sq = 0_u8;
    let targets = king_targets(sq);
    assert(targets == 0x302, 'king on a1');

    //  8 . . . . . . . .   
    //  7 . . . . . . . .   
    //  6 . . . . . . . .   
    //  5 . . . . . . . .   
    //  4 . . . . . . . .   
    //  3 . . . . . . . .   
    //  2 . . . . . . 1 1   
    //  1 . . . . . . 1 K   
    //    a b c d e f g h
    let sq = 7_u8;
    let targets = king_targets(sq);
    assert(targets == 0xc040, 'king on h1');

    //  8 K 1 . . . . . .   
    //  7 1 1 . . . . . .   
    //  6 . . . . . . . .   
    //  5 . . . . . . . .   
    //  4 . . . . . . . .   
    //  3 . . . . . . . .   
    //  2 . . . . . . . .   
    //  1 . . . . . . . .   
    //    a b c d e f g h
    let sq = 56_u8;
    let targets = king_targets(sq);
    assert(targets == 0x203000000000000, 'king on a8');

    //  8 . . . . . . 1 K   
    //  7 . . . . . . 1 1   
    //  6 . . . . . . . .   
    //  5 . . . . . . . .   
    //  4 . . . . . . . .   
    //  3 . . . . . . . .   
    //  2 . . . . . . . .   
    //  1 . . . . . . . .   
    //    a b c d e f g h
    let sq = 63_u8;
    let targets = king_targets(sq);
    assert(targets == 0x40c0000000000000, 'king on h8');

    //  8 . . . . . . . .   
    //  7 . . . . . . . .   
    //  6 1 1 . . . . . .   
    //  5 K 1 . . . . . .   
    //  4 1 1 . . . . . .   
    //  3 . . . . . . . .   
    //  2 . . . . . . . .   
    //  1 . . . . . . . .   
    //    a b c d e f g h
    let sq = 32_u8;
    let targets = king_targets(sq);
    assert(targets == 0x30203000000, 'king on A file (a5)');

    //  8 . . . . . . . .   
    //  7 . . . . . . . .   
    //  6 . . . . . . 1 1   
    //  5 . . . . . . 1 K   
    //  4 . . . . . . 1 1   
    //  3 . . . . . . . .   
    //  2 . . . . . . . .   
    //  1 . . . . . . . .   
    //    a b c d e f g h
    let sq = 39_u8;
    let targets = king_targets(sq);
    assert(targets == 0xc040c0000000, 'king on H file (h5)');

    //  8 . . . . . . . .   
    //  7 . . . . . . . .   
    //  6 . . . . . . . .   
    //  5 . . . . . . . .   
    //  4 . . . . . . . .   
    //  3 . . . . . . . .   
    //  2 . . 1 1 1 . . .   
    //  1 . . 1 K 1 . . .   
    //    a b c d e f g h
    let sq = 3_u8;
    let targets = king_targets(sq);
    assert(targets == 0x1c14, 'king on 1st rank (d1)');

    //  8 . . 1 K 1 . . .   
    //  7 . . 1 1 1 . . .   
    //  6 . . . . . . . .   
    //  5 . . . . . . . .   
    //  4 . . . . . . . .   
    //  3 . . . . . . . .   
    //  2 . . . . . . . .   
    //  1 . . . . . . . .   
    //    a b c d e f g h
    let sq = 59_u8;
    let targets = king_targets(sq);
    assert(targets == 0x141c000000000000, 'king on 8th rank (d8)');
}
