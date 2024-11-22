package main

import (
	"github.com/gin-gonic/gin"
	"level2/gin-example/internal/web"
	"log"
)

func main() {
	// 连接到 Infura 并创建 UserHandler
	infuraURL := "https://sepolia.infura.io/v3/5cfcf36740804b5f92e934d6a2ba77c8"
	userHandler, err := web.NewUserHandler(infuraURL)
	if err != nil {
		log.Fatal("Failed to connect to Infura:", err)
	}

	// 初始化 Web 服务器
	server := initWebServer()

	// 加载视图文件
	server.LoadHTMLGlob("gin-example/views/*") // 修正路径

	// 注册路由
	userHandler.RegisterRoutes(server)

	// 启动服务器
	if err := server.Run(":8080"); err != nil {
		log.Fatal("Failed to start server:", err)
	}
}

func initWebServer() *gin.Engine {
	// 初始化 gin 引擎并返回
	server := gin.Default()
	return server
}
