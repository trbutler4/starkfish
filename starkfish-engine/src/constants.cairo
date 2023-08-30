// piece types 
const KNIGHT: felt252 = 'knight';
const BISHOP: felt252 = 'bishop';
const ROOK: felt252 = 'rook';
const PAWN: felt252 = 'pawn';
const KING: felt252 = 'king';
const QUEEN: felt252 = 'queen';

// piece colors 
const BLACK: felt252 = 'black';
const WHITE: felt252 = 'white';

// to represent empty squares 
const EMPTY: felt252 = 'empty';

// for easier to read move calculations
// right and left are from the white perspective
const ONE_RANK: usize = 8;
const TWO_RANKS: usize = 16;
const ONE_COL: usize = 1;
const RIGHT_SINGLE_DIAG: usize = 9;
const LEFT_SINGLE_DIAG: usize = 7;



