package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"regexp"
	"strings"

	"github.com/antchfx/htmlquery"
)

const (
	jokesNumber = 100
	jokesUrl    = "http://bash.org.pl/latest/?page"
	port        = ":9000"
)

type Joke struct {
	Id      string `json:"id"`
	Date    string `json:"date"`
	Content string `json:"content"`
}

var listJokesPath = regexp.MustCompile(`^\/jokes[\/]*$`)

func handleRequests() {
	http.HandleFunc("/jokes", returnJokes)
	log.Fatal(http.ListenAndServe(port, nil))
}

func returnJokes(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("content-type", "application/json")
	switch {
	case r.Method == http.MethodGet && listJokesPath.MatchString(r.URL.Path):
		getJokes(w)
		return
	default:
		httpError(w, "not found", http.StatusNotFound)
		return
	}
}

func getJokes(w http.ResponseWriter) {
	var Jokes []Joke
	page := 0
	limit := 10
	for len(Jokes) < jokesNumber {
		getPageJokes(&Jokes, page)
		page++
		if page > limit {
			break
		}
	}
	err := json.NewEncoder(w).Encode(Jokes[0:jokesNumber])
	if err != nil {
		httpError(w, "internal server error", http.StatusInternalServerError)
		return
	}
}

func getPageJokes(Jokes *[]Joke, page int) {
	url := fmt.Sprintf("%s=%d", jokesUrl, page)
	doc, err := htmlquery.LoadURL(url)
	log.Printf("Retrieving jokes from %s\n", url)
	if err != nil {
		log.Println(err)
	} else {
		for _, n := range htmlquery.Find(doc, `//div[contains(@class,"q post")]`) {

			id := htmlquery.SelectAttr(n, "id")

			dateNode := htmlquery.FindOne(n, `//div[contains(@class,"right")]`)
			date := strings.TrimSpace(htmlquery.InnerText(dateNode))

			contentNode := htmlquery.FindOne(n, `//div[contains(@class,"quote post-content post-body")]`)
			content := strings.TrimSpace(htmlquery.InnerText(contentNode))

			*Jokes = append(*Jokes, Joke{Id: id, Date: date, Content: content})
		}
	}
}

func httpError(w http.ResponseWriter, text string, status int) {
	w.WriteHeader(status)
	w.Write([]byte(text))
}

func main() {
	handleRequests()
}
