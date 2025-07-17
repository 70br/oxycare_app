<?php
header("Content-Type: application/json");
include("../db_config.php");

$sql = "SELECT id, nome, sexo, faixa_etaria, comorbidades FROM perfis ORDER BY nome ASC";
$result = $conn->query($sql);

$perfis = [];

if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $perfis[] = [
            "id" => $row["id"],
            "nome" => $row["nome"],
            "sexo" => $row["sexo"],
            "faixa" => $row["faixa_etaria"],
            "comorbidades" => $row["comorbidades"]
        ];
    }

    echo json_encode([
        "status" => "ok",
        "perfis" => $perfis
    ]);
} else {
    echo json_encode([
        "status" => "vazio",
        "mensagem" => "Nenhum perfil encontrado"
    ]);
}

$conn->close();
?>
