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

