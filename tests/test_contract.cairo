use array::ArrayTrait;
use result::ResultTrait;
use option::OptionTrait;
use traits::TryInto;
use starknet::ContractAddress;
use starknet::Felt252TryIntoContractAddress;
use cheatcodes::PreparedContract;

use starkfish::IStarkfishSafeDispatcher;
use starkfish::IStarkfishSafeDispatcherTrait;

fn deploy_contract(name: felt252) -> ContractAddress {
    let class_hash = declare(name);
    let prepared = PreparedContract {
        class_hash, constructor_calldata: @ArrayTrait::new()
    };
    deploy(prepared).unwrap()
}

#[test]
fn test_throw() {
    let contract_address = deploy_contract('Starkfish');

    let safe_dispatcher = IStarkfishSafeDispatcher { contract_address };

    assert(safe_dispatcher.throw() == 'hello', 'should say hello');

}

