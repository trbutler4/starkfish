use dict::Felt252DictTrait;
use debug::PrintTrait;


// mapping of squares to their bitboard representation 
// maybe better to do this with a struct?
#[derive(Index, IndexView)]
fn create_sqaure_map() {
    let mut squares: Felt252Dict<u64> = Default::default();
    squares.insert('A1', 0x1);
    squares.insert('B1', 0x2);
    squares.insert('C1', 0x4);
    squares.insert('D1', 0x8);
    squares.insert('E1', 0x10);
    squares.insert('F1', 0x20);
    squares.insert('G1', 0x40);
    squares.insert('H1', 0x80);

    squares.insert('A2', 0x100);
    squares.insert('B2', 0x200);
    squares.insert('C2', 0x400);
    squares.insert('D2', 0x800);
    squares.insert('E2', 0x1000);
    squares.insert('F2', 0x2000);
    squares.insert('G2', 0x4000);
    squares.insert('H2', 0x8000);

    squares.insert('A3', 0x10000);
    squares.insert('B3', 0x20000);
    squares.insert('C3', 0x40000);
    squares.insert('D3', 0x80000);
    squares.insert('E3', 0x100000);
    squares.insert('F3', 0x200000);
    squares.insert('G3', 0x400000);
    squares.insert('H3', 0x800000);

    squares.insert('A4', 0x1000000);
    squares.insert('B4', 0x2000000);
    squares.insert('C4', 0x4000000);
    squares.insert('D4', 0x8000000);
    squares.insert('E4', 0x10000000);
    squares.insert('F4', 0x20000000);
    squares.insert('G4', 0x40000000);
    squares.insert('H4', 0x80000000);

    squares.insert('A5', 0x100000000);
    squares.insert('B5', 0x200000000);
    squares.insert('C5', 0x400000000);
    squares.insert('D5', 0x800000000);
    squares.insert('E5', 0x1000000000);
    squares.insert('F5', 0x2000000000);
    squares.insert('G5', 0x4000000000);
    squares.insert('H5', 0x8000000000);

    squares.insert('A6', 0x10000000000);
    squares.insert('B6', 0x20000000000);
    squares.insert('C6', 0x40000000000);
    squares.insert('D6', 0x80000000000);
    squares.insert('E6', 0x100000000000);
    squares.insert('F6', 0x200000000000);
    squares.insert('G6', 0x400000000000);
    squares.insert('H6', 0x800000000000);

    squares.insert('A7', 0x1000000000000);
    squares.insert('B7', 0x2000000000000);
    squares.insert('C7', 0x4000000000000);
    squares.insert('D7', 0x8000000000000);
    squares.insert('E7', 0x10000000000000);
    squares.insert('F7', 0x20000000000000);
    squares.insert('G7', 0x40000000000000);
    squares.insert('H7', 0x80000000000000);

    squares.insert('A8', 0x100000000000000);
    squares.insert('B8', 0x200000000000000);
    squares.insert('C8', 0x400000000000000);
    squares.insert('D8', 0x800000000000000);
    squares.insert('E8', 0x1000000000000000);
    squares.insert('F8', 0x2000000000000000);
    squares.insert('G8', 0x4000000000000000);
    squares.insert('H8', 0x8000000000000000);
}

fn toggle_bit(bb: u64, sqaure: felt252) {// TODO  
}

fn shift_left(val: u64, n: u8) -> u64 {
    val * power_of_2(n)
}

fn shift_right(val: u64, n: u8) -> u64 {
    val / power_of_2(n)
}

// used for shifting 
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
fn shift_rank_up(bb: u64) -> u64 {
    shift_left(bb, 8)
}

// shift a given bitboard one rank down
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
    let x = 0b010101;
    let y = 0xff;
    assert(count_set_bits(x) == 3, '0b010101 has 3 bits set');
    assert(count_set_bits(y) == 8, '0xff has 8 bits set');
}

#[test]
#[available_gas(9999999)]
fn test_shift_rank_up() {
    let x = 0xff00;
    let y = 0xaa5500;
    assert(shift_rank_up(x) == 0xff0000, 'should be shifted up one rank');
    assert(shift_rank_up(y) == 0xaa550000, 'should be shifted up one rank');
}

#[test]
#[available_gas(9999999)]
fn test_shift_rank_down() {
    let x = 0xff0000;
    let y = 0xaa550000;
    assert(shift_rank_down(x) == 0xff00, 'should be shifted down one rank');
    assert(shift_rank_down(y) == 0xaa5500, 'should be shifted down one rank');
}

#[test]
#[should_panic]
fn test_shift_rank_up_8th_rank() {
    let x = 0xff00000000000000; // 8th rank
    shift_rank_up(x); // should overflow
}

#[test]
#[should_panic]
fn test_sanity() {
    0x100000000_u64 * 0x100000000_u64;
}
