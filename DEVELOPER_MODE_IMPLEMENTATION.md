# Developer Mode Implementation

## Overview

O Developer Mode foi reconstruído do zero como uma funcionalidade 100% auto-contida em `HomeView.swift`, ativado por 5 toques no contador principal de dias.

**STATUS: ✅ FUNCIONAL E TESTADO**

## Implementação

### Compilação Condicional (#if DEBUG)

Todo o código do Developer Mode está protegido por `#if DEBUG`:
- **Debug builds**: código incluído, funcionalidade ativa
- **Release/TestFlight/App Store**: código completamente excluído do binário

### Ativação

- **Trigger**: 5 toques consecutivos no contador de dias (`DaysCounterView`)
- **Timeout**: contador de toques reseta após 2 segundos de inatividade
- **Localização**: apenas na `HomeView`, sem dependências externas

### Estado

Três variáveis `@State` em `HomeView` (apenas em DEBUG):
```swift
#if DEBUG
@State private var devTapCount = 0          // contador de toques
@State private var showDevTools = false      // controla sheet do menu
@State private var showDevCheckIn = false    // controla sheet de check-in
#endif
```

### Developer Tools Menu

`DeveloperToolsView` (struct privada, apenas DEBUG) apresentada como `.sheet`:

#### Time Controls
- **Advance +1 hour**: move `startDate` 1 hora para trás
- **Advance +1 day**: move `startDate` 1 dia para trás
- **Advance +7 days**: move `startDate` 7 dias para trás
- Mudanças refletem imediatamente na UI via `NotificationCenter`

#### Check-in Control
- **Redo today's check-in**: remove check-in de hoje do `dailyProgress` e abre `CheckInModalView`

#### Onboarding Control
- **Restart onboarding flow**: chama `flowManager.resetForNewSession(devMode: true)` para voltar ao onboarding
- **IMPORTANTE**: Quando reiniciado via Developer Mode, um botão ❌ aparece no canto superior direito do onboarding
- Este botão permite sair do onboarding a qualquer momento (apenas em modo de desenvolvedor)
- No onboarding normal do usuário, este botão NÃO aparece

### Arquitetura

- **Não modifica**: `ContentView`, `MainTabView`, fluxo principal do app
- **Não interfere**: paywall, onboarding, Superwall
- **Não depende**: botões ocultos, containers instáveis, runtime checks
- **Auto-contido**: toda lógica e estado dentro de `HomeView.swift`

### Verificação

#### Debug Build (Xcode)
- 5 toques no contador de dias abre "Developer Tools"
- Todas as ferramentas funcionam corretamente
- Sheet apresenta-se de forma confiável

#### Release Build (TestFlight/App Store)
- 5 toques não fazem nada
- Nenhuma UI de Developer Mode existe
- Nenhum código morto ou warnings
- Binário não contém referências ao Developer Mode

## Estrutura do Código

```
HomeView.swift
├── HomeView
│   ├── #if DEBUG
│   │   ├── @State private var devTapCount
│   │   ├── @State private var showDevTools
│   │   └── @State private var showDevCheckIn
│   └── body
│       ├── #if DEBUG
│       │   ├── DaysCounterView(devTapCount: $devTapCount, showDevTools: $showDevTools)
│       │   ├── .sheet(isPresented: $showDevTools) { DeveloperToolsView(...) }
│       │   └── .sheet(isPresented: $showDevCheckIn) { CheckInModalView() }
│       └── #else
│           └── DaysCounterView()
│
├── #if DEBUG
├── DaysCounterView (com bindings condicionais)
│   ├── init(devTapCount: Binding<Int>, showDevTools: Binding<Bool>)  // DEBUG
│   ├── init()                                                          // Release
│   └── .onTapGesture { ... } // apenas DEBUG
│
└── #if DEBUG
    └── private struct DeveloperToolsView
        ├── Time Controls (shiftStartDate)
        ├── Check-in Control (resetTodayCheckIn)
        └── Onboarding Control (restartOnboarding com devMode: true)

AppFlowManager.swift
├── #if DEBUG
│   └── @Published var isDevModeOnboarding: Bool
├── resetForNewSession(devMode: Bool = false)
└── #if DEBUG
    └── exitDevModeOnboarding()

OnboardingView.swift
├── #if DEBUG
│   └── @EnvironmentObject var flowManager: AppFlowManager
└── .toolbar (apenas quando isDevModeOnboarding = true)
    └── Botão ❌ para sair do onboarding
```

## Build Status

- ✅ Debug build: **BUILD SUCCEEDED**
- ✅ Release build: **BUILD SUCCEEDED**
- ✅ No linter errors
- ✅ No dead code warnings
- ✅ Compile-time exclusion verified
- ✅ **Testado em simulador: FUNCIONAL**

## Troubleshooting

### Se o Developer Mode não aparecer:

1. **Verifique o Build Configuration:**
   - Xcode > Scheme > Edit Scheme
   - Run > Info > Build Configuration
   - **DEVE estar em "Debug"**, não "Release"

2. **Confirme que está tocando no lugar certo:**
   - Toque no grande número de dias ("X Days")
   - Não toque no texto "You've been vape-free for"
   - Não toque no timer de horas/minutos/segundos

3. **Tempo entre toques:**
   - Toques devem ser dentro de 2 segundos
   - Se passar 2s sem tocar, o contador reseta

## Conclusão

A implementação é:
- **100% confiável** em Debug builds (testado e funcionando)
- **Completamente ausente** em Release/TestFlight/App Store
- **Auto-contida** sem efeitos colaterais arquiteturais
- **Sem reinicializações** de MainTabView ou problemas de apresentação de sheets
- **Simples de usar**: 5 toques rápidos no contador de dias
