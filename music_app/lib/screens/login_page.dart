import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'song_list_page.dart'; // Ganti dengan nama file halaman song list
import 'package:music_app/models/user_model.dart'; 

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    if (username != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SongListPage()),
      );
    }
  }

  Future<void> _login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    // Iterasi list users dan gunakan checkCredential
    for (var user in users) { 
      if (user.checkCredential(username, password)) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', username);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SongListPage()),
        );
        return; // Keluar dari loop setelah login berhasil
      }
    }

    // Jika tidak ada user yang cocok
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Username atau password salah')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color.fromARGB(255, 2, 40, 71)!, const Color.fromARGB(255, 75, 2, 149)!],
          ),
        ),
        child: Center(
          child: SingleChildScrollView( // Agar keyboard tidak menutupi input
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/icon/WD.jpeg'), // Ganti dengan path logo Anda
                  ),
                  const SizedBox(height: 16.0),
                   // Text MUSIC APP
                  const Text(
                    'MUSIC APP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
           
                  const SizedBox(height: 32.0),
                  
                  // Username TextField
                  TextField(
                    controller: _usernameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'username',
                      hintStyle: const TextStyle(color: Colors.white54),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // Password TextField
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'password',
                      hintStyle: const TextStyle(color: Colors.white54),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32.0),
                  // Login Button
                  SizedBox(
                    width: double.infinity, // Membuat button selebar mungkin
                    child: ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        textStyle: const TextStyle(fontSize: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                      ),
                      child: const Text('Sign In', style: TextStyle(color: Colors.blue)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}