import SwiftUI
import UIKit

public struct ContentView: View {
    @State private var isAuthenticated = false
    @State private var checkingAuth = true
    
    public init() {}
    
    public var body: some View {
        Group {
            if checkingAuth {
                ZStack {
                    Color(red: 0.08, green: 0.12, blue: 0.2)
                        .ignoresSafeArea()
                    ProgressView()
                        .tint(.white)
                }
            } else if isAuthenticated {
                TabView {
                    RecursosView()
                        .tabItem {
                            Label("Explorar", systemImage: "safari.fill")
                        }
                    
                    ProjetosView()
                        .tabItem {
                            Label("Projetos", systemImage: "folder.fill")
                        }
                    
                    EntidadesView()
                        .tabItem {
                            Label("Entidades", systemImage: "building.2.fill")
                        }
                    
                    PerfilView(isAuthenticated: $isAuthenticated)
                        .tabItem {
                            Label("Perfil", systemImage: "person.crop.circle.fill")
                        }
                    
                    SobreView()
                        .tabItem {
                            Label("Sobre", systemImage: "info.circle.fill")
                        }
                }
                .tint(Color(red: 0.06, green: 0.49, blue: 0.78))
            } else {
                LoginView(isAuthenticated: $isAuthenticated)
            }
        }
        .onAppear {
            configureTabBarAppearance()
            checkAuthToken()
        }
    }
    
    private func checkAuthToken() {
        if KeychainHelper.getToken() != nil {
            isAuthenticated = true
        } else {
            isAuthenticated = false
        }
        checkingAuth = false
    }

    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 8/255, green: 20/255, blue: 40/255, alpha: 0.96)

        let selectedColor = UIColor(red: 111/255, green: 219/255, blue: 245/255, alpha: 1)
        let normalColor = UIColor.white.withAlphaComponent(0.65)

        appearance.stackedLayoutAppearance.selected.iconColor = selectedColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: selectedColor]
        appearance.stackedLayoutAppearance.normal.iconColor = normalColor
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: normalColor]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

