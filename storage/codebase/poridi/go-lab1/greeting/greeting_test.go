package greeting

import "testing"

func TestGreet(t *testing.T) {
	got := Greet("World", "casual")
	want := "Hello, World!"

	if got != want {
		t.Errorf("got %q but wanted %q", got, want)
	}
}

func TestGreetWithName(t *testing.T) {
	got := Greet("Karim", "casual")
	want := "Hello, Karim!"

	if got != want {
		t.Errorf("got %q but wanted %q", got, want)
	}
}

func TestGreetWithEmptyName(t *testing.T) {
	got := Greet("", "")
	want := "Hello, Poridhian!"

	if got != want {
		t.Errorf("got %q but wanted %q", got, want)
	}
}

func TestGreetCasual(t *testing.T) {
	got := Greet("Karim", "casual")
	want := "Hello, Karim!"

	if got != want {
		t.Errorf("got %q but wanted %q", got, want)
	}
}

func TestGreetFormal(t *testing.T) {
	got := Greet("Karim", "formal")
	want := "Good Day, Karim!"

	if got != want {
		t.Errorf("got %q but wanted %q", got, want)
	}
}
