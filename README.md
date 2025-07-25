
# 🩺 Oxycare - Mobile (Projeto Acadêmico UFS)

Sistema completo de monitoramento de sinais vitais com comunicação via **Bluetooth BLE**, **backend em PHP + MySQL** e frontend desenvolvido em **Flutter**. Este projeto tem como objetivo permitir a visualização em **tempo real** de batimentos cardíacos, temperatura e oxigenação do paciente.

---
## 🧑‍🔬 Créditos do Projeto

### Inventores Fundadores
- Edward Moreno – [edmoreno@academic

### Mentores Técnicos
- Débora Maria Coelho Nascimento  
- Michel dos Santos Soares

### Time de Desenvolvimento
- Felipe Ferreira da Silva  
- Bruno Santana Andrade  
- Isaías Elias da Silva  
- Marcelo Santos da Cruz  
- Matheus Lima da Cruz  
- Mateus do Rosário Costa

### Especialistas
- Talita Leite dos Santos Moraes  
- Grace Anne Azevedo Dória

---
## 🧪 RESUMO DESCRITIVO (TUTORIAL COMPLETO)

### 🔧 Etapa 1 – Ambiente de Desenvolvimento

- Sistema Operacional: **Linux Ubuntu 22.04**  
- Editor: **Visual Studio Code**  
- SDK: **Flutter 3.x**  
- Terminal: Bash  
- Backend: **Servidor Apache com PHP 8.1**  
- Banco de dados: **MySQL 5.7**  
- Hospedagem para testes: **DDNS + Porta liberada no roteador**  
- Bluetooth: **Flutter Blue Plus** com comunicação serial BLE

---

### 📦 Etapa 2 – Instalação do Projeto no Linux

```bash
# Atualize seu sistema
sudo apt update && sudo apt upgrade -y

# Instale o Flutter (já adicionado ao PATH)
git clone https://github.com/flutter/flutter.git
export PATH="$PATH:`pwd`/flutter/bin"
flutter doctor


# Instale as dependências do projeto
flutter pub get

# Conecte seu celular via USB (ativar modo desenvolvedor)
flutter devices

# Rode o app
flutter run
```

---

### 🌐 Etapa 3 – Estrutura do Projeto

```text
oxycare_app/
├── lib/
│   ├── main.dart                    # Roteamento principal
│   ├── login_page.dart              # Tela de login
│   ├── tempo_real_page.dart         # Tela com dados ao vivo do protótipo via Bluetooth
│   ├── listar_perfis_page.dart      # Lista e seleção de perfis
│   ├── historico_page.dart          # Tela com gráficos históricos
│   ├── conexao_page.dart            # Status e pareamento Bluetooth
├── assets/                          # Imagens da aplicação
├── pubspec.yaml                     # Dependências do projeto
```

---

### 🧠 Etapa 4 – Tecnologias Utilizadas

| Tecnologia | Finalidade |
|-----------|------------|
| **Flutter** | Criação do app mobile |
| **Dart** | Lógica e componentes |
| **Flutter Blue Plus** | Comunicação com o dispositivo BLE |
| **Shared Preferences** | Armazenamento local de perfil selecionado |
| **PHP 8.1** | Backend simples com autenticação e persistência |
| **MySQL** | Banco de dados para usuários, perfis e histórico |
| **Postman / Curl** | Testes dos endpoints da API |
| **DDNS (noip.com)** | Tornar o servidor visível fora da rede local |

---

### 🔐 Etapa 5 – Autenticação via Login

- Os usuários fazem login com email e senha.
- O backend verifica se o usuário existe na tabela `usuarios`.
- Se estiver correto, redireciona para a tela `TempoRealPage`.

#### login.php (resumo):

```php
$email = $data["email"];
$senha = $data["senha"];

SELECT * FROM usuarios WHERE email = ?

if (password_verify($senha, $user['senha'])) {
  // retorna JSON com nome, tipo e ID do usuário
}
```

---

### 🧬 Etapa 6 – Comunicação com o Hardware (Protótipo BLE)

Na tela `TempoRealPage`:

1. O app inicia o escaneamento BLE.
2. Conecta automaticamente a dispositivos com nome **"PROTOTIPO"** ou **"OXYSENSOR"**.
3. Recebe dados como:

```
85;36.4;97
```

4. O app extrai os valores (bpm, temperatura, spo2), exibe na tela e envia via HTTP para o PHP:

```json
{
  "paciente_id": 5,
  "batimentos": 85,
  "temperatura": 36.4,
  "spo2": 97
}
```

---

### 📊 Etapa 7 – Visualização do Histórico

- Tela `HistoricoPage`
- Ao selecionar um perfil, consulta o histórico no servidor com base no `idPerfilSelecionado`.
- Exibe os dados em gráfico (ex: batimentos ao longo do tempo).

---

### 📡 Backend PHP (Resumo)

| Endpoint | Função |
|----------|--------|
| `login.php` | Autenticação do usuário |
| `receber_dados.php` | Recebe dados do BLE |
| `listar_perfis.php` | Lista perfis cadastrados |
| `historico.php` | Retorna histórico de sinais |

**Estrutura do banco:**
- `usuarios(id, nome, email, senha, tipo)`
- `perfis(id, nome, usuario_id)`
- `historico(id, paciente_id, batimentos, temperatura, spo2, data_hora)`

---

## 📥 Como Gerar o APK

```bash
flutter clean
flutter pub get
flutter build apk --release
```

O APK será gerado em:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## ✅ Funcionalidades Prontas

- [x] Login com email e senha  
- [x] Recepção de dados via Bluetooth BLE  
- [x] Envio automático para o servidor  
- [x] Seleção de perfis  
- [x] Armazenamento local do perfil  
- [x] Gráfico histórico por perfil  

---

## 💬 Considerações Finais

Este projeto acadêmico foi desenvolvido com foco em usabilidade, conectividade e escalabilidade, buscando simular um ambiente real de monitoramento médico. Todo o código está disponível neste repositório com instruções completas para quem quiser adaptar, evoluir ou contribuir.

> Desenvolvido com dedicação por alunos da Universidade Federal de Sergipe 💙

OBS: Este backend foi desenvolvido em PHP apenas para fins de teste e validação inicial. No entanto, poderá ser substituído futuramente por outra API construída com tecnologias diferentes, conforme a evolução do projeto e suas necessidades.
