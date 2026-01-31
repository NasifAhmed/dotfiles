package tournament

func CalculateTotal(scores [5]int) int {
	total := 0

	// for i := 0 ; i < 5 ; i++ {
	// 	total = total + scores[i]
	// }

	for _, scores := range scores {
		total += scores
	}

	return total
}
