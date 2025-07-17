<?php
header("Content-Type: application/json");
include("../db_config.php");

$data = json_decode(file_get_contents("php://input"), true);

$nome = $data["nome"] ?? '';
$sexo = $data["sexo"] ?? '';
$faixa = $data["faixa"] ?? '';
$comorbidades = $data["comorbidades"] ?? '';

if (!$nome || !$sexo || !$faixa) {
    echo json_encode(["status" => "erro", "mensagem" => "Campos obrigatórios ausentes."]);
    exit;
}

$stmt = $conn->prepare("INSERT INTO perfis (nome, sexo, faixa_etaria, comorbidades) VALUES (?, ?, ?, ?)");
$stmt->bind_param("ssss", $nome, $sexo, $faixa, $comorbidades);

if ($stmt->execute()) {
    echo json_encode(["status" => "ok", "mensagem" => "Perfil cadastrado com sucesso."]);
} else {
    echo json_encode(["status" => "erro", "mensagem" => "Erro ao cadastrar perfil."]);
}

$stmt->close();
$conn->close();
?>
