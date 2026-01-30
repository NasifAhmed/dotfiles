package tournament

import "testing"

func TestRepeat(t *testing.T) {
	scores := [5]int{10, 15, 20, 12, 18}
	got := CalculateTotal(scores)
	want := 75

	if got != want {
		t.Errorf("got %q but wanted %q", got, want)
	}
}
