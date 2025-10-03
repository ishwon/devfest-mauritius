package main

import (
	"html/template"
	"net/http"
	"os"

	"github.com/gin-gonic/gin"
)

func main() {
	// Use release mode in containers by default
	if ginMode := os.Getenv("GIN_MODE"); ginMode == "" {
		gin.SetMode(gin.ReleaseMode)
	}

	r := gin.Default()

	// Serve static assets
	r.Static("/assets", "./public/assets")
	r.Static("/images", "./public/images")

	// Load templates
	t := template.Must(template.ParseFiles("templates/index.tmpl"))
	r.SetHTMLTemplate(t)

	r.GET("/", func(c *gin.Context) {
		c.HTML(http.StatusOK, "index.tmpl", gin.H{
			"title": "GDG DevFest Mauritius",
		})
	})

	// PORT for cloud run/GKE envs
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	_ = r.Run(":" + port)
}
