# Validação da entrega — Fliperamada TI

Data: 23/11/2026. Ambiente: Sandbox Linux ARM64, Flutter 3.50.1, Dart 3.14.0 e Chromium. As verificações usam dados demonstrativos em memória; não houve acesso a um projeto Supabase externo nem publicação na Vercel.

## Testes e análise

Os **nove testes de domínio passaram**: parsing de valores pt-BR/decimais; pagamento combinado; isolamento de caixa entre turnos; diferenças por forma que não se anulam; valores inválidos e estoque insuficiente; fornecedor inativado preservado; manutenção com baixa vinculada; histórico de ponto; e bloqueio de escala ocupada.

Os testes de layout exercitam login, o botão “EXPLORAR DEMONSTRAÇÃO” e os oito módulos, com o `FliperamadaApp` real e seus delegates pt-BR. As verificações concluídas foram:

| Viewport | Resultado e evidência |
| --- | --- |
| 390 × 844 | Passou na última execução dos três tamanhos, sem exceção de renderização. |
| 1440 × 900 | Passou na mesma execução, sem exceção de renderização. |
| 768 × 1024 | A execução conjunta revelou overflow no grupo de ações do Caixa; após empilhar essas ações, o caso tablet isolado passou (`+1: All tests passed!`). |

Não houve uma nova execução conjunta depois do último ajuste exclusivo ao layout compacto do Caixa. Os resultados acima são de execuções separadas, não de uma única suíte final inteiramente verde. O teste verifica renderização inicial dos módulos e ausência de exceções nos tamanhos indicados; não é uma cobertura end-to-end de todos os drawers, abas, estados ou permissões. O runner de widgets usa fonte de teste e avisa que `FontManifest.json` não existe; portanto os testes não certificam a tipografia real. A captura da Preview mobile com fontes reais foi usada para investigar o login, não como auditoria visual completa.

`flutter analyze` terminou com **No issues found!** após os ajustes de login, gráficos e localização. Os delegates globais de Material e Cupertino vêm dos pacotes modernos `material_ui` e `cupertino_ui`, em vez das APIs depreciadas da SDK.

Comandos de reprodução, após instalar a SDK e exportar seu `bin` para o `PATH`:

```bash
flutter analyze
CHROME_EXECUTABLE=/usr/bin/chromium flutter test --platform chrome --reporter expanded
CHROME_EXECUTABLE=/usr/bin/chromium flutter test test/layout_test.dart \
  --platform chrome --plain-name 'Telas sem overflow em 768 px' --reporter expanded
bash scripts/vercel-build.sh
```

## Build e Preview

O build Web release **de entrega compilou com sucesso** com os últimos ajustes de Caixa, login, gráficos e idioma (`✓ Built build/web`, compilação de 79,9 segundos). A saída total ocupa aproximadamente 44 MiB e não contém arquivo individual maior que 30 MiB. `index.html`, `manus-routes.json` e a ilustração original incorporada foram encontrados no build. As fontes locais também fazem parte da saída estática. A compilação foi feita sem credenciais Supabase e, por isso, o pacote estático é demonstrativo; configure os valores públicos e recompile para operação real.

A Preview gerenciada usa `bash scripts/dev_preview.sh` na porta 3000, reiniciada após os últimos ajustes. As verificações HTTP finais retornaram 200 para `/`, `/manus-routes.json`, a ilustração do login e a fonte Inter, com uma única rota Flutter `/`. HTTP 200 comprova a resposta do servidor, não uma validação de acesso em todos os navegadores dos usuários.

## Supabase e segurança

A migração `supabase/migrations/001_initial.sql` foi verificada sintaticamente com parser Postgres (123 instruções e 12 corpos SQL/PL/pgSQL na última verificação). **Ela não foi executada em Postgres/Supabase**: essa evidência não certifica compatibilidade operacional, grants, concorrência ou RLS em uma conta real.

A implementação inclui RLS, grants mínimos e RPCs transacionais para revalidar perfil ativo, estoque, caixa, valores, desconto e pagamentos. Não há chave administrativa no cliente. O bootstrap exige projeto dedicado, execução revisada da migração, primeiro administrador no Auth e carga inicial dos cadastros. Novos colaboradores são convidados no Supabase Auth e vinculados pelo ERP; editar perfil não altera o e-mail do Auth.

Antes do uso comercial, configure `SUPABASE_URL` e `SUPABASE_PUBLISHABLE_KEY`, gere novo build e verifique login/perfis, convites, transações, RLS, fechamento e concorrência no projeto real. O build sem essas configurações é uma demonstração e não grava no banco.

## Acabamentos visuais parciais e limites

Três critérios visuais permanecem parciais e abertos no `TODO.md`: borda dos cards neon uniforme, não em gradiente; ausência de zebra universal em todas as tabelas; e ausência de brilho contínuo animado no CTA do login. Blur, translucidez, glow, ilustração original, hover, números animados e chips pulsantes estão implementados.

Não estão incluídos emissão fiscal, folha, contabilidade completa, integração bancária ou estorno comercial. Relatórios carregam até 65 dias; movimentações, manutenção e ponto mostram até 1.000 registros recentes. Não houve deploy em Vercel nem execução de SQL em conta externa.
