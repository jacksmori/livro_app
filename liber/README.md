# 📚 BookShelf App

Aplicativo Android de leitura de livros com **modo claro e escuro**, construído com **Flutter + Python (FastAPI)**.

---

## 📱 Telas implementadas

| Tela | Descrição |
|------|-----------|
| **Página Principal** | Logo + botões Login / Cadastre-se |
| **Login** | Header arredondado, email/senha |
| **Cadastro** | Nome, email, senha, confirmação |
| **Home** | Grid de livros, histórico, FAB |
| **Pesquisa** | Busca em tempo real + ações rápidas |
| **Livro (Click)** | Detalhes, capa, progresso, ações |
| **Livro (Leitura)** | Reader com controle de fonte e progresso |

---

## 🚀 Como rodar

### Backend (Python)

```bash
cd backend
pip install -r requirements.txt
python main.py
```

O servidor roda em `http://localhost:8000`.
Documentação automática: `http://localhost:8000/docs`

### Frontend (Flutter)

```bash
# Instalar dependências
flutter pub get

# Rodar no emulador Android
flutter run

# Build APK
flutter build apk --release
```

> **Nota:** No emulador Android, o endereço `10.0.2.2` aponta para `localhost` do computador.
> Para dispositivo físico, altere `baseUrl` em `lib/services/api_service.dart` para o IP da sua máquina.

---

## 🎨 Tema

### Modo Claro
- Background: `#F5F3EE` (bege quente)
- Primary: `#6B7C47` (verde oliva)
- Surface: `#FFFFFF`

### Modo Escuro
- Background: `#0D1410` (verde escuro profundo)
- Primary: `#6B7C47` (verde oliva)
- Surface: `#1A2218`

O tema é salvo automaticamente com `SharedPreferences` e persiste entre sessões.

---

## 🔑 API Endpoints

| Método | Rota | Descrição |
|--------|------|-----------|
| POST | `/auth/login` | Login |
| POST | `/auth/register` | Cadastro |
| POST | `/auth/logout` | Logout |
| GET | `/books` | Listar livros (com busca) |
| GET | `/books/favorites` | Favoritos do usuário |
| POST | `/books/{id}/favorite` | Toggle favorito |
| PUT | `/books/{id}/progress` | Salvar progresso |
| GET | `/health` | Health check |

---

## 📦 Estrutura do projeto

```
bookapp/
├── lib/
│   ├── main.dart               # Entry point
│   ├── theme/
│   │   ├── app_theme.dart      # Cores e temas claro/escuro
│   │   └── theme_provider.dart # Provider do tema
│   ├── models/
│   │   └── models.dart         # Book, User
│   ├── services/
│   │   └── api_service.dart    # HTTP client + mock data
│   ├── screens/
│   │   ├── landing_screen.dart
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── home_screen.dart
│   │   ├── search_screen.dart
│   │   ├── book_config_screen.dart
│   │   └── book_reader_screen.dart
│   └── widgets/
│       └── book_cover_widget.dart
├── backend/
│   ├── main.py                 # FastAPI app
│   └── requirements.txt
└── pubspec.yaml
```

---

## 📝 Modo offline

O app funciona em modo demo mesmo sem o backend rodando — os dados mock são retornados automaticamente quando a API não está disponível.