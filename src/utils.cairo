use debug::PrintTrait;

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

