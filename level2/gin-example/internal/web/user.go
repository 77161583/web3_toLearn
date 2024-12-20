package web

import (
	"context"
	"crypto/ecdsa"
	"encoding/hex"
	"errors"
	"fmt"
	"github.com/davecgh/go-spew/spew"
	"github.com/ethereum/go-ethereum"
	"github.com/ethereum/go-ethereum/accounts/abi"
	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/common/hexutil"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/ethereum/go-ethereum/ethclient"
	"github.com/ethereum/go-ethereum/rlp"
	"github.com/gin-gonic/gin"
	hdwallet "github.com/miguelmota/go-ethereum-hdwallet"
	"golang.org/x/crypto/sha3"
	pkgStore "level2/pkg"
	"log"
	"math/big"
	"net/http"
	"regexp"
	"strings"
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
	ug.GET("/checkAddress", u.CheckAddress)
	ug.GET("/checkBlock", u.CheckBlock)
	ug.GET("/checkTransactions", u.CheckTransactions)
	ug.GET("/transferETH", u.TransferETH)
	ug.GET("/tokenTransfer", u.TokenTransfer)
	ug.GET("/subscribe", u.Subscribe)
	ug.GET("/transactionRawCreate", u.TransactionRawCreate)
	ug.GET("/transactionRawSendreate", u.TransactionRawSendreate)
	ug.GET("/contractDeploy", u.ContractDeploy)
	ug.GET("/loadContract", u.LoadContract)
	ug.GET("/writeContract", u.WriteContract)
	ug.GET("/readContract", u.ReadContract)
	ug.GET("/subLog", u.SubLog)
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
	//正则表达式验证以太坊地址
	re := regexp.MustCompile("^0x[0-9a-fA-F]{40}$")
	fmt.Printf("is valid: %v\n", re.MatchString("0x323b5d4c32345ced77393b3530b1eed0f346429d")) // is valid: true
	fmt.Printf("is valid: %v\n", re.MatchString("0xZYXb5d4c32345ced77393b3530b1eed0f346429d")) // is valid: false
	//验证输入的地址
	if !re.MatchString("0x00000000219ab540356cBB839Cbe05303d7705Fa") {
		errors.New("以太坊地址不正确！")
		ctx.JSON(http.StatusOK, gin.H{
			"msg": "以太坊地址不正确",
		})
	}
	//获取地址字节码，检查是否为合约地址
	address := common.HexToAddress("0x00000000219ab540356cBB839Cbe05303d7705Fa")
	bytecode, err := u.ethClient.CodeAt(context.Background(), address, nil)
	if err != nil {
		log.Fatal(err)
	}
	//如果返回的 bytecode 长度大于0，说明该地址部署了智能合约。如果 bytecode 长度为0，说明该地址是一个普通钱包地址。
	isContract := len(bytecode) > 0
	fmt.Printf("is contract %V\n", isContract)
}

// CheckBlock 查看区块
func (u *UserHandler) CheckBlock(ctx *gin.Context) {
	// 传入 nil 返回最新的区块头
	header, err := u.ethClient.HeaderByNumber(context.Background(), nil)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("最新的区块号是：", header.Number.String()) //7146892

	//获取完整区块 如：区块号，区块时间戳，区块摘要，区块难度以及交易列表
	blockNumber := big.NewInt(7146892)
	block, err := u.ethClient.BlockByNumber(context.Background(), blockNumber)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("区块号: %d\n", block.Number().Uint64())
	fmt.Printf("区块时间戳: %d (Unix 时间戳)\n", block.Time())
	fmt.Printf("区块难度: %d\n", block.Difficulty().Uint64())
	fmt.Printf("区块哈希: %s\n", block.Hash().Hex())
	fmt.Printf("交易数量: %d\n", len(block.Transactions()))

	//调用 Transaction 只返回一个区块的交易数目。
	count, err := u.ethClient.TransactionCount(context.Background(), block.Hash())
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("区块的交易数目", count)
}

