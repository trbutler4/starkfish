mod utils;
mod move_gen;
mod board;

use board::Board;
use board::BoardImpl;
use board::BoardTrait;


#[starknet::interface]
trait IStarkfish<TContractState> {
    fn throw(ref self: TContractState) -> felt252;
}

#[starknet::contract]
mod Starkfish {
    #[storage]
    struct Storage {}

    #[external(v0)]
    impl Starkfish of super::IStarkfish<ContractState> {
        fn throw(ref self: ContractState) -> felt252 {
            'hello'
        }
    }
}
