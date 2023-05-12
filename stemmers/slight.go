package main

import (
	"bytes"
	"os"
	"os/exec"
)

func main() {
	arg := os.Args[1:]
	cmd := exec.Command("/home/l/gits/balaa/stemmers/arabicstemmer/bin/rootwords", "-l", "ar")
	buffer := bytes.Buffer{}
	buffer.Write([]byte(arg[0]))
	cmd.Stdin = &buffer
	cmd.Stdout = os.Stdout
	cmd.Run()

}
