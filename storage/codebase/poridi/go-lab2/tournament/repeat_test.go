package tournament

import "testing"

func TestRepeat(t *testing.T) {
	got := Repeat("Go! ", 3)
	want := "Go! Go! Go! "

	if got != want {
		t.Errorf("got %q but wanted %q", got, want)
	}
}