// CheckTransactions 查询交易
func (u *UserHandler) CheckTransactions(ctx *gin.Context) {
	blockNumber := big.NewInt(7146892)
	block, err := u.ethClient.BlockByNumber(context.Background(), blockNumber)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("区块哈希:", block.Hash().Hex()) // 打印区块哈希
	for i, tx := range block.Transactions() {
		if i == 4 {
			break
		}
		fmt.Printf("交易 %d:\n", i+1)
		fmt.Printf("  哈希: %s\n", tx.Hash().Hex())
		fmt.Printf("  数量 (Value): %s wei\n", tx.Value().String())
		fmt.Printf("  Gas 限制: %d\n", tx.Gas())
		fmt.Printf("  Gas 价格: %d wei\n", tx.GasPrice().Uint64())
		fmt.Printf("  Nonce: %d\n", tx.Nonce())
		fmt.Printf("  数据 (Data): %x\n", tx.Data())
		if tx.To() != nil {
			fmt.Printf("  接收地址: %s\n", tx.To().Hex())
		} else {
			fmt.Println("  接收地址: (合约创建交易)")
		}
		fmt.Println("-------------------------")

		//获取发送者地址
		chainID, err := u.ethClient.NetworkID(context.Background())
		if err != nil {
			log.Fatal(err)
		}
		// types.Sender 方法获取交易的发送者地址. 使用 EIP155Signer 来根据网络链 ID 来签名交易，从而提取发送者地址。
		if sender, err := types.Sender(types.NewEIP155Signer(chainID), tx); err == nil {
			fmt.Println("sender", sender.Hex())
		}
		// 获取交易数据 TransactionReceipt 获取交易的收据，它包含了交易的执行结果和状态信息
		receipt, err := u.ethClient.TransactionReceipt(context.Background(), tx.Hash())
		if err != nil {
			log.Fatal(err)
		}
		fmt.Println("你是啥：", receipt.Status) //执行结果
	}
	// 获取区块中的交易数量 TransactionCount 获取指定区块（通过 blockHash 指定）的交易数量。该方法返回区块中包含的交易总数。
	blockHash := common.HexToHash("0xf7219b984ead83cf52243d70292302cb2d9d80c08298a29e061925174e75d429") //这里的哈希是区块哈希，不是交易哈希
	count, err := u.ethClient.TransactionCount(context.Background(), blockHash)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("Transaction Count:", count)
	//遍历区块中的所有交易
	for idx := uint(0); idx < count; idx++ {
		if idx == 4 {
			break
		}
		tx, err := u.ethClient.TransactionInBlock(context.Background(), blockHash, idx)
		if err != nil {
			log.Fatal(err)
		}
		//fmt.Printf("Transaction: %+v\n", tx)
		fmt.Println("就是你", tx.Hash().Hex())
	}
	//获取单个交易的详细信息
	txHash := common.HexToHash("0x3802c067d3b57db2e8b82c9dc3f263ef97046ea613c0a0e5eb531bdee1dfb6ea") // 这里是交易哈希
	tx, isPending, err := u.ethClient.TransactionByHash(context.Background(), txHash)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println(tx.Hash().Hex()) // 打印交易哈希
	fmt.Println(isPending)       // 打印交易是否在待处理队列中
}

