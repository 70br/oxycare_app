<?php
header("Content-Type: application/json");
include("../db_config.php");

// Aceitar tanto GET quanto JSON
$paciente_id = $_GET['paciente_id'] ?? $_GET['perfil_id'] ?? null;

if (!$paciente_id) {
    echo json_encode(["status" => "erro", "mensagem" => "ID do paciente ausente"]);
    exit;
}

$stmt = $conn->prepare("SELECT batimentos, spo2, temperatura, data_hora FROM sinais WHERE paciente_id = ? ORDER BY data_hora ASC");
$stmt->bind_param("i", $paciente_id);
$stmt->execute();
$resultado = $stmt->get_result();

$dados = [];
while ($linha = $resultado->fetch_assoc()) {
    $dados[] = $linha;
}

echo json_encode(["status" => "ok", "dados" => $dados]);

$stmt->close();
$conn->close();
?>
