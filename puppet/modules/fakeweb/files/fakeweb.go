package main

import (
	"io"
	"time"
	"net/http"
)

func slow(w http.ResponseWriter, r *http.Request) {
	time.Sleep(800 * time.Millisecond)
	io.WriteString(w, "SLOW")
}

func ok(w http.ResponseWriter, r *http.Request) {
	io.WriteString(w, "OK")
}

func throwErr(w http.ResponseWriter, r *http.Request) {
	http.Error(w, "ERROR", 500)
}


func main() {
	mux := http.NewServeMux()
	mux.HandleFunc("/slow", slow)
	mux.HandleFunc("/", ok)
	mux.HandleFunc("/error", throwErr)
	http.ListenAndServe(":8000", mux)
}