// TransferETH 以太坊
func (u *UserHandler) TransferETH(ctx *gin.Context) {
	// 使用 crypto.HexToECDSA 加载私钥. 返回一个 privateKey，用于签名交易。
	privateKey, err := crypto.HexToECDSA("6701523d74c4790a71***d80651bf31b9fc24d0232f7f2662ea02411****")
	if err != nil {
		log.Fatal(err)
	}
	//获取公钥地址
	publicKey := privateKey.Public()
	publicKeyECDSA, ok := publicKey.(*ecdsa.PublicKey)
	if !ok {
		log.Fatal("cannot assert type: publicKey is not of type *ecdsa.PublicKey")
	}
	//使用 crypto.PubkeyToAddress 将公钥转化为地址，即交易的发送方地址。  如果公钥类型无法转换为 *ecdsa.PublicKey，则报错。
	fromAddress := crypto.PubkeyToAddress(*publicKeyECDSA)
	fmt.Println("看看地址", fromAddress)

	//读取应该用于帐户交易的随机数。
	/**
	nonce 是交易的唯一标识符，用于防止重放攻击。它是发送方地址在链上的交易数量。
	使用 PendingNonceAt 获取待处理交易的 nonce 值。
	如果获取失败，会抛出错误。
	*/
	nonce, err := u.ethClient.PendingNonceAt(context.Background(), fromAddress)
	if err != nil {
		log.Fatal(err)
	}
	//设置交易细节
	/**
	value 设置为 0.01 ETH（10,000,000,000,000,000 wei）。
	gasLimit 设置为 21,000 wei，这是标准的转账交易的 Gas 限制。
	gasPrice 使用 ethClient.SuggestGasPrice 获取当前网络建议的 Gas 价格。
	*/
	value := big.NewInt(10000000000000000) // in wei (1 eth)
	gasLimit := uint64(21000)
	gasPrice, err := u.ethClient.SuggestGasPrice(context.Background())
	if err != nil {
		log.Fatal(err)
	}
	// 设置目标地址 将 ETH 发送给谁。
	toAddress := common.HexToAddress("0xCA690381a3Ea245BfA6a3DE8823133260bCA572A")
	// 生成未签名的交易 包含发送者地址、接收者地址、转账金额、Gas 限制、Gas 价格等信息。
	tx := types.NewTransaction(nonce, toAddress, value, gasLimit, gasPrice, nil)
	// 使用发件人的私钥对事务进行签名
	/**
	获取网络的链 ID（主网、测试网等）。
	使用 types.SignTx 方法，使用发送者的私钥和链 ID 对交易进行签名，生成已签名的交易 signedTx。
	*/
	chainID, err := u.ethClient.NetworkID(context.Background())
	if err != nil {
		log.Fatal(err)
	}
	signedTx, err := types.SignTx(tx, types.NewEIP155Signer(chainID), privateKey)
	if err != nil {
		log.Fatal(err)
	}
	// 广播交易 调用“SendTransaction”来将已签名的事务广播到整个网络
	/**
	使用 ethClient.SendTransaction 将已签名的交易广播到以太坊网络。
	如果交易发送失败，会抛出错误。
	最后，打印出交易的哈希（交易的唯一标识符），表示交易已发送。
	*/
	err = u.ethClient.SendTransaction(context.Background(), signedTx)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("tx sent: %s", signedTx.Hash().Hex())
	/**
	总结
	该代码实现了以下步骤：
	加载私钥并从中生成发送方地址。
	获取发送方地址的 nonce，以确保交易的唯一性。
	设置转账的目标地址、金额、Gas 限制和 Gas 价格等参数。
	使用发送方的私钥对交易进行签名。
	将签名的交易广播到以太坊网络并打印交易哈希。
	*/
}

