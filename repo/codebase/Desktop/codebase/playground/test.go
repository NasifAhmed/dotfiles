package main

import "fmt"

var x int

func main() {
	for i := range 10 {
		fmt.Println(fibo(i))
	}
}

func testFunc() int {
	x = 104
	return x
}

func fibo(n int) int {
	if n == 0 {
		return 0
	} else if n == 1 {
		return 1
	} else {
		return fibo(n-1) + fibo(n-2)
	}
}
