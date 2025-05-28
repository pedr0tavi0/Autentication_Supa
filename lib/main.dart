import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carrega o .env
  await dotenv.load(fileName: ".env");

  // Inicializa o Supabase com dados do .env
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supabase Auth Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AuthPage(),
    );
  }
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  String message = '';

  Future<void> signUp() async {
    setState(() {
      isLoading = true;
      message = '';
    });

    try {
      final AuthResponse response = await Supabase.instance.client.auth.signUp(
        email: emailController.text,
        password: passwordController.text,
      );

      setState(() {
        isLoading = false;
        message =
            'Usuário criado com sucesso! Verifique seu e-mail para confirmar.';
      });
    } catch (error) {
      setState(() {
        isLoading = false;
        message = 'Erro ao cadastrar: $error';
      });
    }
  }

  Future<void> signIn() async {
    setState(() {
      isLoading = true;
      message = '';
    });

    try {
      final AuthResponse response = await Supabase.instance.client.auth
          .signInWithPassword(
            email: emailController.text,
            password: passwordController.text,
          );

      setState(() {
        isLoading = false;
        message =
            'Login efetuado com sucesso! Bem-vindo ${response.user?.email}';
      });
    } catch (error) {
      setState(() {
        isLoading = false;
        message = 'Erro ao entrar: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Supabase Auth')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'E-mail'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            if (isLoading) const CircularProgressIndicator(),
            if (!isLoading)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: signUp,
                    child: const Text('Cadastrar'),
                  ),
                  ElevatedButton(
                    onPressed: signIn,
                    child: const Text('Entrar'),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            Text(message, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