// TokenTransfer 代币转账
func (u *UserHandler) TokenTransfer(ctx *gin.Context) {
	// 使用 crypto.HexToECDSA 加载私钥. 返回一个 privateKey，用于签名交易。
	privateKey, err := crypto.HexToECDSA("6701523d74c4790a71f4e8d/bf31b9fc24d0232f7f2662ea02411e9b01")
	if err != nil {
		log.Fatal(err)
	}
	//获取公钥地址
	publicKey := privateKey.Public()
	publicKeyECDSA, ok := publicKey.(*ecdsa.PublicKey)
	if !ok {
		log.Fatal("cannot assert type: publicKey is not of type *ecdsa.PublicKey")
	}
	//使用 crypto.PubkeyToAddress 将公钥转化为地址，即交易的发送方地址。  如果公钥类型无法转换为 *ecdsa.PublicKey，则报错。
	fromAddress := crypto.PubkeyToAddress(*publicKeyECDSA)
	//交易账户的随机数
	nonce, err := u.ethClient.PendingNonceAt(context.Background(), fromAddress)
	if err != nil {
		log.Fatal(err)
	}
	//交易细节
	value := big.NewInt(0) // in wei (1 eth)
	//gasLimit := uint64(21000)
	gasPrice, err := u.ethClient.SuggestGasPrice(context.Background())
	if err != nil {
		log.Fatal(err)
	}
	toAddress := common.HexToAddress("0xCA690381a3Ea245BfA6a3DE8823133260bCA572A")
	tokenAddress := common.HexToAddress("0xfD2da79adb9109fe8fe66b5270cf2e68b59e6237")
	//生成 ERC-20 transfer 方法的函数签名
	/**
	transfer(address,uint256) 是 ERC-20 合约中的 transfer 方法，用于发送代币。
	使用 sha3.NewKeccak256 计算方法签名的 Keccak-256 哈希值。methodID 是哈希值的前 4 个字节（这是以太坊 ABI 编码的规则，用于标识方法）。
	*/
	transferFnSignature := []byte("transfer(address,uint256)")
	hash := sha3.NewLegacyKeccak256()
	hash.Write(transferFnSignature)
	methodID := hash.Sum(nil)[:4]
	fmt.Println(hexutil.Encode(methodID))
	//将接收地址和转账金额填充为 32 字节
	paddedAddress := common.LeftPadBytes(toAddress.Bytes(), 32)
	fmt.Println("paddedAddress", hexutil.Encode(paddedAddress))
	//设置代币数量
	amountTokens := big.NewInt(100)
	decimals := big.NewInt(18)
	// 转换成最小单位 wei
	multiplier := new(big.Int).Exp(big.NewInt(10), decimals, nil)
	amount := new(big.Int).Mul(amountTokens, multiplier)
	paddedAmount := common.LeftPadBytes(amount.Bytes(), 32)
	fmt.Println(hexutil.Encode(paddedAmount))
	//构造交易数据
	var data []byte
	data = append(data, methodID...)
	data = append(data, paddedAddress...)
	data = append(data, paddedAmount...)
	//估算 Gas Limit
	/**
	使用 EstimateGas 方法估算执行这笔交易所需要的 Gas 数量。
	ethereum.CallMsg 包含了目标地址和数据，EstimateGas 会计算并返回适当的 Gas 限制。
	*/
	//gasLimit, err := u.ethClient.EstimateGas(context.Background(), ethereum.CallMsg{
	//	To:   &toAddress,
	//	Data: data,
	//})
	//if err != nil {
	//	log.Fatal(err)
	//}
	adjustedGasLimit := uint64(60000) // 增加10%的余量
	fmt.Println("gas 总量", adjustedGasLimit)
	fmt.Println("nonce", nonce)
	fmt.Println("交易细节", value)
	fmt.Println("gasPrice", gasPrice)
	fmt.Println("tokenAddress", tokenAddress)
	//构造并签名交易
	/**
	使用 types.NewTransaction 创建一个新的交易，指定交易的 nonce、目标地址（ERC-20 合约地址）、金额（0 ETH）、Gas 限制、Gas 价格和交易数据（即调用合约的 transfer 方法）。
	使用 types.SignTx 方法，使用私钥对交易进行签名。
	*/
	tx := types.NewTransaction(nonce, tokenAddress, value, adjustedGasLimit, gasPrice, data)

	chainID, err := u.ethClient.NetworkID(context.Background())
	if err != nil {
		log.Fatal(err)
	}

	signedTx, err := types.SignTx(tx, types.NewEIP155Signer(chainID), privateKey)
	if err != nil {
		log.Fatal(err)
	}
	//发送交易 使用 client.SendTransaction 将已签名的交易广播到网络中。
	err = u.ethClient.SendTransaction(context.Background(), signedTx)
	if err != nil {
		log.Fatal(err)
	}
	//输出交易哈希
	fmt.Printf("tx sent: %s", signedTx.Hash().Hex()) //
}

