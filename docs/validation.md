
## Segunda revisão visual — Caixa e Equipe

Data: 26/11/2026. Foram aplicadas melhorias adicionais no tema claro em todo o fluxo prioritário de operação:

- verde semântico substituído por verde escuro de alto contraste;
- textos de operador, abertura, subtítulos e metadados ampliados e escurecidos;
- diálogos de abertura, suprimento, sangria e fechamento de Caixa passaram a usar a superfície do tema em vez de fundos escuros fixos;
- painel interno do fechamento, legendas e divisórias passaram a acompanhar o tema claro;
- formulários de colaborador e seleção de colaborador para escala passaram a usar superfícies claras;
- dias da semana e células da escala receberam mais largura, altura, margem e espaçamento;
- elementos pequenos da tela de Equipe foram ampliados sem alterar o tema escuro.

Validação desta revisão: `flutter analyze` sem issues; `flutter test --platform chrome --reporter expanded` com 12 testes aprovados; `bash scripts/vercel-build.sh` com `Built build/web`.
