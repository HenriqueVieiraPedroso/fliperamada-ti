
### Validação desta revisão

Na execução final com Flutter 3.50.1 e Dart 3.14.0: `flutter analyze` terminou com **No issues found!**; `flutter test --platform chrome --reporter expanded` terminou com **12 testes aprovados**; e `bash scripts/vercel-build.sh` terminou com **Built build/web**. O build foi regenerado em `build/web`; o ZIP de entrega omite caches temporários e pode regenerar esse diretório pelo script da Vercel.