// Subscribe 订阅新区块
func (u *UserHandler) Subscribe(ctx *gin.Context) {
	client, err := ethclient.Dial("wss://sepolia.infura.io/ws/v3/5cfcf36740804b5f92e934d6a2ba77c8")
	if err != nil {
		log.Fatal(err)
	}

	//创建一个新的通道，用于接收最新的区块头。
	headers := make(chan *types.Header)
	//SubscribeNewHead 方法用来订阅新的区块头（即区块链上新增的区块）。每当一个新区块被挖矿成功并广播到网络时，这个订阅会接收到新区块的头部信息，并将其放入 headers 通道。
	sub, err := client.SubscribeNewHead(context.Background(), headers)
	if err != nil {
		log.Fatal(err)
	}
	//循环处理新区块头和区块信息：
	/**
	使用 select 语句等待 sub.Err() 和 headers 通道中的数据
		-如果订阅发生错误（sub.Err()），则会捕获并输出错误。
		-如果接收到新区块头（header := <-headers），则获取区块的详细信息。

	*/
	for {
		select {
		case err := <-sub.Err():
			log.Fatal(err)
		case header := <-headers:
			fmt.Println(header.Hash().Hex())
			block, err := client.BlockByHash(context.Background(), header.Hash())
			if err != nil {
				log.Fatal(err)
			}
			fmt.Printf("区块哈希值: %s\n", block.Hash().Hex())           // 使用 %s 输出区块哈希值，格式化为字符串
			fmt.Printf("区块编号 (高度): %d\n", block.Number().Uint64())  // 输出区块编号
			fmt.Printf("区块时间戳 (UNIX 时间): %d\n", block.Time())       // 输出区块的时间戳（UNIX格式）
			fmt.Printf("区块的 Nonce: %s\n", block.Nonce())            // 输出区块的 nonce 值
			fmt.Printf("区块中的交易数量: %d\n", len(block.Transactions())) // 输出区块中交易的数量
		}
	}
}

// TransactionRawCreate 构建原始交易
func (u *UserHandler) TransactionRawCreate(ctx *gin.Context) {
	// 使用 crypto.HexToECDSA 加载私钥. 返回一个 privateKey，用于签名交易。
	privateKey, err := crypto.HexToECDSA("6701523d74c4790a71f4e8d1d80651bf31b9fc24d0232f7f2662ea02411e9b01")
	if err != nil {
		log.Fatal(err)
	}
	//获取公钥地址
	publicKey := privateKey.Public()
	publicKeyECDSA, ok := publicKey.(*ecdsa.PublicKey)
	if !ok {
		log.Fatal("cannot assert type: publicKey is not of type *ecdsa.PublicKey")
	}
	//使用 crypto.PubkeyToAddress 将公钥转化为地址，即交易的发送方地址。  如果公钥类型无法转换为 *ecdsa.PublicKey，则报错。
	fromAddress := crypto.PubkeyToAddress(*publicKeyECDSA)
	fmt.Println("看看地址", fromAddress)
	//读取应该用于帐户交易的随机数。
	/**
	nonce 是交易的唯一标识符，用于防止重放攻击。它是发送方地址在链上的交易数量。
	使用 PendingNonceAt 获取待处理交易的 nonce 值。
	如果获取失败，会抛出错误。
	*/
	nonce, err := u.ethClient.PendingNonceAt(context.Background(), fromAddress)
	if err != nil {
		log.Fatal(err)
	}
	//设置交易细节
	/**
	value 设置为 0.01 ETH（10,000,000,000,000,000 wei）。
	gasLimit 设置为 21,000 wei，这是标准的转账交易的 Gas 限制。
	gasPrice 使用 ethClient.SuggestGasPrice 获取当前网络建议的 Gas 价格。
	*/
	value := big.NewInt(10000000000000000) // in wei (1 eth)
	gasLimit := uint64(60000)
	gasPrice, err := u.ethClient.SuggestGasPrice(context.Background())
	if err != nil {
		log.Fatal(err)
	}
	// 设置目标地址 将 ETH 发送给谁。
	toAddress := common.HexToAddress("0xCA690381a3Ea245BfA6a3DE8823133260bCA572A")
	tx := types.NewTransaction(nonce, toAddress, value, gasLimit, gasPrice, nil)
	chainID, err := u.ethClient.NetworkID(context.Background())
	if err != nil {
		log.Fatal(err)
	}
	// 使用私钥对交易进行签名，签名后交易变为一个“已签名”交易对象。
	signedTx, err := types.SignTx(tx, types.NewEIP155Signer(chainID), privateKey)
	if err != nil {
		log.Fatal(err)
	}
	// 获取 RLP 编码的交易数据  将签名后的交易序列化为 RLP 编码格式的字节数据
	rawTxBytes, err := signedTx.MarshalBinary()
	if err != nil {
		log.Fatal(err)
	}
	// 将 RLP 编码的交易数据转换为十六进制字符串
	// 使用 hex.EncodeToString 将 RLP 编码的字节数据转换为十六进制字符串 rawTxHex。这就是交易的原始数据，它可以用于广播到以太坊网络
	rawTxHex := hex.EncodeToString(rawTxBytes)
	// 打印交易的 RLP 编码
	fmt.Printf("RLP 编码 %s", rawTxHex) //f86e128405364ab1...68750c50fe5c3029e
	/**
	流程总结：
	加载私钥：通过 crypto.HexToECDSA 将十六进制私钥字符串转换为 ecdsa.PrivateKey 对象。
	获取公钥地址：通过 privateKey.Public() 获取公钥并转换为地址。
	获取交易 nonce：使用 ethClient.PendingNonceAt 获取待处理的交易 nonce，确保每个交易有唯一标识符。
	设置交易参数：定义交易的金额、Gas 限制、Gas 价格、目标地址等。
	创建交易对象：使用 types.NewTransaction 创建交易对象。
	签名交易：使用 types.SignTx 和私钥对交易进行签名。
	获取 RLP 编码：通过 signedTx.MarshalBinary 获取交易的 RLP 编码，并将其转换为十六进制字符串。
	打印 RLP 编码：打印 RLP 编码后的交易数据，可以用于广播到以太坊网络。
	最终，生成的 RLP 编码的交易可以用于将交易发送到以太坊网络，进行确认和执行。
	*/
}

