# Auditoria Técnica — Quick App Setup

Data: 2026-04-03

## Escopo auditado
- `Quick_App_Setup.bat`
- `README.md`

## Resumo executivo
O projeto é funcional e resolve bem o caso de uso principal (instalação em lote via Winget), mas há pontos importantes de **confiabilidade**, **segurança operacional** e **manutenibilidade** que podem ser melhorados. Os maiores riscos atuais são:

1. **Detecção frágil de itens já instalados** (pode gerar falso positivo por substring).
2. **Processamento de erro parcial do `winget`** (não captura cenários de reinício/aceite/interação bloqueada).
3. **Menu e lógica acoplados** (manutenção cresce linearmente conforme adiciona apps).
4. **Uso de nomes com underscore para exibição/listas** (piora UX e reporting).
5. **Funções não utilizadas** (`:progress`, `:spinner`) e inconsistências de documentação.

---

## Achados e recomendações

### 1) Verificação de app instalado com risco de falso positivo
**Achado:** A função `:add_unique` usa `findstr` com busca textual em toda string acumulada; isso permite colisão por substring (ex.: `Mega` e `MegaSync`).

**Impacto:** app pode não entrar na lista correta, impactando o resumo final e telemetria manual.

**Recomendação:**
- Armazenar listas com delimitador fixo (`|nome|`) e validar com correspondência delimitada.
- Alternativamente, usar uma variável por item (`set "SEEN_<slug>=1"`) para deduplicação exata.

---

### 2) Dependência em `winget list --id` sem endurecimento de parsing
**Achado:** A lógica depende de `errorlevel` de `winget list --id %2 -e` para decidir se está instalado.

**Impacto:** em versões diferentes do `winget`, idioma/localidade e mudanças de comportamento podem afetar retorno.

**Recomendação:**
- Fixar formatação de saída (`--source winget` quando aplicável) e conferir presença do `Id` esperado em output estruturado.
- Adicionar fallback com `winget export`/`list` parseado de forma robusta.

---

### 3) Instalação sem estratégia para códigos de retorno conhecidos
**Achado:** Após `winget install`, só há bifurcação binária (0 = sucesso / !=0 = erro).

**Impacto:** perda de nuance operacional (ex.: reinício necessário, pacote em uso, prompt pendente).

**Recomendação:**
- Mapear códigos frequentes do `winget` e classificar em: sucesso, sucesso com aviso, erro recuperável, erro fatal.
- Exibir ações sugeridas ao usuário (reiniciar, executar novamente, instalar manualmente).

---

### 4) Arquitetura do menu pouco escalável
**Achado:** O menu e os `if %%a==N` são repetitivos e difíceis de manter.

**Impacto:** maior chance de erro humano ao adicionar/remover apps.

**Recomendação:**
- Criar “tabela” de apps em variáveis (`APP_1_NAME`, `APP_1_ID`...) e iterar dinamicamente.
- Validar entradas inválidas e duplicadas antes da execução.

---

### 5) UX e legibilidade
**Achado:** Nomes de app exibidos com `_` e resumo usando `X` quando vazio.

**Impacto:** experiência menos profissional e menor clareza.

**Recomendação:**
- Usar nomes amigáveis (`Google Chrome`) no display.
- Trocar `X` por mensagens semânticas (“Nenhum item”).

---

### 6) Segurança operacional / pré-checagens
**Achado:** não há validação explícita de presença do `winget` antes do menu.

**Impacto:** falhas tardias e mensagens confusas.

**Recomendação:**
- Checar `winget --version` no início e abortar com instrução clara se ausente.
- Opcional: validar conectividade básica e source `winget` disponível.

---

### 7) Organização de código
**Achado:** existem funções utilitárias não utilizadas (`:progress`, `:spinner`).

**Impacto:** dívida técnica e ruído cognitivo.

**Recomendação:**
- Remover código morto ou integrar via flag de execução.
- Padronizar comentários e idioma (PT-BR) em todo script.

---

### 8) Documentação com pequenos desalinhamentos
**Achado:** README cita modos de log, mas o script fixa `LOGLEVEL=2` sem parametrização por entrada.

**Impacto:** expectativa do usuário pode não bater com execução padrão.

**Recomendação:**
- Permitir definir `LOGLEVEL` por argumento (`Quick_App_Setup.bat --log 1`).
- Atualizar README com exemplos de uso por parâmetro.

---

## Plano de melhoria sugerido (prioridade)

### Curto prazo (1–2 horas)
1. Adicionar pré-check de `winget`.
2. Melhorar mensagens de vazio no resumo.
3. Remover funções não usadas ou documentar feature flag.

### Médio prazo (0,5–1 dia)
1. Refatorar catálogo de apps para estrutura orientada a dados.
2. Validar input de seleção (range, duplicados, tokens inválidos).
3. Deduplicação robusta por chave exata.

### Evolução (1–2 dias)
1. Migrar para PowerShell para melhor tratamento de erros/objetos.
2. Gerar log estruturado (`.log`/`.json`) para suporte.
3. Adicionar modo “dry-run” (simulação sem instalar).

---

## Indicadores de qualidade recomendados
- Taxa de instalações concluídas sem intervenção.
- Taxa de falso positivo em “já instalado”.
- Tempo médio por execução.
- Percentual de erros recuperáveis vs fatais.

---

## Conclusão
A base do projeto é boa para uso pessoal e times pequenos. Com ajustes pontuais de robustez e uma refatoração leve de estrutura, o script pode evoluir rapidamente para um instalador em lote confiável e de fácil manutenção.
