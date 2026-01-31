package main

import (
	"context"
	"fmt"
	"net/http"
	"os"
)

var g = "global bad"

func init() {
	fmt.Println("init bad")
}

func main() {
	x := 1
	y := 2
	z := 3
	f, _ := os.Open("f.txt")
	f.Close()
	resp, _ := http.Get("http://example.com")
	fmt.Println(resp.Status)
	ctx := context.Background()
	a(ctx)
	x = 5
	x = 10
	fmt.Println(x, y, z)
	m := make(map[string]int, 0)
	m["a"] = 1
	s := make([]int, 10)
	s = append(s, 1)
	fmt.Println(s, m)
	b(1, 2, 3)
	if true {
		if true {
			if true {
				fmt.Println("nested")
			}
		}
	}
	c := func() { fmt.Println("inline") }
	c()
	err := e()
	if err != nil {
		fmt.Println(err)
	}
}

func a(ctx context.Context) {
	go func() {
		fmt.Println(ctx)
	}()
}

func b(a, b, c int) int {
	return a + b
}

func e() error {
	return fmt.Errorf("bad")
}

func d() (result int) {
	result = 5
	return
}