// TransactionRawSendreate 发送原始交易事务
func (u *UserHandler) TransactionRawSendreate(ctx *gin.Context) {
	// Step 1: 定义一个包含交易的原始十六进制字符串
	rawTx := "f86e128405364ab182ea6094ca690381a3ea245bfa6a3de8823133260bca572a872386f26fc10000808401546d71a0dd3751e81dace9a108d6a560d8b54d8b944bf4043d9bcc1ccc4f4d1ae2cfd8fea06ccc5360edfe806e6a5dede994a1a72bffad6256abcda2468750c50fe5c3029e"
	// Step 2: 将十六进制的字符串解码为字节数组
	rawTxBytes, err := hex.DecodeString(rawTx)
	if err != nil {
		log.Fatal("hex.DecodeString failed: ", err)
	}
	// Step 3: 新建一个交易对象
	tx := new(types.Transaction)
	// Step 4: 使用 RLP 解码字节数据到 Transaction 对象
	rlp.DecodeBytes(rawTxBytes, &tx)
	// Step 5: 通过以太坊客户端发送交易
	err = u.ethClient.SendTransaction(context.Background(), tx)
	if err != nil {
		log.Fatal(err)
	}
	// Step 6: 打印交易哈希
	fmt.Printf("tx sent: %s", tx.Hash().Hex())
	/**
	这段代码的目的是通过 RLP 编码格式的原始交易数据发送一笔交易。
	主要流程：
	获取原始交易数据（十六进制字符串）。
	将十六进制字符串解码为字节数组。
	使用 RLP 解码函数将字节数据解码为交易对象。
	使用以太坊客户端发送解码后的交易。
	如果交易发送成功，输出交易的哈希值。
	*/
}

