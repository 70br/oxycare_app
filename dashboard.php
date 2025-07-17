<?php 
require_once("db_config.php");
$result = $conn->query("
  SELECT s.*, p.nome FROM sinais s
  JOIN pacientes p ON p.id = s.paciente_id
  ORDER BY s.data_hora DESC
");
?>

<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Painel OxyCare</title>
</head>
<body>
  <h2>Painel de Sinais Vitais</h2>
  <table border="1" cellpadding="8">
    <tr>
      <th>Paciente</th>
      <th>Batimentos</th>
      <th>SpO2</th>
      <th>Temperatura</th>
      <th>Data/Hora</th>
    </tr>
    <?php while($row = $result->fetch_assoc()): ?>
    <tr>
      <td><?= $row['nome'] ?></td>
      <td><?= $row['batimentos'] ?> bpm</td>
      <td><?= $row['spo2'] ?> %</td>
      <td><?= $row['temperatura'] ?> °C</td>
      <td><?= $row['data_hora'] ?></td>
    </tr>
    <?php endwhile; ?>
  </table>
</body>
</html>
