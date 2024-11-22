package main

import (
	"context"
	"crypto/ecdsa"
	"fmt"
	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/common/hexutil"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/ethereum/go-ethereum/ethclient"
	"golang.org/x/crypto/sha3"
	token "level2/pkg"
	"log"
	"math"
	"math/big"
)

func main() {
	// 02.链接客户端
	client, err := connectToInfura()
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("we are connect", client)
	defer client.Close()
	//03账户
	//performAccountOperations()
	//04账户余额
	//accountBalance(client)
	//最新区块号
	//blockNum := newBlockNum(client)
	//newBlockBalance(client, blockNum)
	//getToken(client) //有问题
	//生成新钱包
	//buildNewWallet()
	//keyStore

	//importKs()

}

// 02.链接客户端
func connectToInfura() (*ethclient.Client, error) {
	//infuraUrl := "https://mainnet.infura.io/v3/5cfcf36740804b5f92e934d6a2ba77c8"
	infuraUrl := "https://sepolia.infura.io/v3/5cfcf36740804b5f92e934d6a2ba77c8"

	return ethclient.Dial(infuraUrl)
}

// 03账户
func performAccountOperations() {
	address := common.HexToAddress("0x3C0beEae20D3a11563BFF81cd52a88E40F24E534")
	//打印原始地址的十六进制字符串
	fmt.Println(address.Hex()) // 0x3C0beEae20D3a11563BFF81cd52a88E40F24E534
	//计算哈希
	addressHash := sha3.Sum256(address.Bytes())
	fmt.Printf("%x\n", addressHash) //0af148e583ffa6a2cd09e9fbf5aea177486d62b590007403ea5a8da36f397b0c
	//打印地址的字节表示形式
	fmt.Println(address.Bytes()) // [60 11 238 174 32 211 161 21 99 191 248 28 213 42 136 228 15 36 229 52]
}

// 04账户余额
func accountBalance(client *ethclient.Client) {
	account := common.HexToAddress("0xE8b8990f266299545f0a8bA03db8D7D5609c818F")
	balance, err := client.BalanceAt(context.Background(), account, nil)
	if err != nil {
		log.Fatal(err)
	}
	ethVal := balanceConversion(balance.String())
	fmt.Println("账户余额：", ethVal) //100000000000000000000
}

func balanceConversion(balance string) *big.Float {
	//余额精度 将Wei 转换成了 Ether
	fbalance := new(big.Float)
	fbalance.SetString(balance)
	// 1 Ether = 10^18 Wei
	return new(big.Float).Quo(fbalance, big.NewFloat(math.Pow10(18)))
}

// 获取最新的区块号
func newBlockNum(client *ethclient.Client) *big.Int {
	header, err := client.HeaderByNumber(context.Background(), nil)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("最新区块号:", header.Number)
	return header.Number
}

// 最新区块号的余额 区块号必须是 big.Int 类型
func newBlockBalance(client *ethclient.Client, blockNum *big.Int) {
	account := common.HexToAddress("0xE8b8990f266299545f0a8bA03db8D7D5609c818F")
	balance, err := client.BalanceAt(context.Background(), account, blockNum)
	if err != nil {
		log.Fatal(err)
	}
	ethVal := balanceConversion(balance.String())
	fmt.Println("最新区块号的余额：", ethVal)
}

func getToken(client *ethclient.Client) {
	tokenAddress := common.HexToAddress("0xa74476443119A942dE498590Fe1f2454d7D4aC0d")
	instance, err := token.NewToken(tokenAddress, client)
	if err != nil {
		log.Fatal(err)
	}

	address := common.HexToAddress("0x7DD9c5Cba05E151C895FDe1CF355C9A1D5DA6429")
	bal, err := instance.BalanceOf(&bind.CallOpts{}, address)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Printf("wei: %s\n", bal) // "wei: 74605500647408739782407023"
}

// 生成新钱包
func buildNewWallet() {
	//1.生成私钥
	/**
	crypto.GenerateKey()：生成一个随机的椭圆曲线私钥，基于 secp256k1 椭圆曲线。
	privateKey：一个 *ecdsa.PrivateKey 类型的对象，包含私钥和对应的公钥。
	*/
	privateKey, err := crypto.GenerateKey()
	if err != nil {
		log.Fatal(err)
	}
	//导出私钥并打印
	/**
	crypto.FromECDSA(privateKey)：将 *ecdsa.PrivateKey 转换为字节切片（[]byte）。
	hexutil.Encode(privateKeyBytes)：将私钥的字节数据转换为十六进制字符串表示。
	[2:]：去掉前缀 0x，只打印实际的私钥值。
	*/
	privateKeyBytes := crypto.FromECDSA(privateKey)
	fmt.Println("这是私钥：", hexutil.Encode(privateKeyBytes)[2:]) //cc2639be3f55c9c152d64d9060d02278b1396d6daba8b4b46bc6851c50a20655

	//提取公钥并打印
	/**
	privateKey.Public()：提取私钥对应的公钥，返回的是一个接口类型。
	类型断言 (*ecdsa.PublicKey)：将公钥转换为 *ecdsa.PublicKey 类型，用于后续操作。
	*/
	publicKey := privateKey.Public()
	publicKeyECDSA, ok := publicKey.(*ecdsa.PublicKey)
	if !ok {
		log.Fatal("error casting public key to ECDSA")
	}
	/**
	crypto.FromECDSAPub(publicKeyECDSA)：将 *ecdsa.PublicKey 转换为字节切片。
	[4:]：跳过公钥前4个字符（0x04 是未压缩格式的前缀），只打印实际的公钥值。
	*/
	publicKeyBytes := crypto.FromECDSAPub(publicKeyECDSA)
	fmt.Println("这是公钥：", hexutil.Encode(publicKeyBytes)[4:]) //b6acbb91dd1dcfefe9cdac66f4a13627b4be80e03d9c34d9c903db0e9a9f1c50eb91e9995887060102f0717b8ce45aa6aef037a79fafdbecc644bb25abe247a5
	//计算以太坊地址
	/**
	crypto.PubkeyToAddress(*publicKeyECDSA)：根据公钥计算以太坊地址。
	取公钥的后 64 字节（去掉前缀 0x04）。
	使用 Keccak256 哈希算法计算哈希值。
	取哈希值的最后 20 字节，作为地址。
	.Hex()：将地址格式化为十六进制字符串，带 0x 前缀。
	*/
	address := crypto.PubkeyToAddress(*publicKeyECDSA).Hex()
	fmt.Println("这是正常公钥：", address) //0xe915764280f1b37b9a86e5c2007447C3943b4A2e
	//手动计算地址
	/**
	sha3.NewKeccak256()：创建 Keccak256 哈希算法实例。
	hash.Write(publicKeyBytes[1:])：
	使用公钥的后 64 字节作为输入（publicKeyBytes[1:] 跳过未压缩格式的前缀 0x04）。
	hash.Sum(nil)：计算哈希值，返回一个 []byte 类型的结果。
	[12:]：取哈希值的后 20 字节，表示以太坊地址。
	*/
	hash := sha3.NewLegacyKeccak256()
	hash.Write(publicKeyBytes[1:])
	fmt.Println("这是Keccak256之后的公钥：", hexutil.Encode(hash.Sum(nil)[12:]))
}
