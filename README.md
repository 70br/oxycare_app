# 🩺 Cuidar+

O **Cuidar+** é um sistema integrado de **monitoramento e triagem inteligente de sinais vitais**, desenvolvido no **Departamento de Computação da Universidade Federal de Sergipe (UFS)**.

O projeto combina **hardware (ESP32)** e **software (Flutter + .NET + AWS)** para otimizar o processo de **triagem e acompanhamento de pacientes** em ambientes de saúde e domiciliares.

---

## 🎯 Objetivo

Fornecer uma **avaliação rápida e precisa da condição clínica** de um paciente, utilizando sensores de temperatura, frequência cardíaca e oxigenação do sangue (SpO₂).
Com base nesses dados, o sistema aplica protocolos de triagem, como o **Protocolo de Manchester**, ajudando profissionais de saúde a **priorizar atendimentos** e **detectar anomalias precocemente**.

---

## 🧩 Componentes do Sistema

### 🔹 Hardware (ESP32)

* Coleta de temperatura, frequência cardíaca e SpO₂
* Comunicação via **Bluetooth Low Energy (BLE)**
* Exibição de dados e alertas no display
* Alertas sonoros e visuais em casos críticos

### 🔹 Aplicativo Móvel (Flutter)

* Interface intuitiva para **cadastro e monitoramento de pacientes**
* Comunicação direta com o dispositivo via BLE
* Funcionalidade **offline**, com sincronização posterior
* **Notificações push** via Firebase
* Geração de relatórios e gráficos históricos

### 🔹 Servidor Central (.NET + AWS)

* API REST documentada com Swagger
* Banco de dados **PostgreSQL (RDS)**
* Autenticação com **JWT Tokens**
* Deploy automatizado com **GitHub Actions**
* Infraestrutura como código usando **Terraform**

---

## ⚙️ Funcionalidades Principais

* 🧠 Triagem automatizada e classificação de risco
* 📊 Relatórios e histórico de medições
* 🔔 Notificações push em tempo real
* ☁️ Sincronização em nuvem com backup automático
* 🔒 Conformidade total com a **LGPD**

---

## 👥 Público-Alvo

* **Profissionais de saúde**: enfermeiros, técnicos e médicos
* **Pacientes e cuidadores**: para acompanhamento remoto de sinais vitais

---

## 🏗️ Tecnologias Utilizadas

| Camada           | Tecnologia                       |
| ---------------- | -------------------------------- |
| Aplicativo Móvel | Flutter / Dart                   |
| Backend          | .NET 8.0                         |
| Banco de Dados   | PostgreSQL (AWS RDS)             |
| Infraestrutura   | AWS ECS, ECR, S3, SES, Terraform |
| CI/CD            | GitHub Actions                   |
| Notificações     | Firebase Cloud Messaging         |

---

## 🔐 Segurança

* Criptografia de dados em trânsito e em repouso
* Autenticação via JWT com expiração
* Controle de acesso baseado em papéis (RBAC)
* Conformidade com a **Lei Geral de Proteção de Dados (LGPD)**

---

## 👨‍💻 Equipe de Desenvolvimento

**Universidade Federal de Sergipe – DCOMP/UFS**

* Bruno Santana Andrade
* Felipe Ferreira da Silva
* Isaias Elias da Silva
* Marcelo Santos da Cruz
* Mateus do Rosário Costa
* Matheus Lima da Cruz

---

## 📄 Licença

Projeto acadêmico desenvolvido para fins educacionais na **UFS**.
Uso permitido para pesquisa, extensão e aprendizado.
