package middleware

import (
	"github.com/gin-gonic/gin"
)

type LoginJWTMiddlewareBuilder struct {
	paths []string
}

func NewLoginJWTMiddlewareBuilder() *LoginJWTMiddlewareBuilder {
	return &LoginJWTMiddlewareBuilder{}
}

func (l *LoginJWTMiddlewareBuilder) IgnorePaths(path string) *LoginJWTMiddlewareBuilder {
	l.paths = append(l.paths, path)
	return l
}

func (l *LoginJWTMiddlewareBuilder) Build() gin.HandlerFunc {
	return func(ctx *gin.Context) {
		print("进入登录JWT中间件,当前路径：", ctx.Request.URL.Path)

		for _, p := range l.paths {
			if ctx.Request.URL.Path == p {
				ctx.Next()
				return
			}
		}

		ctx.JSON(401, gin.H{
			"message": "搞事？",
		})

	}
}
