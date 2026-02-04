package main

import "fmt"

var x int

func main() {
	// x = 0
	// y := true
	//
	// fmt.Println("test")
	// fmt.Println(x)
	//
	// fmt.Println(testFunc())
	//
	// fmt.Println(x)
	// fmt.Println(y)
	//
	// for i := range 10 {
	// 	fmt.Println(fibo(i))
	// }
	//
	// for ii:=0 ; ii<100 ; ii++ {
	// 	fmt.Println(ii)
	// }

	const testConst = 100
	fmt.Println(testConst)

	fmt.Println("tst", true, 100)

	var a [100]int
	a[4] = 1000

	var b [3]bool
	b = [3]bool{true, false, true}

	var c [2]int = [2]int{1, 2}

	fmt.Println(a)
	fmt.Println(b)
	fmt.Println(c)
	fmt.Println(&a)
	fmt.Println(&b)
	fmt.Println(&c)
}

func testFunc() int {
	x = 100
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
