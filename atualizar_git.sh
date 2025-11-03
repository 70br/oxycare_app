#!/bin/bash

# Mensagem do commit (passar como argumento ou usar padrão)
MSG=${1:-"Atualizações do projeto"}

# Adiciona todas as alterações
git add .

# Commit (vai pular se não houver alterações)
git commit -m "$MSG" 2>/dev/null

# Push para a universidade
git push universidade main

# Push para o 70br
git push 70br main

echo "✅ Atualização completa para ambos os repositórios!"
