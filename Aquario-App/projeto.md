# Projeto Aquário - iOS Mobile App

Este documento detalha o planejamento, as decisões arquiteturais e os próximos passos para o desenvolvimento do aplicativo móvel do **Aquário**.

---

## 🛠️ Decisões Arquiteturais

1. **Plataforma e Framework:**
   - **Nativo iOS:** Desenvolvido em Swift 6 e SwiftUI.
   - **Compatibilidade:** Código otimizado para compatibilidade retroativa com compiladores Swift mais antigos (como Swift 5.7.2).

2. **Gerenciamento de Dados e Cache (Suporte Offline):**
   - **SwiftData:** Utilizado para modelar e persistir os dados localmente (`StorageProvider.swift`).
   - **Offline-First:** O aplicativo carrega os dados salvos em cache imediatamente ao abrir, realizando chamadas em segundo plano para atualizar o conteúdo quando houver conexão de internet.

3. **Rede e Segurança:**
   - **URLSession + async/await:** Chamadas de rede nativas e modernas.
   - **Criptografia com Keychain:** Armazenamento seguro de credenciais e do token JWT do usuário no chaveiro nativo do iOS.

---

## 🚀 Próximos Passos de Desenvolvimento

### 1. Executar e Popular o Backend Local
Para testar o aplicativo móvel com dados dinâmicos, o backend em Next.js precisa estar rodando localmente.
- **Passo 1.1:** Inicializar o banco de dados PostgreSQL com Docker:
  ```bash
  cd ../aquario
  docker-compose up -d
  ```
- **Passo 1.2:** Executar as migrações do banco e a semente de dados (seed) para popular dados reais (centros, cursos, vagas):
  ```bash
  npm run db:migrate
  npm run db:seed
  ```
- **Passo 1.3:** Iniciar o servidor de desenvolvimento:
  ```bash
  npm run dev
  ```

### 2. Implementar as Telas Restantes no iOS
Para equiparar o app mobile com os recursos descritos no `README.md` do backend:
- **Telas a Implementar:**
  - **`GuiasView.swift`:** Interface para navegar nos guias acadêmicos, consumindo o endpoint `/api/guias`.
  - **`MapasView.swift`:** Mapa do campus e blocos integrado ao MapKit do iOS (consumindo `/api/campus`).
  - **`CalendarioView.swift`:** Agenda de aulas e visualização de horários cadastrados pelo aluno (consumindo `/api/calendario`).

### 3. Testes e Validação Integrados
- **Testes de Integração:** Validar fluxos de autenticação completos (Login -> Armazenamento no Chaveiro -> Carregamento de Perfil).
- **Testes de Conectividade:** Simular modo avião no simulador do iOS para verificar a robustez do cache do SwiftData.
