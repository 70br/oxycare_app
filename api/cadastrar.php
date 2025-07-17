<?php
header("Content-Type: application/json");
include("../db_config.php");

$data = json_decode(file_get_contents("php://input"), true);

$nome = $data["nome"] ?? '';
$email = $data["email"] ?? '';
$senha = $data["senha"] ?? '';
$tipo = $data["tipo"] ?? 'usuario'; // <- RECEBE o tipo enviado do app ('paciente' ou 'enfermeiro')

if (!$nome || !$email || !$senha) {
    echo json_encode(["status" => "erro", "mensagem" => "Campos obrigatórios"]);
    exit;
}

// Verifica se já existe um usuário com esse e-mail
$stmt = $conn->prepare("SELECT id FROM usuarios WHERE email = ?");
$stmt->bind_param("s", $email);
$stmt->execute();
$stmt->store_result();

if ($stmt->num_rows > 0) {
    echo json_encode(["status" => "erro", "mensagem" => "E-mail já cadastrado"]);
    exit;
}

// Insere novo usuário com o tipo vindo do app
$senha_hash = password_hash($senha, PASSWORD_DEFAULT);
$stmt = $conn->prepare("INSERT INTO usuarios (nome, email, senha, tipo) VALUES (?, ?, ?, ?)");
$stmt->bind_param("ssss", $nome, $email, $senha_hash, $tipo);

if ($stmt->execute()) {
    echo json_encode(["status" => "ok", "mensagem" => "Cadastro realizado com sucesso"]);
} else {
    echo json_encode(["status" => "erro", "mensagem" => "Erro ao cadastrar"]);
}
?>
