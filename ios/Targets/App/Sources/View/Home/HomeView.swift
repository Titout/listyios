import SwiftUI
import SharedKit

// Clé pour l'environnement qui permet de communiquer avec MainTabView
struct TabSelectionKey: EnvironmentKey {
    static let defaultValue: Binding<Int> = .constant(0)
}

extension EnvironmentValues {
    var tabSelection: Binding<Int> {
        get { self[TabSelectionKey.self] }
        set { self[TabSelectionKey.self] = newValue }
    }
}

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @Environment(\.tabSelection) private var tabSelection
    
    // État pour la sélection de liste et l'affichage de la vue détaillée
    @State private var selectedList: ListItem? = nil
    @State private var showDetailView = false
    @State private var showEditMenu = false
    @State private var selectedListForEdit: ListItem? = nil
    @State private var showRecommendations: Bool = false
    @State private var navigateToListView = false
    @State private var showNotifications = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Couleur de fond
                Color(UIColor.systemGroupedBackground)
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 36) {
                        // Résumé hebdomadaire
                        weeklySummarySection()
                        
                        // Section du piechart des dépenses
                        monthlyExpensesSection()
                        
                        // Section des listes
                        yourListsSection()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Bonjour \(viewModel.userName) 👋")
                        .font(.system(size: 28, weight: .bold))
                        .padding(.top, 60)
                        .padding(.bottom, 36)
                        .padding(.leading, 12)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showNotifications.toggle()
                    } label: {
                        Image(systemName: "bell")
                            .font(.system(size: 20))
                            .foregroundColor(.primary)
                    }
                    .padding(.top, 60)
                    .padding(.bottom, 36)
                    .padding(.trailing, 12)
                }
            }
            .sheet(isPresented: $showDetailView) {
                if let list = selectedList {
                    DetailListView(list: list)
                }
            }
            .sheet(isPresented: $showNotifications) {
                NotificationsView()
            }
        
        }

    }
    
    // MARK: - Sections
    private func weeklySummarySection() -> some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Cette semaine")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color(UIColor(red: 0.11, green: 0.11, blue: 0.13, alpha: 1)))
            
            HStack(spacing: 16) {
                // Budget total
                VStack(alignment: .leading, spacing: 4) {
                    Text("Budget total")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    Text("\(String(format: "%.2f", totalBudget)) €")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(2)
                .background(Color.white)
                .cornerRadius(12)
                
                // Nombre d'articles
                VStack(alignment: .leading, spacing: 4) {
                    Text("Articles")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    Text("\(totalItems)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(2)
                .background(Color.white)
                .cornerRadius(12)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
    }
    
    private func monthlyExpensesSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Dépenses mensuelles")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color(UIColor(red: 0.11, green: 0.11, blue: 0.13, alpha: 1)))
            
            VStack {
                ZStack {
                    // Cercle pour le graphique circulaire
                    Circle()
                        .trim(from: 0, to: 0.25)
                        .stroke(Color(hex: "FFAE4C"), style: StrokeStyle(lineWidth: 16, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 220, height: 220)
                    
                    Circle()
                        .trim(from: 0.25, to: 0.5)
                        .stroke(Color(hex: "07DBFA"), style: StrokeStyle(lineWidth: 16, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 220, height: 220)
                    
                    Circle()
                        .trim(from: 0.5, to: 0.75)
                        .stroke(Color(hex: "7086FD"), style: StrokeStyle(lineWidth: 16, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 220, height: 220)
                    
                    Circle()
                        .trim(from: 0.75, to: 1)
                        .stroke(Color(hex: "6FD195"), style: StrokeStyle(lineWidth: 16, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 220, height: 220)
                    
                    // Montant total au centre
                    VStack(spacing: 4) {
                        Text("\(String(format: "%.2f", totalBudget))€")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.black)
                        
                        Text("+2,3% vs mois dernier")
                            .font(.system(size: 14))
                            .foregroundColor(.black)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 32)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
    }
    
    private func yourListsSection() -> some View {
        VStack(alignment: .leading, spacing: 24) {
            // En-tête de la section
            Text("Vos listes")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color(UIColor(red: 0.11, green: 0.11, blue: 0.13, alpha: 1)))
            
            // Liste principale
            if !viewModel.lists.isEmpty {
                // Liste principale (première liste)
                listCard(list: viewModel.lists[0])
                
                // Liste secondaire (deuxième liste si disponible)
                if viewModel.lists.count > 1 {
                    listCard(list: viewModel.lists[1])
                }
            } else {
                Text("Aucune liste disponible")
                    .foregroundColor(.secondary)
                    .padding()
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
    }
    
    // Carte pour chaque liste
    private func listCard(list: ListItem) -> some View {
        ListCardFactory(
            list: list,
            onTap: {
                selectedList = list
                showDetailView = true
            },
            onDelete: { deletedList in
                // Supprimer la liste de l'array
                Task {
                    await viewModel.deleteList(deletedList)
                }
            }
        )
    }
    
    // MARK: - Computed Properties
    private var totalBudget: Double {
        viewModel.lists.compactMap { $0.price }.reduce(0, +)
    }
    
    private var totalItems: Int {
        viewModel.lists.reduce(0) { $0 + $1.numberOfItems }
    }
}

// Extension pour créer des couleurs à partir de valeurs hexadécimales
fileprivate extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 