// ContractDeploy 部署智能合约
func (u *UserHandler) ContractDeploy(ctx *gin.Context) {
	// 使用 crypto.HexToECDSA 加载私钥. 返回一个 privateKey，用于签名交易。
	privateKey, err := crypto.HexToECDSA("6701523d74c4790a71f4e8d1d80651bf31b9fc24d0232f7f2662ea02411e9b01")
	if err != nil {
		log.Fatal(err)
	}
	//获取公钥地址
	publicKey := privateKey.Public()
	publicKeyECDSA, ok := publicKey.(*ecdsa.PublicKey)
	if !ok {
		log.Fatal("cannot assert type: publicKey is not of type *ecdsa.PublicKey")
	}
	//使用 crypto.PubkeyToAddress 将公钥转化为地址，即交易的发送方地址。  如果公钥类型无法转换为 *ecdsa.PublicKey，则报错。
	fromAddress := crypto.PubkeyToAddress(*publicKeyECDSA)
	fmt.Println("看看地址", fromAddress)
	nonce, err := u.ethClient.PendingNonceAt(context.Background(), fromAddress)
	if err != nil {
		log.Fatal(err)
	}
	gasPrice, err := u.ethClient.SuggestGasPrice(context.Background())
	if err != nil {
		log.Fatal(err)
	}

	auth := bind.NewKeyedTransactor(privateKey)
	auth.Nonce = big.NewInt(int64(nonce))
	auth.Value = big.NewInt(0)
	auth.GasLimit = uint64(300000)
	auth.GasPrice = gasPrice

	input := "1.0"
	address, tx, instance, err := pkgStore.DeployStore(auth, u.ethClient, input)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("地址", address.Hex())
	fmt.Println("tx address", tx.Hash().Hex())
	_ = instance
}

// LoadContract 加载智能合约 + 查询智能合约
func (u *UserHandler) LoadContract(ctx *gin.Context) {
	address := common.HexToAddress("0x135765bEC9A17B12841389a727092552598ed6D5")
	instance, err := pkgStore.NewStore(address, u.ethClient)
	if err != nil {
		log.Fatal(err)
	}
	version, err := instance.Version(nil)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("这好像是个版本", version)
}

// WriteContract 智能合约写入
func (u *UserHandler) WriteContract(ctx *gin.Context) {
	privateKey, err := crypto.HexToECDSA("6701523d74c4790a71f4e8d1d80651bf31b9fc24d0232f7f2662ea02411e9b01")
	if err != nil {
		log.Fatal(err)
	}
	publicKey := privateKey.Public()
	publicKeyECDSA, ok := publicKey.(*ecdsa.PublicKey)
	if !ok {
		log.Fatal("cannot assert type: publicKey is not of type *ecdsa.PublicKey")
	}
	fromAddress := crypto.PubkeyToAddress(*publicKeyECDSA)
	nonce, err := u.ethClient.PendingNonceAt(context.Background(), fromAddress)
	if err != nil {
		log.Fatal(err)
	}
	gasPrice, err := u.ethClient.SuggestGasPrice(context.Background())
	if err != nil {
		log.Fatal(err)
	}
	//接受私钥
	auth := bind.NewKeyedTransactor(privateKey)
	//设置 keyed transactor 的标准交易选项
	auth.Nonce = big.NewInt(int64(nonce))
	auth.Value = big.NewInt(0)
	auth.GasLimit = uint64(300000)
	auth.GasPrice = gasPrice

	address := common.HexToAddress("0x135765bEC9A17B12841389a727092552598ed6D5")
	instance, err := pkgStore.NewStore(address, u.ethClient)
	if err != nil {
		log.Fatal(err)
	}
	key := [32]byte{}
	value := [32]byte{}
	copy(key[:], []byte("foo"))
	copy(value[:], []byte("bar"))

	tx, err := instance.SetItem(auth, key, value)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Printf("tx sent: %s\n", tx.Hash().Hex())
	//验证键/值是否已设置，我们可以读取智能合约中的值。
	result, err := instance.Items(nil, key)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println(string(result[:]))
}

// ReadContract 读取智能合约的字节码
func (u *UserHandler) ReadContract(ctx *gin.Context) {
	contractAddress := common.HexToAddress("0x135765bEC9A17B12841389a727092552598ed6D5")

	bytecode, err := u.ethClient.CodeAt(context.Background(), contractAddress, nil)
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println("合约的字节码：", hex.EncodeToString(bytecode))
}

