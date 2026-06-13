# Detalhes Técnicos - Aquário iOS

Este documento fornece informações detalhadas sobre a identidade visual do Aquário, mapeamento de APIs e endpoints, e regras de sincronização para o desenvolvedor iOS.

---

## 🎨 Identidade Visual e Cores

O aplicativo móvel do Aquário deve seguir a paleta de cores definida na versão web para garantir consistência visual:

*   **Cor Primária do Aquário (Deep Navy):** `HSL(212, 77%, 24%)` ou `Hex #0E2E5C`.
*   **Fundo (Modo Claro):** `Slate 50` (`Hex #F8FAFC`).
*   **Fundo (Modo Escuro):** `Slate 950` (`Hex #020617`).
*   **Textos Principais:** `Foreground` (`Hex #0A0F1D`).
*   **Tipografia:** Outfit ou System Rounded (Inter e Roboto como fallbacks no iOS).

---

## 🔄 Mapeamento das APIs e Endpoints

O aplicativo consome a API do Next.js via requisições HTTP REST. Todos os endpoints abaixo estão sob o prefixo `/api` (ex: `http://localhost:3000/api/vagas`).

| Recurso | Método | Endpoint | Autenticado? | Descrição |
| :--- | :--- | :--- | :--- | :--- |
| **Autenticação** | `POST` | `/auth/login` | Não | Login com email e senha. Retorna `{ token: JWT }`. |
| **Perfil** | `GET` | `/auth/me` | Sim | Retorna dados do usuário autenticado (nome, curso, etc.). |
| **Vagas** | `GET` | `/vagas` | Não | Retorna a lista de vagas e oportunidades ativas. |
| **Entidades** | `GET` | `/entidades` | Não | Retorna a lista de laboratórios, grupos e entidades do CI. |
| **Guias** | `GET` | `/guias` | Não | Retorna a lista de guias acadêmicos estruturados. |
| **Currículos** | `GET` | `/curriculos` | Não | Retorna as disciplinas da grade curricular do curso. |
| **Calendário** | `GET` | `/calendario` | Sim | Retorna os horários e disciplinas do semestre do aluno. |

---

## 💾 Políticas de Cache Local

Para garantir a melhor experiência offline, as seguintes políticas devem ser seguidas pela camada de armazenamento local (SwiftData):

1.  **Usuário (`CachedUsuario`):**
    *   Salvo no login ou quando o app carrega o perfil do servidor (`/auth/me`).
    *   Limpo completamente no logout (`NetworkManager.shared.logout()`).

2.  **Oportunidades (`CachedVaga`):**
    *   Armazena até 50 vagas localmente.
    *   Ao obter sucesso no carregamento da API, a lista local é limpa e atualizada com as novas vagas do servidor.

3.  **Entidades (`CachedEntidade`):**
    *   Sincronizado na inicialização e mantido no banco local.
    *   Como os dados das entidades mudam raramente, o cache local deve ser mantido indefinidamente até a próxima requisição com sucesso.
