package greeting

func Greet(name string, style string) string {
	if name == "" {
		name = "Poridhian"
	}

	return getPrefix(style)+name+"!"
}

func getPrefix(style string) string {
	switch style {
	case "casual":
		return "Hello, "
	case "formal":
		return "Good Day, "
		default :
		return "Hello, "

	}
}
