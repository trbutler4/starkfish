

#[starknet::interface]
trait IStarkfish<TContractState> {
    fn step_eval(ref self: TContractState);
}

#[starknet::contract]
mod Starkfish {
    use starkfish::move_gen::queen_targets;
    use starkfish::move_gen::rook_targets;
    use starkfish::move_gen::all_black_pawn_attacks;
    use starkfish::move_gen::all_white_pawn_attacks;
    use starkfish::move_gen::all_white_pawn_pushes;
    use starkfish::move_gen::all_black_pawn_pushes;
    use starkfish::move_gen::bishop_targets;
    use starkfish::move_gen::king_targets;
    use starkfish::board::{BoardTrait, BoardImpl};
    #[storage]
    struct Storage {}

    #[external(v0)]
    impl Starkfish of super::IStarkfish<ContractState> {

        // to show amount of steps when executed in katana
        fn step_eval(ref self: ContractState) {
            let mut new_board = BoardTrait::new();
            let wpawns = new_board.white_pawns;
            let bpawns = new_board.black_pawns;
            let empty = new_board.empty_squares();
            queen_targets(35_u8);
            rook_targets(35_u8);
            rook_targets(32_u8);
            all_white_pawn_attacks(wpawns);
            all_black_pawn_attacks(bpawns);
            all_white_pawn_pushes(wpawns, empty);
            all_black_pawn_pushes(bpawns, empty);
            king_targets(35_u8);
        }
    }
}