// SubLog 订阅事件日志
func (u *UserHandler) SubLog(ctx *gin.Context) {
	client, err := ethclient.Dial("wss://sepolia.infura.io/ws/v3/5cfcf36740804b5f92e934d6a2ba77c8")
	if err != nil {
		log.Fatal(err)
	}
	contractAddress := common.HexToAddress("0x147B8eb97fD247D06C4006D269c90C1908Fb5D54")
	query := ethereum.FilterQuery{
		Addresses: []common.Address{contractAddress},
	}
	//接收事件的方式是通过 Go channel
	logs := make(chan types.Log)
	sub, err := client.SubscribeFilterLogs(context.Background(), query, logs)
	if err != nil {
		log.Fatal(err)
	}
	//连续循环来读入新的日志事件或订阅错误。
	for {
		select {
		case err := <-sub.Err():
			log.Fatal(err)
		case vLog := <-logs:
			fmt.Println(vLog)
		}
	}
}

// ReadLogsEvent 读取日志事件
func (u *UserHandler) ReadLogsEvent() {
	client, err := ethclient.Dial("wss://sepolia.infura.io/ws/v3/5cfcf36740804b5f92e934d6a2ba77c8")
	if err != nil {
		log.Fatal(err)
	}
	contractAddress := common.HexToAddress("0x147B8eb97fD247D06C4006D269c90C1908Fb5D54")
	query := ethereum.FilterQuery{
		//FromBlock 和 ToBlock：定义了区块范围，这里查询的是区块 2394201
		FromBlock: big.NewInt(2394201),
		ToBlock:   big.NewInt(2394201),
		//定义了过滤的地址，即只关注这个智能合约地址的事件日志
		Addresses: []common.Address{
			contractAddress,
		},
	}
	//获取指定区块范围内的日志 client.FilterLogs 用于根据 query 中指定的过滤条件，从区块链上检索日志。
	logs, err := client.FilterLogs(context.Background(), query)
	if err != nil {
		log.Fatal(err)
	}
	//解析智能合约的 ABI
	contractAbi, err := abi.JSON(strings.NewReader(string(pkgStore.StoreABI)))
	if err != nil {
		log.Fatal(err)
	}
	//遍历并解码事件日志
	for _, vLog := range logs {
		fmt.Println(vLog.BlockHash.Hex())
		fmt.Println(vLog.BlockNumber)
		fmt.Println(vLog.TxHash.Hex())
		//使用 ABI 解析 vLog.Data 数据部分，并将其解码为一个结构体 event
		event := struct {
			Key   [32]byte
			Value [32]byte
		}{}
		//将日志的数据部分解码到 event 结构体中，并通过 ItemSet 事件的名称进行匹配。
		err := contractAbi.UnpackIntoInterface(&event, "ItemSet", vLog.Data)
		if err != nil {
			log.Fatal(err)
		}
		//打印解码出来的 Key 和 Value。假设这两者的值是 "foo" 和 "bar"，它们会被转换为字符串后打印。
		fmt.Println(string(event.Key[:]))   // foo
		fmt.Println(string(event.Value[:])) // bar
		//遍历 vLog.Topics，并打印第一个主题 topics[0]。日志事件通常有多个主题（topics），其中第一个主题通常是事件的签名或索引字段。
		var topics [4]string
		for i := range vLog.Topics {
			topics[i] = vLog.Topics[i].Hex()
		}
		fmt.Println(topics[0])
	}
	//计算事件签名的 Keccak256 哈希
	/**
	eventSignature 是事件的签名（即事件名称和参数类型），ItemSet(bytes32,bytes32) 表示一个名为 ItemSet 的事件，它有两个 bytes32 类型的参数。
	crypto.Keccak256Hash 计算事件签名的 Keccak256 哈希值，返回的哈希是事件标识符，用于区分不同的事件。
	*/
	eventSignature := []byte("ItemSet(bytes32,bytes32)")
	hash := crypto.Keccak256Hash(eventSignature)
	fmt.Println(hash.Hex())
	/**
	这段代码的流程是：
		连接到 Infura 提供的 WebSocket 服务（Sepolia 测试网络）。
		根据指定的区块范围和合约地址，获取区块链上的日志事件。
		使用合约的 ABI 解析日志数据，解码事件的 Key 和 Value 字段。
		输出日志的详细信息（包括区块哈希、交易哈希、事件数据等）。
		计算并打印 ItemSet 事件签名的 Keccak256 哈希，用于验证或识别该事件。
	*/
}
