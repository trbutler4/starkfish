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

    struct Piece {
        Type: felt252,
        Rank: u8,
        File: u8,
        Color: felt252
    }

    enum Board {
        Pieces: Felt252Dict<Piece>
    }
}




