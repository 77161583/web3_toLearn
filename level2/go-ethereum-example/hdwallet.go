package go_ethereum_example

import (
	"fmt"
	hdwallet "github.com/miguelmota/go-ethereum-hdwallet"
	"log"
)

func wallet() {
	mnemonic := "tag volcano eight thank"
	wallet, err := hdwallet.NewFromMnemonic(mnemonic)
	if err != nil {
		log.Fatal(err)
	}

	path := hdwallet.MustParseDerivationPath("m/44'/60'/0'/0/0")
	account, err := wallet.Derive(path, false)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println(account.Address.Hex())

	path = hdwallet.MustParseDerivationPath("m/44'/60'/0'/0/1")
	account, err = wallet.Derive(path, false)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println(account.Address.Hex())
}
