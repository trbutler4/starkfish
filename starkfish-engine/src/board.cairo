use debug::PrintTrait;


// board represented by one bitboard for each piece-color combination 
#[derive(Copy, Drop)]
struct Board {
    white_pawns: u64,
    white_rooks: u64,
    white_knights: u64,
    white_bishops: u64,
    white_queens: u64,
    white_king: u64,
    black_pawns: u64,
    black_rooks: u64,
    black_knights: u64,
    black_bishops: u64,
    black_queens: u64,
    black_king: u64
}
trait BoardTrait {
    fn new() -> Board; // create new board 
    fn white_pieces(ref self: Board) -> u64;
    fn black_pieces(ref self: Board) -> u64;
    fn all_pawns(ref self: Board) -> u64;
    fn all_rooks(ref self: Board) -> u64;
    fn all_knights(ref self: Board) -> u64;
    fn all_bishops(ref self: Board) -> u64;
    fn all_queens(ref self: Board) -> u64;
    fn all_kings(ref self: Board) -> u64;
    fn occupied_squares(ref self: Board) -> u64; // occupied squares as bit board
    fn empty_squares(ref self: Board) -> u64;
}
impl BoardImpl of BoardTrait {
    // starting board state 
    fn new() -> Board {
        Board {
            white_pawns: 0x000000000000ff00,
            white_rooks: 0x0000000000000081,
            white_knights: 0x0000000000000042,
            white_bishops: 0x0000000000000024,
            white_queens: 0x0000000000000008,
            white_king: 0x0000000000000010,
            black_pawns: 0x00ff000000000000,
            black_rooks: 0x8100000000000000,
            black_knights: 0x4200000000000000,
            black_bishops: 0x2400000000000000,
            black_queens: 0x0800000000000000,
            black_king: 0x1000000000000000
        }
    }
    fn white_pieces(ref self: Board) -> u64 {
        self.white_pawns
            | self.white_rooks
            | self.white_knights
            | self.white_bishops
            | self.white_queens
            | self.white_king
    }
    fn black_pieces(ref self: Board) -> u64 {
        self.black_pawns
            | self.black_rooks
            | self.black_knights
            | self.black_bishops
            | self.black_queens
            | self.black_king
    }
    fn all_pawns(ref self: Board) -> u64 {
        self.white_pawns | self.black_pawns
    }
    fn all_rooks(ref self: Board) -> u64 {
        self.white_rooks | self.black_rooks
    }
    fn all_knights(ref self: Board) -> u64 {
        self.white_knights | self.black_knights
    }
    fn all_bishops(ref self: Board) -> u64 {
        self.white_bishops | self.black_bishops
    }
    fn all_queens(ref self: Board) -> u64 {
        self.white_queens | self.black_queens
    }
    fn all_kings(ref self: Board) -> u64 {
        self.white_king | self.black_king
    }
    fn occupied_squares(ref self: Board) -> u64 {
        self.white_pieces() | self.black_pieces()
    }
    fn empty_squares(ref self: Board) -> u64 {
        let occupied: u64 = self.occupied_squares();
        occupied ^ 0xffffffffffffffff
    }
}

// --------------------------------------------------------------
// --------------------- TESTS ----------------------------------
// --------------------------------------------------------------

#[test]
fn test_create_board() {
    let mut new_board = BoardTrait::new();
    assert(new_board.all_pawns() == 0x00ff00000000ff00, 'incorrect pawns');
    assert(new_board.all_rooks() == 0x8100000000000081, 'incorrect rooks');
    assert(new_board.all_knights() == 0x4200000000000042, 'incorrect knights');
    assert(new_board.all_bishops() == 0x2400000000000024, 'incorrect bishops');
    assert(new_board.all_queens() == 0x0800000000000008, 'incorrect queens');
    assert(new_board.all_kings() == 0x1000000000000010, 'incorrect kings');
}

#[test]
fn test_occupied_squares() {
    let mut new_board = BoardTrait::new();
    let occupied: u64 = new_board.occupied_squares();
    assert(occupied == 0xffff00000000ffff, 'incorrect occupied squares');
}

#[test]
fn test_empty_squares() {
    let mut new_board = BoardTrait::new();
    let empty: u64 = new_board.empty_squares();
    assert(empty == 0x0000ffffffff0000, 'incorrect empty squares')
}

#[test]
fn test_white_pieces() {
    let mut new_board = BoardTrait::new();
    let white: u64 = new_board.white_pieces();
    assert(white == 0x000000000000ffff, 'incorrect white pieces')
}

#[test]
fn test_black_pieces() {
    let mut new_board = BoardTrait::new();
    let white: u64 = new_board.black_pieces();
    assert(white == 0xffff000000000000, 'incorrect black pieces')
}

