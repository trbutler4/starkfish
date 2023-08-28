use debug::PrintTrait;
use traits::Into;
use core::traits::TryInto;
use option::OptionTrait;


fn shift_left(val: u64, n: u8) -> u64 {
    val * power_of_2(n)
}

// NOTE: if val will always be divisible by n, felt can offer performance improvement 
fn shift_right(val: u64, n: u8) -> u64 {
    val / power_of_2(n)
}

// instead of overflowing, these will ignore bits that 
// go "off the board"  
fn bitboard_shift_left(bb: u64, n: u8) -> u64 {
    let mut bb_u128: u128 = bb.into();
    bb_u128 = bb_u128 * power_of_2(n).into();
    let res: u64 = (bb_u128 & 0xFFFFFFFFFFFFFFFF).try_into().unwrap();
    res
}
fn bitboard_shift_right(bb: u64, n: u8) -> u64 {
    let mut bb_u128: u128 = bb.into();
    bb_u128 = bb_u128 * 2 * power_of_2(63).into();
    bb_u128 = bb_u128 / power_of_2(n).into();
    bb_u128 = bb_u128 / power_of_2(63).into();
    bb_u128 = bb_u128 / 2;
    let mut res: u64 = (bb_u128 & 0xFFFFFFFFFFFFFFFF).try_into().unwrap();
    res
}

// used for shifting 
// input -> u8 b/c 63 max power we will need to calculate
// output -> u64 b/c max size for 2^63
fn power_of_2(n: u8) -> u64 {
    let mut result = 1;
    let mut i = 0;

    loop {
        if (i == n) {
            break;
        }
        result *= 2;
        i += 1;
    };

    result
}

// shift a given bitboard one rank up 
// TODO: handle overflow 
fn shift_rank_up(bb: u64) -> u64 {
    shift_left(bb, 8)
}

// shift a given bitboard one rank down
// TODO: handle overflow
fn shift_rank_down(bb: u64) -> u64 {
    shift_right(bb, 8)
}

// count the number of bits set in a bit board 
// given a piece bit board, this will give us the number of pieces
fn count_set_bits(bb: u64) -> u64 {
    let mut count: u64 = 0;
    let mut bb_copy = bb;

    loop {
        if (bb_copy == 0) {
            break;
        }
        count += bb_copy & 1_u64;
        bb_copy = shift_right(bb_copy, 1);
    };

    count
}

fn get_rank_index(sq: u8) -> u8 {
    (sq / 8)
}

fn get_file_index(sq: u8) -> u8 {
    (sq % 8)
}

// --------------------------------------------------------------
// --------------------- TESTS ----------------------------------
// --------------------------------------------------------------

#[test]
#[available_gas(9999999)]
fn test_power_of_2() {
    let r = power_of_2(3);
    let r2 = power_of_2(5);
    let r3 = power_of_2(10);
    assert(r == 0x8, '2^3 should be 8');
    assert(r2 == 0x20, '2^5 should be 20');
    assert(r3 == 0x400, '2^10 should be 400');
}

#[test]
#[available_gas(9999999)]
fn test_shift_left() {
    assert(shift_left(0b01, 1) == 0b10, '0b01 << 1 should be 0b10');
    assert(shift_left(0b0001, 2) == 0b0100, '0b0001 << 2 should be 0b0100');
    assert(shift_left(0x0101010101010100, 2) == 0x404040404040400, '');
    assert(shift_left(0x1, 63) == 0x8000000000000000, '');
}

#[test]
#[available_gas(9999999)]
fn test_shift_right() {
    assert(shift_right(0b10, 1) == 0b01, '0b10 >> 1 should be 0b10');
    assert(shift_right(0b0100, 2) == 0b0001, '0b0100 >> 2 should be 0b0001');
}

#[test]
#[available_gas(9999999)]
fn test_count_set_bits() {
    assert(count_set_bits(0b010101) == 3, '0b010101 has 3 bits set');
    assert(count_set_bits(0xff) == 8, '0xff has 8 bits set');
}

#[test]
#[available_gas(9999999)]
fn test_shift_rank_up() {
    assert(shift_rank_up(0xff00) == 0xff0000, 'should be shifted up one rank');
    assert(shift_rank_up(0xaa5500) == 0xaa550000, 'should be shifted up one rank');
}

#[test]
#[available_gas(9999999)]
fn test_shift_rank_down() {
    assert(shift_rank_down(0xff0000) == 0xff00, 'should be shifted down one rank');
    assert(shift_rank_down(0xaa550000) == 0xaa5500, 'should be shifted down one rank');
}

#[test]
#[available_gas(9999999)]
#[should_panic] // currently expected behavior, but 
fn test_shift_rank_up_8th_rank() {
    let x = 0xff00000000000000; // 8th rank
    shift_rank_up(x); // should overflow
}

#[test]
#[available_gas(9999999)]
fn test_bitboard_shift_left() {
    let x = 0x101010101010100;
    let shifted = bitboard_shift_left(x, 20);
    assert(shifted == 0x1010101010000000, 'shifting some off board');

    let x = 0x101010101010100;
    let shifted = bitboard_shift_left(x, 63);
    assert(shifted == 0x0, 'shifting all off board');

    let x = 0x1;
    let shifted = bitboard_shift_left(x, 63);
    assert(shifted == 0x8000000000000000, 'corner to corner');

    let x = 0x102810000000;
    let shifted = bitboard_shift_left(x, 1);
    assert(shifted == 0x205020000000, 'diamond pattern');
}

#[test]
#[available_gas(9999999)]
fn test_bitboard_shift_right() {
    let x = 0x8000000000000000;
    let shifted = bitboard_shift_right(x, 63);
    assert(shifted == 0x1, 'corner to corner');

    let x = 0x8080808080808080;
    let shifted = bitboard_shift_right(x, 20);
    assert(shifted == 0x80808080808, 'shifting some off board');

    let x = 0x102810000000;
    let shifted = bitboard_shift_right(x, 1);
    assert(shifted == 0x81408000000, 'diamond pattern');
}


#[test]
#[available_gas(9999999)]
fn test_get_rank_index() {
    // board layout (rank and file indexes)
    //  7   56	57	58	59	60	61	62	63
    //  6   48	49	50	51	52	53	54	55
    //  5   40	41	42	43	44	45	46	47
    //  4   32	33	34	35	36	37	38	39
    //  3   24	25	26	27	28	29	30	31
    //  2   16	17	18	19	20	21	22	23
    //  1   08	09	10	11	12	13	14	15
    //  0   00	01	02	03	04	05	06	07
    //      0   1   2   3   4   5   7   8
    assert(get_rank_index(0) == 0, 'a1');
    assert(get_rank_index(9) == 1, 'b2');
    assert(get_rank_index(35) == 4, 'd5');
    assert(get_rank_index(63) == 7, 'h8');
}

#[test]
#[available_gas(9999999)]
fn test_get_file_index() {
    // board layout 	
    //  8   56	57	58	59	60	61	62	63
    //  7   48	49	50	51	52	53	54	55
    //  6   40	41	42	43	44	45	46	47
    //  5   32	33	34	35	36	37	38	39
    //  4   24	25	26	27	28	29	30	31
    //  3   16	17	18	19	20	21	22	23
    //  2   08	09	10	11	12	13	14	15
    //  1   00	01	02	03	04	05	06	07
    //      a   b   c   d   e   f   g   h
    assert(get_file_index(0) == 0, 'a1');
    assert(get_file_index(9) == 1, 'b2');
    assert(get_file_index(35) == 3, 'd5');
    assert(get_file_index(63) == 7, 'h8');
}
