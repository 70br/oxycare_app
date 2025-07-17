<?php
require_once("../db_config.php");

$data = json_decode(file_get_contents("php://input"), true);

$paciente_id = $data['paciente_id'] ?? null;
$batimentos = $data['batimentos'] ?? null;
$spo2 = $data['spo2'] ?? null;
$temperatura = $data['temperatura'] ?? null;

// Validação básica
if (!$paciente_id || !$batimentos || !$spo2 || !$temperatura) {
    echo json_encode(["status" => "erro", "mensagem" => "Dados incompletos"]);
    exit;
}

$sql = "INSERT INTO sinais (paciente_id, batimentos, spo2, temperatura)
        VALUES (?, ?, ?, ?)";

$stmt = $conn->prepare($sql);
$stmt->bind_param("iiid", $paciente_id, $batimentos, $spo2, $temperatura);
$stmt->execute();

echo json_encode(["status" => "ok"]);
?>
