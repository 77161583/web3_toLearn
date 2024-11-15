package main

import (
	"fmt"
	token "level2/pkg"
	"log"

	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/ethclient"
)

func main() {
	/**
	 * 02.链接客户端
	 */
	// 连接到 Ganache 本地节点
	client, err := ethclient.Dial("http://127.0.0.1:8545")
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("Successfully connected to Ganache")
	_ = client

	/**
	 * 03账户
	 */
	// address := common.HexToAddress("0x3C0beEae20D3a11563BFF81cd52a88E40F24E534")
	// //打印原始地址的十六进制字符串
	// fmt.Println(address.Hex()) // 0x3C0beEae20D3a11563BFF81cd52a88E40F24E534
	// //计算哈希
	// addressHash := sha3.Sum256(address.Bytes())
	// fmt.Printf("%x\n", addressHash) //0af148e583ffa6a2cd09e9fbf5aea177486d62b590007403ea5a8da36f397b0c
	// //打印地址的字节表示形式
	// fmt.Println(address.Bytes()) // [60 11 238 174 32 211 161 21 99 191 248 28 213 42 136 228 15 36 229 52]

	/**
	 * 04账户余额
	 */
	//通过地址获取余额
	// account := common.HexToAddress("0x3C0beEae20D3a11563BFF81cd52a88E40F24E534")
	// balance, err := client.BalanceAt(context.Background(), account, nil)
	// if err != nil {
	// 	log.Fatal(err)
	// }
	// fmt.Println(balance) //100000000000000000000

	// 获取最新的区块头
	// header, err := client.HeaderByNumber(context.Background(), nil)
	// if err != nil {
	// 	log.Fatal(err)
	// }
	// fmt.Println("最新区块号:", header.Number)

	//通过区块号获取余额 区块号必须是 big.Int 类型
	// blockNum := big.NewInt(0)
	// balance, err := client.BalanceAt(context.Background(), account, blockNum)
	// if err != nil {
	// 	log.Fatal(err)
	// }
	// fmt.Println(balance)

	//余额精度 将Wei 转换成了 Ether
	// fbalance := new(big.Float)                                             //创建了一个 big.Float 类型的指针变量 fbalance
	// fbalance.SetString(balance.String())                                   //将余额转换成字符串形式，通过这个fbalance.SetString方法将字符串赋值给fbalance
	// ethValue := new(big.Float).Quo(fbalance, big.NewFloat(math.Pow10(18))) // 1 Ether = 10^18 Wei
	// fmt.Println(ethValue)

	//获取待处理的余额
	// pendingBalance, err := client.PendingBalanceAt(context.Background(), account)
	// fmt.Println(pendingBalance)

	/**
		账户代币余额
	**/
	tokenAddress := common.HexToAddress("0x6B175474E89094C44Da98b954EedeAC495271d0F")
	instance, err := token.NewToken(tokenAddress, client)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println(instance)

	//调用er20
	address := common.HexToAddress("0x0536806df512d6cdde913cf95c9886f65b1d3462")
	bal, err := instance.BalanceOf(&bind.CallOpts{}, address)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("Wei: %s\n", bal)
}
