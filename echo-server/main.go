package main

import (
	"io"
	"log/slog"
	"net"
)

func main() {
	addr := "localhost:42069"
	server, err := net.Listen("tcp", addr)
	if err != nil {
		slog.Error("failed to start server", slog.Any("err", err))
	}
	defer server.Close()

	slog.Info("Server is running", slog.String("addr", addr))

	for {
		conn, err := server.Accept()
		if err != nil {
			slog.Error("failed to accept conn", slog.Any("err", err))
			continue
		}

		go func(conn net.Conn) {
			defer func() {
				conn.Close()
			}()
			io.Copy(conn, conn)
		}(conn)
	}
}
