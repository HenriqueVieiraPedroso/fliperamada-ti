# Fliperamada TI — plano de implementação

## Produto e stack

Aplicativo ERP em **Flutter Web/Dart**, com prioridade para desktop e tablet e navegação adaptada a mobile. O backend solicitado é **Supabase**: autenticação por e-mail/senha, Postgres e políticas RLS por perfil. A hospedagem final solicitada é **Vercel**, servindo o resultado estático de `flutter build web` em `build/web`. Não será substituído por React ou banco Manus.

O projeto Manus usa um template flexível, inicialmente vazio, apenas como ambiente de desenvolvimento, Preview e salvamento de versões. A SDK Flutter não está instalada e será instalada com versão fixa. Não há acesso fornecido a projetos Supabase, Vercel ou GitHub. Publicação real e execução de migrações em uma conta externa dependem do acesso do usuário; não serão declaradas como concluídas sem confirmação.

## Implementação

Tema global reutilizável, shell com rail lateral recolhível, topbar de busca/caixa/perfil e navegação mobile. Login dividido com ilustração arcade, campos validados e exibição de falhas de credenciais e usuário inativo. O login real usa Supabase; a exploração sem credenciais será um **modo demonstração explicitamente identificado**, isolado dos dados reais.

O núcleo de dados separa entidades e regras da apresentação. Repositórios implementam leitura/escrita via Supabase e dados de demonstração. Operações de caixa/vendas/estoque devem ser transacionais no banco, com validação de saldo, estoque, papel e estado de caixa; permissões na UI não substituem RLS/RPC. Nunca incluir chaves `service_role` ou administrativas no Flutter. URL e chave pública/publishable são definidas no build por `--dart-define`.

### Módulos

- **Dashboard:** período Hoje/7 dias/Mês, quatro KPIs com variação, sparklines, faturamento comparativo, pagamento, categoria, movimento por dia/hora, produtos, estoque e máquinas, em bento grid.
- **PDV:** produtos por categoria, carrinho com quantidades/desconto autorizado, bloqueio por estoque/caixa, pagamento simples e dividido, recebido/troco e confirmação de venda.
- **Caixa:** abertura/fundo inicial, suprimento, sangria autorizada com justificativa, timeline e recebimentos. Fechamento em duas etapas com contado por forma, comparação e observação obrigatória em divergência; impedir dois caixas abertos do mesmo operador.
- **Estoque:** posição/filtros/nível/mínimo, entrada com fornecedor/itens/custos/data, histórico por filtros e fornecedores inativáveis.
- **Máquinas:** cards por status com jogo/patrimônio/aquisição/manutenções, detalhes em painel lateral, histórico e saída de peças com máquina obrigatória.
- **Equipe:** colaboradores, cadastro dos campos solicitados e perfil/status, escala semanal com blocos de turnos e ponto com registro de início/fim/histórico/gráfico. Dados de salário/CPF restritos conforme perfil.
- **Financeiro e Relatórios:** telas coerentes com as entidades existentes, resumo de vendas/recebimentos e filtros. O anexo define esses itens de navegação, mas não regras contábeis/fiscais adicionais; não haverá emissão fiscal, folha ou integração bancária implícita.

## Estrutura

- `lib/main.dart`: bootstrap e configuração Supabase.
- `lib/app/`: tema, estado e navegação/shell.
- `lib/core/`: componentes, formatação pt-BR e regras compartilhadas.
- `lib/data/`: modelos, repositório Supabase e repositório demonstrativo.
- `lib/features/`: telas e fluxos por módulo.
- `assets/`: fontes e ilustração arcade do login.
- `supabase/migrations/`: schema, constraints, RLS, funções transacionais e índices.
- `supabase/`: instruções para bootstrap do administrador e dados iniciais sem credenciais fixas.
- `scripts/`: build Flutter versionado e preparação para Vercel.
- `web/`: bootstrap, manifest, ícones e manifesto de rotas Manus.
- `test/`: verificações das regras compartilhadas.
- `vercel.json` e `README.md`: configuração e passos de deploy.

## Design

**Movimento:** arcade neon/synthwave premium, conforme o anexo. **Princípios:** legibilidade operacional, contraste escuro profundo, neon usado como hierarquia e cartões leves sem poluição. **Cor:** base #0A0B1E → #140B2E, ciano #00F0FF como assinatura, magenta #FF2E93, lima #B6FF3B, amarelo #FFD60A, vermelho #FF4D4D e roxo #8B5CF6 por contexto.

**Layout:** painel operacional com menu na borda, cabeçalho compacto e bento assimétrico. Cards com cantos 20 px, superfícies translúcidas, bordas finas e glow contido. **Motivos:** grade retro discreta, pixels pontuais e chips de status. **Interação:** toque/clique com feedback imediato, formulários em painel lateral no desktop e bottom sheet no mobile. **Animação:** entradas suaves, hover com brilho e números animados, respeitando acessibilidade e evitando brilho contínuo excessivo.

**Tipografia:** Press Start 2P no logotipo/títulos curtos, Space Grotesk em números/subtítulos e Inter nos textos/tabelas. **Marca:** gestão ágil para um espaço gamer, com personalidade precisa, energética e contemporânea. **Voz:** português brasileiro claro com alusões gamer discretas; exemplos: “INSERIR FICHA E ENTRAR” e “GAME OVER... nenhum registro por aqui”. **Logotipo:** wordmark pixel com símbolo de arcade, não nome em fonte padrão. **Cor assinatura:** ciano neon.

## Build e entrega

Instalar SDK Flutter fixada, resolver dependências via `pubspec.lock`, verificar Dart por `flutter analyze` (a configuração host de diagnósticos não suporta Dart), compilar Flutter Web e disponibilizar a Preview com servidor estático declarado no Webdev. Registrar a configuração de build e salvar a versão no remoto canônico Manus. Entregar código Flutter com SQL e documentação; exportar pacote do projeto quando necessário para uso na Vercel.

Na Vercel: preset Other, build script do projeto e saída `build/web`. Definir `SUPABASE_URL` e `SUPABASE_PUBLISHABLE_KEY`, recompilar e ajustar URLs permitidas no Supabase Auth. Não publicar nem executar SQL em um projeto remoto sem acesso/autorizações disponíveis. A conexão real ao Supabase e o deploy na Vercel permanecem dependências externas se o usuário não as fornecer.
