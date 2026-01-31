package main

import "fmt"


func main() {
	a := 0
	b := 0

	a_pointer := &a
	b_pointer := &b

	a_normal := a

	a_normal = 100

	*a_pointer = 9000

	fmt.Println(a)
	fmt.Println(a_pointer)
	fmt.Println(a_normal)
	fmt.Println(a_pointer)
	fmt.Println(b)
	fmt.Println(b_pointer)
}

