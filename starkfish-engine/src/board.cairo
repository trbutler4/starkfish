use array::ArrayTrait;
use starkfish::constants::{PAWN, BISHOP, ROOK, KNIGHT, KING, QUEEN, BLACK, WHITE, EMPTY};
use debug::PrintTrait;

#[derive(Drop)]
struct Board {
    pieces: Array<felt252>,
    colors: Array<felt252>
}
trait BoardTrait {
    fn new() -> Board;
}
impl BoardImpl of BoardTrait {
    fn new() -> Board {

        // ? : arrays more or less efficient than dicts?

        let initial_pieces = array![
            ROOK, KNIGHT, BISHOP, QUEEN, KING, BISHOP, KNIGHT, ROOK,
            PAWN, PAWN, PAWN, PAWN, PAWN, PAWN, PAWN, PAWN,
            EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY,
            EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY,
            EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY,
            EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY,
            PAWN, PAWN, PAWN, PAWN, PAWN, PAWN, PAWN, PAWN,
            ROOK, KNIGHT, BISHOP, QUEEN, KING, BISHOP, KNIGHT, ROOK,
        ];

        let initial_colors = array![
            WHITE, WHITE, WHITE, WHITE, WHITE, WHITE, WHITE, WHITE,
            WHITE, WHITE, WHITE, WHITE, WHITE, WHITE, WHITE, WHITE,
            EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY,
            EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY,
            EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY,
            EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY,
            BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK,
            BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK,
        ];

        Board {
            pieces: initial_pieces,
            colors: initial_colors
        }
    }

}


#[test]
#[available_gas(3000000)]
fn test_initial_board() {
    let mut new_board = BoardTrait::new();
    
    // length should both be 64
    assert(new_board.pieces.len() == 64, 'pieces should have len 64');
    assert(new_board.colors.len() == 64, 'colors should have len 64');

    let a1_piece = *new_board.pieces.at(0);
    assert(a1_piece == ROOK, 'piece on a1 should be a rook');

    let a1_color = *new_board.colors.at(0);
    assert(a1_color == WHITE, 'piece on a1 should be white');
}
