class User {
  String username;
  String password;

  User({required this.username, required this.password}); 

  // Tambahkan method untuk memeriksa username dan password
  bool checkCredential(String inputUsername, String inputPassword) {
    return (username == inputUsername && password == inputPassword);
  }
}

// Buat list untuk menyimpan data user
List<User> users = [
  User(username: "john", password: "123"),
  User(username: "jane", password: "456"),
  User(username: "doe", password: "789"),
];