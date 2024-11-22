package web

import (
	"context"
	"errors"
	"fmt"
	"github.com/davecgh/go-spew/spew"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/ethclient"
	"github.com/gin-gonic/gin"
	hdwallet "github.com/miguelmota/go-ethereum-hdwallet"
	"log"
	"math/big"
	"net/http"
)

type UserHandler struct {
	ethClient *ethclient.Client
}

// NewUserHandler 函数，连接到以太坊客户端并返回 UserHandler
func NewUserHandler(infuraURL string) (*UserHandler, error) {
	client, err := ethclient.Dial(infuraURL)
	if err != nil {
		return nil, err // 返回错误而不是 panic，方便外部处理
	}
	return &UserHandler{ethClient: client}, nil
}

func (u *UserHandler) RegisterRoutes(server *gin.Engine) {
	ug := server.Group("/users")
	ug.GET("/index", u.Index)
	ug.GET("/wallet", u.Wallet)
	ug.GET("/transaction", u.Transaction)
}

// 连接到 Infura 通过构造函数初始化的客户端
func (u *UserHandler) connectToInfura() (*ethclient.Client, error) {
	if u.ethClient != nil {
		return u.ethClient, nil
	}
	return nil, errors.New("ethClient is not initialized")
}

func (u *UserHandler) Index(ctx *gin.Context) {
	ctx.HTML(http.StatusOK, "index.html", nil) // 渲染模板
}

func (u *UserHandler) Wallet(ctx *gin.Context) {
	mnemonic := "tag volcano eight thank tide danger coast health above argue embrace heavy"
	//使用助记词创建钱包
	wallet, err := hdwallet.NewFromMnemonic(mnemonic)
	if err != nil {
		log.Fatal(err)
	}

	//定义了一个“派生路径”（derivation path），这个路径遵循 BIP-44 标准，代表了从助记词生成的第一个以太坊账户。
	path := hdwallet.MustParseDerivationPath("m/44'/60'/0'/0/0")
	account, err := wallet.Derive(path, false)
	if err != nil {
		log.Fatal(err)
	}
	address1 := account.Address.Hex()

	//第二个地址生成 派生路径为 m/44'/60'/0'/0/1，与第一个地址的路径类似，只不过最后的索引 0/1 表示生成第二个地址。
	path = hdwallet.MustParseDerivationPath("m/44'/60'/0'/0/1")
	account, err = wallet.Derive(path, false)
	if err != nil {
		log.Fatal(err)
	}
	address2 := account.Address.Hex()
	//fmt.Println(account.Address.Hex())
	ctx.JSON(http.StatusOK, gin.H{
		"功能描述：": "基于一个助记词（mnemonic）生成以太坊的两个地址",
		"地址1":   address1,
		"地址2":   address2,
	})
}

// Transaction 签署交易
func (u *UserHandler) Transaction(ctx *gin.Context) {
	//通过助记词创建钱包
	mnemonic := "tag volcano eight thank tide danger coast health above argue embrace heavy"
	wallet, err := hdwallet.NewFromMnemonic(mnemonic)
	if err != nil {
		log.Fatal(err)
	}
	//派生账户
	path := hdwallet.MustParseDerivationPath("m/44'/60'/0'/0/0")
	account, err := wallet.Derive(path, true)
	if err != nil {
		log.Fatal(err)
	}
	//设置交易参数
	nonce := uint64(0)                       //交易序号
	value := big.NewInt(1000000000000000000) //交易的金额
	toAddress := common.HexToAddress("0x0")  //交易的目标地址
	gasLimit := uint64(21000)                //交易的最大 gas 消耗量
	gasPrice := big.NewInt(21000000000)      //每单位 gas 的价格
	var data []byte                          //附加的数据

	//创建交易
	tx := types.NewTransaction(nonce, toAddress, value, gasLimit, gasPrice, data)
	//签署交易 wallet.SignTx 对交易进行签名
	signedTx, err := wallet.SignTx(account, tx, nil)
	if err != nil {
		log.Fatal(err)
	}

	spew.Dump(signedTx)
}

// CheckAddress 检查地址
func (u *UserHandler) CheckAddress(ctx *gin.Context) {
	address := common.HexToAddress("0xE8b8990f266299545f0a8bA03db8D7D5609c818F")
	bytecode, err := u.ethClient.CodeAt(context.Background(), address, nil)
	if err != nil {
		log.Fatal(err)
	}
	isContract := len(bytecode) > 0
	fmt.Printf("is contract %V\n", isContract)
}
