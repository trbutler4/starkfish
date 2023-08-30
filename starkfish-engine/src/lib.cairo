mod constants;
mod board;
mod move_gen;
mod utils;

use constants::{PAWN, BISHOP, ROOK, KNIGHT, KING, QUEEN, BLACK, WHITE, EMPTY};
use array::ArrayTrait;
use board::BoardTrait;
use move_gen::{Move, generate_moves};

#[starknet::interface]
trait IStarkfish<TContractState> {
    fn create_game(ref self: TContractState);
    fn read_cur_pieces(ref self: TContractState) -> Array<felt252>;
    fn read_cur_colors(ref self: TContractState) -> Array<felt252>;
    fn generate_move(ref self: TContractState) -> Move;
}

#[starknet::contract]
mod Starkfish {
    use core::debug::PrintTrait;
    use super::constants::{PAWN, BISHOP, ROOK, KNIGHT, KING, QUEEN, BLACK, WHITE, EMPTY};
    use super::board::BoardTrait;
    use super::move_gen::{Move, generate_moves};

    #[storage]
    struct Storage {
        // ? : is there an easy way to convert this to an array for my board 
        // representation?
        cur_pieces: LegacyMap::<usize, felt252>,
        cur_colors: LegacyMap::<usize, felt252>,
    }

    #[external(v0)]
    impl Starkfish of super::IStarkfish<ContractState> {
        fn create_game(ref self: ContractState) {
            let b = BoardTrait::new();

            let mut sq_index = 0_usize;
            loop {
                if (sq_index > 63) {
                    break;
                }

                let p = *b.pieces.at(sq_index);
                let c = *b.colors.at(sq_index);

                self.cur_pieces.write(sq_index, p);
                self.cur_colors.write(sq_index, c);

                sq_index += 1;
            }
        }
        fn read_cur_pieces(ref self: ContractState) -> Array<felt252> {
            let mut a: Array<felt252> = ArrayTrait::new();

            let mut sq_index = 0_usize;
            loop {
                if (sq_index > 63) {
                    break;
                }
               
                let p = self.cur_pieces.read(sq_index);
                a.append(p);

                sq_index += 1;
            };

            a
        }
        fn read_cur_colors(ref self: ContractState) -> Array<felt252> {
            let mut a: Array<felt252> = ArrayTrait::new();

            let mut sq_index = 0_usize;
            loop {
                if (sq_index > 63) {
                    break;
                }
               
                let c = self.cur_colors.read(sq_index);
                a.append(c);

                sq_index += 1;
            };

            a
        }
        fn generate_move(ref self: ContractState) -> Move {

            // for the sake of running on katana to see the steps 
            let mut b = BoardTrait::new();
            generate_moves(b, WHITE);


            Move { from: 51, to: 43 }
        }
    }

}




