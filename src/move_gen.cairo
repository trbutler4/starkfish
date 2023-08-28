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
