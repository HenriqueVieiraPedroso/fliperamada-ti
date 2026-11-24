# TODO — Fliperamada TI

## Tema global, marca e navegação

- [x] Criar aplicativo ERP chamado "Fliperamada TI" para espaço de entretenimento gamer com máquinas de fliperama, venda de fichas e pequena conveniência. App responsivo (tablet/desktop como foco, mobile adaptado), visual moderno, enxuto e muito diferenciado, inspirado em estética arcade neon / synthwave premium, sem parecer ERP tradicional e sem cara de template.
- [x] Tema escuro por padrão. Fundo: #0A0B1E (azul-noite) com gradientes sutis para #140B2E.
- [x] Cores neon: Ciano #00F0FF (primária), Magenta #FF2E93 (secundária), Verde-limão #B6FF3B (sucesso/entradas), Amarelo #FFD60A (alertas), Vermelho #FF4D4D (erros/estornos), Roxo #8B5CF6 (destaques de gráficos).
- [ ] Cards com glassmorphism: fundo branco 6% de opacidade, blur, borda 1px com gradiente neon, cantos 20px, leve brilho (glow) na cor do contexto.
- [x] Tipografia: "Press Start 2P" apenas em títulos curtos e logo; "Space Grotesk" para subtítulos e números grandes; "Inter" para textos e tabelas.
- [x] Ícones lineares arredondados, micro-animações (hover com glow, transição de números contando, cards que sobem suavemente ao entrar na tela).
- [x] Elementos decorativos discretos: grade retrô no fundo com baixa opacidade, pixels e estrelas sutis. Nada poluído.
- [x] Menu lateral recolhível (rail com ícones neon; expande mostrando rótulos) no desktop/tablet; bottom navigation no mobile. Itens: Dashboard, PDV, Estoque, Máquinas, Caixa, Financeiro, Equipe, Relatórios.
- [x] Topbar com busca global, indicador do caixa (Aberto/Fechado com bolinha pulsando), avatar do usuário logado e perfil (Administrador, Gerente, Operador de Caixa, Técnico).
- [x] Os itens do menu aparecem conforme o perfil do usuário.
- [x] Botões primários com gradiente ciano→roxo e glow; botões destrutivos em vermelho.
- [ ] Tabelas limpas, com linhas altas, zebra sutil, chips coloridos de status e busca/filtro no topo.
- [x] Formulários em modal lateral (drawer) ou bottom sheet, nunca em telas pesadas.
- [x] Estados vazios ilustrados com mensagem divertida de tema gamer (ex.: "GAME OVER... nenhum registro por aqui"). Mensagens de validação claras, em português.
- [x] Gráficos: linhas suaves (curvas) com área em gradiente translúcido e pontos com glow; barras com cantos arredondados e gradiente vertical; donuts finos com valor total no centro; tooltips em glassmorphism; sem linhas de grade pesadas, eixos discretos.
- [x] Gerar tema global (cores, tipografia, componentes reutilizáveis) e navegação principal. Todo texto da interface em português do Brasil.

## Login e dashboard

- [ ] Tela de Login do Fliperamada TI. Layout dividido: à esquerda, uma ilustração/animação estilo arcade neon (silhueta de fliperama com glow ciano e magenta, grade retrô em perspectiva ao fundo); à direita, card glassmorphism com logo em "Press Start 2P", campos de usuário e senha (com botão mostrar/ocultar), botão "INSERIR FICHA E ENTRAR" com gradiente ciano→roxo e animação de brilho. Exibir mensagem de erro clara para usuário inativo ou credenciais inválidas. Mobile: ilustração vira fundo com card centralizado.
- [x] Dashboard principal com visual premium. Topo: saudação ao usuário e seletor de período (Hoje, 7 dias, Mês).
- [x] Linha de 4 KPI cards com glow e número animado: Faturamento do período (ciano), Fichas vendidas (magenta), Ticket médio (verde-limão), Saldo do caixa atual (amarelo). Cada card com mini sparkline e variação % em relação ao período anterior.
- [x] Abaixo, grade com: (1) Gráfico de linha em área com gradiente: faturamento por hora/dia, com tooltip glass e linha comparativa tracejada do período anterior. (2) Donut fino: vendas por forma de pagamento (Dinheiro, PIX, Débito, Crédito) com total no centro. (3) Barras arredondadas: vendas por categoria (Fichas, Bebidas, Snacks). (4) Heatmap por dia da semana x horário mostrando os horários de maior movimento (escala do roxo ao ciano). (5) Ranking "Top 5 produtos" com barras horizontais de progresso neon. (6) Card "Alertas de estoque" listando itens abaixo do mínimo com chip vermelho pulsante. (7) Card "Máquinas": 3 contadores (Ativas, Em Manutenção, Inativas) com anel de progresso.
- [x] Layout em bento grid, com tamanhos de cards variados, espaçamento generoso e hierarquia visual clara.

## PDV e caixa

