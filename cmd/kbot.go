/*
Copyright © 2024 NAME HERE <EMAIL ADDRESS>
*/
package cmd

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"strings"
	"time"

	"github.com/joho/godotenv"
	"github.com/spf13/cobra"
	telebot "gopkg.in/telebot.v3"
)

var (
	TeleToken = os.Getenv("TELE_TOKEN")
	// TeleToken = goDotEnvVariable("TELE_TOKEN")
)

// kbotCmd represents the kbot command
var kbotCmd = &cobra.Command{
	Use:     "kbot",
	Aliases: []string{"start"},
	Short:   "A brief description of your command",
	Long: `A longer description that spans multiple lines and likely contains examples
and usage of using your command. For example:

Cobra is a CLI library for Go that empowers applications.
This application is a tool to generate the needed files
to quickly create a Cobra application.`,
	Run: func(cmd *cobra.Command, args []string) {

		fmt.Printf("kbot %s started", appVersion)
		kbot, err := telebot.NewBot(telebot.Settings{
			URL:    "",
			Token:  TeleToken,
			Poller: &telebot.LongPoller{Timeout: 10 * time.Second},
		})

		if err != nil {
			log.Fatalf("Please check the token value: %s", err)
			return
		}

		kbot.Handle(telebot.OnText, func(ctx telebot.Context) error {
			log.Print(ctx.Message().Payload, ctx.Text())

			command := strings.Split(ctx.Text(), " ")

			switch command[0] {
			case "/hello":
				err = ctx.Send(fmt.Sprintf("Hello! I'm kbot-go %s version", appVersion))
			case "/capital":
				err = ctx.Send(getCapitalCity(command[1]))
			}

			return err
		})

		kbot.Start()
	},
}

type Country struct {
	Capital []string `json:"capital"`
}

func init() {
	rootCmd.AddCommand(kbotCmd)

	// Here you will define your flags and configuration settings.

	// Cobra supports Persistent Flags which will work for this command
	// and all subcommands, e.g.:
	// kbotCmd.PersistentFlags().String("foo", "", "A help for foo")

	// Cobra supports local flags which will only run when this command
	// is called directly, e.g.:
	// kbotCmd.Flags().BoolP("toggle", "t", false, "Help message for toggle")
}

func goDotEnvVariable(key string) string {

	// load .env file
	err := godotenv.Load(".env")

	if err != nil {
		log.Fatalf("Error loading .env file")
	}

	return os.Getenv(key)
}

func getCapitalCity(country string) string {
	url := fmt.Sprintf("https://restcountries.com/v3.1/name/%s?fields=capital", country)

	req, err := http.NewRequest(http.MethodGet, url, nil)
	if err != nil {
		fmt.Printf("client: could not create request: %s\n", err)
		os.Exit(1)
	}

	req.Header.Set("Accept", "application/json")

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		log.Fatalln(err)
	}

	defer resp.Body.Close()

	res, err := http.DefaultClient.Do(req)

	if err != nil {
		fmt.Printf("client: error making http request: %s\n", err)
		os.Exit(1)
	}

	var countryObject []Country
	json.NewDecoder(res.Body).Decode(&countryObject)

	// fmt.Printf("Capital: %s", countryObject[0].Capital[0])

	return fmt.Sprintf("The capital of %s is %s", strings.ToUpper(country), countryObject[0].Capital[0])
}
