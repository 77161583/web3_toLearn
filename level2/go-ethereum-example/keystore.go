package go_ethereum_example

import (
	"fmt"
	"github.com/ethereum/go-ethereum/accounts/keystore"
	"io/ioutil"
	"log"
	"os"
)

// keystore
func getKeystore() {
	ks := keystore.NewKeyStore("./wallets", keystore.StandardScryptN, keystore.StandardScryptP)
	password := "secret"
	account, err := ks.NewAccount(password)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println(account.Address.Hex()) //0x08df93f2dD41421e51B92b1714C41bd4Cf956f62
}

func importKs() {
	file := "./wallets/UTC--2024-11-18T13-41-56.352973000Z--08df93f2dd41421e51b92b1714c41bd4cf956f62"
	ks := keystore.NewKeyStore("./wallets", keystore.StandardScryptN, keystore.StandardScryptP)
	jsonBytes, err := ioutil.ReadFile(file)
	if err != nil {
		log.Fatal(err)
	}
	password := "secret"
	account, err := ks.Import(jsonBytes, password, password)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println(account.Address.Hex())
	if err := os.Remove(file); err != nil {
		log.Fatal(err)
	}

}
