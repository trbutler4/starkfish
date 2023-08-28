use starkfish::move_gen::{
    king_targets, bishop_targets, queen_targets, rook_targets, black_pawn_all_attacks,
    black_pawn_double_attacks, white_pawn_all_attacks, south_sliding_targets,
    southeast_sliding_targets, north_sliding_targets, northeast_sliding_targets,
    southwest_sliding_targets, northwest_sliding_targets, west_sliding_targets,
    east_sliding_targets, all_black_pawn_attacks, all_black_pawn_pushes, black_pawn_ks_attacks,
    black_pawn_qs_attacks, white_pawn_ks_attacks, white_pawn_qs_attacks, black_pawn_single_attacks,
    white_pawn_single_attacks, white_pawn_double_push_targets, white_pawn_double_attacks,
    black_pawn_double_push_targets, black_pawns_double_push_eligible,
    white_pawn_single_push_targets, black_pawns_single_push_eligible,
    black_pawn_single_push_targets, all_white_pawn_pushes, all_white_pawn_attacks,
    white_pawns_single_push_eligible, white_pawns_double_push_eligible, RANK3, RANK4, RANK5, RANK6,
    no_no_ea_knight_target, no_ea_ea_knight_target, so_ea_ea_knight_target, so_so_ea_knight_target,
    no_no_we_knight_target, no_we_we_knight_target, so_we_we_knight_target, so_so_we_knight_target,
    all_knight_targets
};

use starkfish::board::BoardTrait;

use debug::PrintTrait;

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
