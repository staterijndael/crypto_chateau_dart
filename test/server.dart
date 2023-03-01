import 'dart:io';

void main() {
  ServerSocket.bind('127.0.0.1', 8084).then(
    (serverSocket) {
      serverSocket.listen(
        (socket) {
          socket.listen(print);
        },
      );
    },
  );
}
