
## Terceira revisão visual — superfícies claras em todas as telas

Data: 26/11/2026. A revisão foi ampliada para evitar que o tema claro dependa apenas da paleta global enquanto cartões, dropdowns, diálogos e painéis internos continuam escuros:

- superfícies de POS, Estoque, Máquinas e Equipe passaram a usar helpers adaptativos do tema;
- dropdowns de filtros de Estoque e Máquinas passaram a abrir sobre a superfície ativa;
- componentes globais de filtros, indicadores e barras receberam superfícies adaptativas no modo claro;
- Caixa, POS, Estoque, Máquinas e Equipe deixaram de usar fundos fixos escuros em mensagens de erro;
- indicadores circulares do Dashboard passaram a usar uma superfície clara real como fundo;
- a paleta clara foi reforçada com fundo azul muito claro, painéis brancos, texto navy quase preto, bordas mais fortes e acentos ciano/magenta/verde escurecidos;
- o tema escuro permanece usando a identidade arcade original e seus fundos escuros.

Validação desta revisão: executar `flutter analyze`, `flutter test --platform chrome --reporter expanded` e `bash scripts/vercel-build.sh` após a aplicação das alterações.

## Segunda revisão visual — Caixa e Equipe

Data: 26/11/2026. Foram aplicadas melhorias adicionais no tema claro em todo o fluxo prioritário de operação:

- verde semântico substituído por verde escuro de alto contraste;
- textos de operador, abertura, subtítulos e metadados ampliados e escurecidos;
- diálogos de abertura, suprimento, sangria e fechamento de Caixa passaram a usar a superfície do tema em vez de fundos escuros fixos;
- painel interno do fechamento, legendas e divisórias passaram a acompanhar o tema claro;
- formulários de colaborador e seleção de colaborador para escala passaram a usar superfícies claras;
- dias da semana e células da escala receberam mais largura, altura, margem e espaçamento;
- elementos pequenos da tela de Equipe foram ampliados sem alterar o tema escuro.

Validação anterior: `flutter analyze` sem issues; `flutter test --platform chrome --reporter expanded` com 12 testes aprovados; `bash scripts/vercel-build.sh` com `Built build/web`.