- [x] Tela de PDV focada em agilidade, usável com poucos cliques. Esquerda: categorias em chips (Fichas, Bebidas, Snacks) e grade de produtos em cards grandes com ícone, nome, preço e botão "+" (toque adiciona 1). Direita: carrinho fixo em card glass com itens, controle de quantidade, desconto (exige permissão), subtotal, total em fonte grande Space Grotesk e botão "FINALIZAR VENDA".
- [x] Fluxo de pagamento em modal: escolher Dinheiro, PIX, Débito, Crédito, com opção de pagamento combinado (dividir valor entre formas), campo de valor recebido e troco calculado automaticamente em destaque verde-limão.
- [x] Se não houver caixa aberto, bloquear a tela e exibir aviso com botão "Abrir caixa". Bloquear item cuja quantidade pedida seja maior que o estoque, com mensagem clara. Animação de confirmação ao concluir (check neon + confete de pixels).
- [x] Tela de Caixa. Topo: card de status (Aberto/Fechado), operador, horário de abertura e fundo de troco. Botões: Abrir Caixa, Sangria, Suprimento, Fechar Caixa. Abrir caixa pede valor inicial.
- [x] Sangria e suprimento abrem drawer com valor e justificativa obrigatória (sangria exige perfil Gerente/Admin).
- [x] Abaixo: timeline vertical de movimentações do turno (vendas, sangrias, suprimentos) com ícones e cores por tipo, e donut com composição dos recebimentos por forma de pagamento.
- [x] Fechamento: wizard de 2 passos. 1) Informar valor contado por forma de pagamento. 2) Resumo comparando Esperado x Contado, com diferença destacada (verde = bateu, amarelo = sobra, vermelho = quebra). Em caso de diferença, exigir observação antes de concluir. Impedir que o mesmo operador tenha dois caixas abertos.

## Estoque e máquinas

- [x] Tela de Estoque com abas: Posição Atual, Entradas, Movimentações, Fornecedores.
- [x] Posição Atual: tabela com filtro por categoria, barra de nível de estoque colorida por linha (verde/amarelo/vermelho conforme o mínimo) e chip "BAIXO" pulsante nos críticos.
- [x] Entradas: formulário em drawer com fornecedor, itens, quantidade, custo unitário e data; atualiza o saldo automaticamente.
- [x] Movimentações: tabela filtrável por período, produto, tipo (Entrada/Saída) e operador, com chips coloridos (Compra, Venda, Manutenção, Perda, Estorno).
- [x] Fornecedores: cards com razão social, CNPJ/CPF, contato e botão inativar (nunca excluir).
- [x] Tela de Máquinas de Arcade em grade de cards, cada um com visual de "cartucho/arcade" e glow na cor do status: verde (Ativa), amarelo (Em Manutenção), cinza (Inativa). Mostrar nome do jogo, nº de patrimônio, data de aquisição e contagem de manutenções.
- [x] Ao tocar, abre drawer com histórico de manutenções e peças utilizadas (linha do tempo). Botão "Registrar saída de peça" que exige selecionar a máquina vinculada e o produto. Filtro por status no topo.

## Equipe e fechamento do escopo

- [x] Tela de Equipe: cards de colaboradores com avatar, cargo, chip do perfil de acesso e status (Ativo/Inativo). Drawer de cadastro (nome, CPF, cargo, telefone, e-mail, admissão, salário base, perfil).
- [x] Aba "Escalas": grade semanal com turnos Manhã, Tarde e Noite/Fim de Semana em blocos coloridos arrastáveis.
- [x] Aba "Ponto": botão grande "INICIAR TURNO / ENCERRAR TURNO" e histórico de horas trabalhadas com gráfico de barras por semana.
- [x] Incluir Financeiro e Relatórios na navegação principal, com resumos e filtros coerentes com os módulos de vendas, caixa e estoque; não presumir emissão fiscal, folha de pagamento ou integração bancária.
- [x] Todo acesso persistente usa Supabase (Postgres + Auth), com autorização pelos perfis e RLS; nenhuma chave privilegiada no cliente. A demonstração fica explicitamente separada do banco real.
- [x] Build estático Flutter Web compatível com Vercel, com documentação em pt-BR para definir URL/chave pública e rodar migrações no projeto Supabase do usuário.

## Evidências e limites da entrega

Os fluxos de demonstração são isolados e os nove testes de domínio passaram: valores monetários, pagamento combinado, isolamento de caixa por turno, divergências por método, validação de estoque, fornecedor preservado, manutenção vinculada, ponto e ocupação de escala. `flutter analyze` terminou sem diagnósticos após as últimas correções e a migração para Material/Cupertino modernos. Build Web release final gerado em `build/web`; Preview, `/manus-routes.json`, ilustração do login e fonte Inter responderam HTTP 200. Os layouts de login e oito módulos passaram nos tamanhos 390 e 1440 px na execução conjunta; após corrigir o grupo de ações do Caixa, o caso 768 px passou isoladamente. Não houve nova execução conjunta depois dessa correção. As evidências e limitações estão em `docs/validation.md`.

A implementação Supabase está pronta no código, com RLS, grants mínimos e RPCs; a migração foi verificada sintaticamente, mas não executada em uma conta externa. Conexão real, carga inicial, convites e deploy Vercel dependem da configuração da conta do usuário. Os itens de persistência marcados referem-se à implementação, não à operação em produção já validada.

Os três itens visuais acima permanecem parciais: cards têm blur/translucidez/glow e cantos 20 px, mas usam borda neon uniforme em vez de borda em gradiente; tabelas têm separadores/filtros/chips, sem zebra universal em todos os módulos; o login inclui ilustração arcade original, adaptação mobile, senha visível/oculta e CTA neon, mas não tem uma animação contínua de brilho no CTA. Esses acabamentos não bloqueiam os fluxos operacionais implementados.
