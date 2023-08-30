declare:
	starkli declare target/dev/starkfish_Starkfish.sierra.json \
	--compiler-version 2.1.0 \
	--rpc http://0.0.0.0:5050 \
	--account ~/.starkli-wallets/deployer/account0_account.json \
	--keystore  ~/.starkli-wallets/deployer/account0_keystore.json

deploy: 
	starkli deploy $(CLASS_HASH) \
	--rpc http://0.0.0.0:5050 \
	--account ~/.starkli-wallets/deployer/account0_account.json \
	--keystore ~/.starkli-wallets/deployer/account0_keystore.json

create_game:
	starkli invoke $(CONTRACT_ADDRESS) create_game \
	--rpc http://0.0.0:5050 \
	--account ~/.starkli-wallets/deployer/account0_account.json \
	--keystore ~/.starkli-wallets/deployer/account0_keystore.json

read_cur_pieces: 
	starkli call $(CONTRACT_ADDRESS) read_cur_pieces \
	--rpc http://0.0.0:5050 

