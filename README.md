# Fliperamada TI — ERP arcade

Aplicativo **Flutter Web/Dart**, com visual arcade neon e navegação adaptada a desktop, tablet e mobile. Inclui Dashboard, PDV, Caixa, Estoque, Máquinas, Equipe, Financeiro e Relatórios. O backend solicitado é **Supabase Auth + Postgres** e a hospedagem estática está preparada para **Vercel**.

## Explorar a demonstração

Sem credenciais de Supabase, a tela identifica **Modo demonstração — dados fictícios, sem gravação no Supabase**. O botão “EXPLORAR DEMONSTRAÇÃO” permite entrar diretamente. Vendas, entradas, manutenção, escalas e ponto ficam somente na memória e são reiniciados ao sair/entrar. Não use esse modo para operação comercial real.

## Desenvolvimento

SDK Flutter 3.50.1 e checksums em `toolchain/flutter_version`. O instalador Linux valida o download; em ARM64 instala o Dart compatível com essa versão e recompila o CLI.

```bash
FLUTTER_ROOT="$(bash scripts/install_flutter.sh)"
export PATH="$FLUTTER_ROOT/bin:$PATH"
flutter pub get
flutter analyze
flutter run -d chrome
```

Para servir sem abrir navegador, rode `bash scripts/dev_preview.sh`. A porta padrão é 3000 e pode ser definida por `PORT`.

## Configurar Supabase real

1. Crie um **projeto Supabase novo/dedicado**. Execute `supabase/migrations/001_initial.sql` no SQL Editor. A migração cria entidades, índices, trigger de perfil, RPCs transacionais, grants mínimos e RLS. Não aplique sem revisão em um projeto com outro esquema existente.
2. Crie/convide o primeiro usuário em **Authentication**. Copie o UUID e execute a instrução de bootstrap comentada no fim da migração para torná-lo `admin`. Usuários novos recebem `cashier`; nunca aceite perfis enviados em metadata como autorização.
3. Cadastre produtos, fornecedores e máquinas no **Table Editor** do Supabase para a carga inicial. Produtos usam categorias `Fichas`, `Bebidas` e `Snacks`. Estoque inicial pode ser registrado pela entrada do app depois de cadastrar o produto. Fornecedores são inativados, não excluídos.
4. Defina `SUPABASE_URL` e `SUPABASE_PUBLISHABLE_KEY` no ambiente do build. São valores públicos do cliente. **Nunca use `service_role`, secret key ou credencial administrativa no Flutter, bundle ou repositório.**
5. Para colaboradores, convide/crie o acesso no Supabase Auth primeiro; depois use “Novo colaborador” no ERP com o mesmo e-mail para vincular cargo, telefone, CPF, admissão, salário, status e perfil. Somente Administrador pode atribuir/alterar perfis privilegiados.
6. Configure o domínio da Vercel nos endereços de retorno do Supabase Auth quando usar convites/recuperação. Esta versão implementa login por e-mail/senha; convites são enviados pelo Dashboard do Supabase.

Build manual:

```bash
flutter build web --release \
  --dart-define="SUPABASE_URL=$SUPABASE_URL" \
  --dart-define="SUPABASE_PUBLISHABLE_KEY=$SUPABASE_PUBLISHABLE_KEY"
```

As RPCs `open_cash`, `record_cash_adjustment`, `create_sale`, `close_cash`, `register_stock_receipt` e `register_part_exit` controlam operações transacionais. O servidor revalida perfil ativo, permissão, caixa, estoque, desconto, recebimento e pagamentos exatos. `save_employee_profile` gerencia o cadastro de usuários já convidados. `end_time_entry` usa o relógio do servidor para encerrar o ponto.

## Hospedar na Vercel

1. Importe o repositório. Escolha **Framework Preset: Other**, com a raiz no diretório de `vercel.json`.
2. Build Command: `bash scripts/vercel-build.sh`. Output Directory: `build/web`. Ambos já estão definidos em `vercel.json`.
3. Configure `SUPABASE_URL` e `SUPABASE_PUBLISHABLE_KEY` nos ambientes Production/Preview e faça novo deploy depois de alterar valores.
4. Cadastre o domínio final no Supabase conforme o fluxo de convite usado. Verifique login com cada perfil e as RPCs no projeto real antes de liberar o uso comercial.

A Vercel recebe arquivos estáticos. Não há backend privado no bundle nem banco Manus. A ilustração e fontes são incluídas no build; as licenças das fontes estão em `assets/fonts/OFL-*.txt`. A aplicação usa uma rota Web `/` e navegação interna Flutter.

## Perfis e dados

`admin` (Administrador), `manager` (Gerente), `cashier` (Operador de Caixa) e `technician` (Técnico). Financeiro/Relatórios são da gestão; Técnico não opera vendas/caixa. RLS e RPCs continuam sendo a autorização real, independentemente dos menus escondidos.

Relatórios agregam vendas por período local (Hoje, 7 dias, Mês), com comparativo de mesma duração. Pagamento combinado é separado por forma; caixa usa apenas vendas do turno atual. Categoria e ranking usam os itens vendidos, e a margem usa custo unitário registrado na venda, não percentual inventado. Dados analíticos carregam até 65 dias; movimentações/manutenção/ponto mostram até 1.000 registros recentes. CPF e salário ficam restritos à gestão. Escalas seguem a convenção 0=segunda a 6=domingo.

## Validação e limites

O build estático final compilou e `flutter analyze` terminou sem erros no Sandbox. Os nove testes de domínio passaram; os layouts de 390/1440 px passaram na execução conjunta, e o de 768 px passou isoladamente após a correção do Caixa. A cobertura e os três acabamentos visuais parciais estão em [docs/validation.md](docs/validation.md). Há testes em `test/` para parsing monetário, pagamento combinado, isolamento de turnos, divergência por forma, estoque, fornecedor inativado, manutenção, ponto e layouts. Em ARM64, os testes usam o runner oficial Web:

```bash
CHROME_EXECUTABLE=/usr/bin/chromium flutter test --platform chrome
```

A migração foi verificada sintaticamente com parser Postgres; **não foi executada em uma conta Supabase**. A conexão e o deploy Vercel reais exigem as configurações da sua conta. O ZIP de build estático entregue é demonstrativo: para conectar o banco, configure os valores públicos e recompile o projeto. Emissão fiscal, folha, integração bancária, estorno comercial e contabilidade completa não fazem parte desta versão.
