<?php
header("Content-Type: application/json");
include("../db_config.php");

// Ler dados JSON do app Flutter
$data = json_decode(file_get_contents("php://input"), true);

// DEBUG: Salvar dados recebidos em um arquivo
file_put_contents("../debug_login.txt", print_r($data, true));

// Verifica se email e senha foram enviados
$email = $data["email"] ?? '';
$senha = $data["senha"] ?? '';

if (!$email || !$senha) {
    echo json_encode(["status" => "erro", "mensagem" => "Campos obrigatórios"]);
    exit;
}

// Consultar o usuário no banco
$stmt = $conn->prepare("SELECT * FROM usuarios WHERE email = ?");
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();
$user = $result->fetch_assoc();

if ($user && password_verify($senha, $user['senha'])) {
    echo json_encode([
        "status" => "ok",
        "usuario" => [
            "id" => $user['id'],
            "nome" => $user['nome'],
            "email" => $user['email'],
            "tipo" => $user['tipo']
        ]
    ]);
} else {
    echo json_encode(["status" => "erro", "mensagem" => "Login inválido"]);
}
?>
