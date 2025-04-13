import SwiftUI

struct StatsView: View {
    // Sélecteur de période
    @State private var selectedPeriod = "Semaine"
    @State private var currentDateRange = "21-28 Mars"
    
    // État pour le magasin sélectionné dans le graphique
    @State private var selectedStore: String? = nil
    
    // Échantillons de données pour les éléments recommandés
    struct RecommendedItem {
        let title: String
        let image: String?
        let quantity: String
        let price: String
    }

    let sampleRecommendedItems: [RecommendedItem] = [
        RecommendedItem(title: "Carottes", image: "carotte", quantity: "2 packs", price: "3.20 €"),
        RecommendedItem(title: "Baguette", image: "baguette", quantity: "1 pack", price: "1.50 €"),
        RecommendedItem(title: "Lait", image: nil, quantity: "1 L", price: "2.10 €")
    ]

    // Structure pour les éléments de liste
    struct ListItem {
        let title: String
        let icon: String
        let numberOfItems: Int
        let price: Double
        let color: Color
        let category: ListCategory
    }

    enum ListCategory {
        case maison
        case enfants
        case courses
        case soiree
    }

    let sampleLists: [ListItem] = [
        ListItem(title: "Courses maison", icon: "house", numberOfItems: 12, price: 45.99, color: Color.blue, category: .maison),
        ListItem(title: "Courses enfants", icon: "person.2", numberOfItems: 8, price: 34.50, color: Color.orange, category: .enfants),
        ListItem(title: "Courses de la semaine", icon: "cart", numberOfItems: 15, price: 62.75, color: Color.green, category: .courses),
        ListItem(title: "Soirée pizza", icon: "fork.knife", numberOfItems: 6, price: 25.30, color: Color.red, category: .soiree)
    ]

    // Données pour le graphique des catégories
    struct CategoryExpense: Identifiable {
        let id = UUID()
        let name: String
        let amount: Double
        let color: Color
    }

    let weeklyCategoryExpenses: [CategoryExpense] = [
        CategoryExpense(name: "Produits laitiers", amount: 12.50, color: Color(hex: "7086FD")),
        CategoryExpense(name: "Viandes", amount: 7.90, color: Color(hex: "6FD195")),
        CategoryExpense(name: "Fruits", amount: 4.49, color: Color(hex: "FFAE4C")),
        CategoryExpense(name: "Légumes", amount: 3.00, color: Color(hex: "07DBFA")),
        CategoryExpense(name: "Épicerie", amount: 2.00, color: Color(hex: "988AFC"))
    ]
    
    // Données pour le graphique des dépenses par magasin (Semaine)
    private let weeklyStoreExpenses: [(String, Double, Double)] = [
        ("Carrefour", 151.0, 50.0),
        ("Action", 70.0, 30.0),
        ("Fresh", 30.0, 15.0),
        ("Pharmacie", 20.0, 10.0)
    ]
    
    // Données pour la vue Mois
    struct WeeklyExpense: Identifiable {
        let id = UUID()
        let weekRange: String
        let amount: Double
    }

    struct MonthlyData {
        struct TopItem {
            let name: String
            let amount: Double
        }
        
        let totalExpense: Double
        let comparison: String
        let topProduct: TopItem
        let topStore: TopItem
        let topWeek: TopItem
        let categoryExpenses: [CategoryExpense]
        let weeklyExpenses: [WeeklyExpense]
    }

    let monthlyData = MonthlyData(
        totalExpense: 289.24,
        comparison: "+2,3% vs mois dernier",
        topProduct: MonthlyData.TopItem(name: "Laitiers", amount: 48.0),
        topStore: MonthlyData.TopItem(name: "Action", amount: 78.0),
        topWeek: MonthlyData.TopItem(name: "08-15", amount: 120.0),
        categoryExpenses: [
            CategoryExpense(name: "Produits laitiers", amount: 48.50, color: Color(hex: "7086FD")),
            CategoryExpense(name: "Viandes", amount: 35.20, color: Color(hex: "6FD195")),
            CategoryExpense(name: "Épicerie", amount: 88.10, color: Color(hex: "988AFC")),
            CategoryExpense(name: "Fruits", amount: 22.40, color: Color(hex: "FFAE4C")),
            CategoryExpense(name: "Légumes", amount: 15.00, color: Color(hex: "07DBFA"))
        ],
        weeklyExpenses: [
            WeeklyExpense(weekRange: "01-07", amount: 85.50),
            WeeklyExpense(weekRange: "08-15", amount: 120.20),
            WeeklyExpense(weekRange: "16-23", amount: 45.30),
            WeeklyExpense(weekRange: "24-31", amount: 38.24)
        ]
    )
    
    var body: some View {
            ZStack {
            // Fond de l'écran
            Color(hex: "F7F7F7")
                    .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // En-tête avec titre
                headerView
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Sélecteur de période et date
                        dateRangeSelector
                        
                        // Sélecteur Semaine/Mois
                        periodSelector
                        
                        // Contenu principal
                        statsContent
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 80) // Espacement pour la barre de navigation
                }
            }
        }
    }
    
    // En-tête avec titre
    private var headerView: some View {
        HStack {
                        Text("Statistiques")
                .font(.custom("Roboto", size: 28).weight(.heavy))
                .foregroundColor(.black)
            
            Spacer()
            
            // Icône cloche de notifications
            Image(systemName: "bell")
                .font(.system(size: 22))
                            .foregroundColor(.black)
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 24)
    }
    
    // Sélecteur de date
    private var dateRangeSelector: some View {
        HStack {
            Button(action: {
                // Action pour naviguer vers la gauche
            }) {
                ZStack {
                    Circle()
                        .fill(Color.black)
                        .frame(width: 28, height: 28)
                    
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                }
            }
            
            Spacer()
            
            Text(currentDateRange)
                .font(.custom("Roboto", size: 14))
                .foregroundColor(Color(hex: "000000", alpha: 0.9))
            
            Spacer()
            
            Button(action: {
                // Action pour naviguer vers la droite
            }) {
                ZStack {
                    Circle()
                        .fill(Color.black)
                        .frame(width: 28, height: 28)
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(hex: "EDEDED"))
        .cornerRadius(999)
    }
    
    // Sélecteur Semaine/Mois
    private var periodSelector: some View {
        HStack(spacing: 0) {
            Button(action: {
                selectedPeriod = "Semaine"
            }) {
                ZStack {
                    Rectangle()
                        .fill(selectedPeriod == "Semaine" ? Color.white : Color.clear)
                        .cornerRadius(12)
                        .shadow(color: selectedPeriod == "Semaine" ? Color.black.opacity(0.1) : Color.clear, radius: 4)
                    
                    Text("Semaine")
                        .font(.custom("Roboto", size: 14))
                        .foregroundColor(.black)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                }
            }
            .frame(maxWidth: .infinity)
            
                Button(action: {
                selectedPeriod = "Mois"
            }) {
                ZStack {
                    Rectangle()
                        .fill(selectedPeriod == "Mois" ? Color.white : Color.clear)
                        .cornerRadius(12)
                        .shadow(color: selectedPeriod == "Mois" ? Color.black.opacity(0.1) : Color.clear, radius: 4)
                    
                    Text("Mois")
                        .font(.custom("Roboto", size: 14))
                        .foregroundColor(.black)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(4)
        .background(Color(hex: "EDEDED"))
        .cornerRadius(16)
    }
    
    // Contenu principal des statistiques
    private var statsContent: some View {
        VStack(spacing: 24) {
            if selectedPeriod == "Semaine" {
                // --- VUE SEMAINE ---
                weeklyPieChartView
                weeklyCategoryBreakdownView
                weeklyItemCountView
                weeklyStoreExpensesView
                
            } else { // selectedPeriod == "Mois"
                // --- VUE MOIS ---
                monthlyPieChartView
                monthlyTopExpenseView
                monthlyCategoryBreakdownView
                monthlyWeeklyExpensesChartView
            }
        }
    }
    
    // --- Vues Semaine (renommées pour clarté) ---
    
    // Graphique circulaire avec total (Semaine)
    private var weeklyPieChartView: some View {
        VStack {
            ZStack {
                // Cercle pour le graphique circulaire
                Circle()
                    .trim(from: 0, to: 0.25)
                    .stroke(Color(hex: "7086FD"), style: StrokeStyle(lineWidth: 16, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 220, height: 220)
                
                Circle()
                    .trim(from: 0.25, to: 0.45)
                    .stroke(Color(hex: "FFAE4C"), style: StrokeStyle(lineWidth: 16, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 220, height: 220)
                
                Circle()
                    .trim(from: 0.45, to: 0.65)
                    .stroke(Color(hex: "7086FD").opacity(0.7), style: StrokeStyle(lineWidth: 16, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 220, height: 220)
                
                Circle()
                    .trim(from: 0.65, to: 0.85)
                    .stroke(Color(hex: "6FD195"), style: StrokeStyle(lineWidth: 16, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 220, height: 220)
                
                Circle()
                    .trim(from: 0.85, to: 1)
                    .stroke(Color(hex: "07DBFA"), style: StrokeStyle(lineWidth: 16, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 220, height: 220)
                
                // Montant total au centre
                VStack(spacing: 4) {
                    Text("289.24€")
                        .font(.custom("Roboto", size: 28).weight(.bold))
                        .foregroundColor(.black)
                    
                    Text("+2,3% vs mois dernier")
                        .font(.custom("Roboto", size: 14))
                        .foregroundColor(.black)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(Color.white)
        .cornerRadius(16)
    }
    
    // Répartition par catégorie (Semaine)
    private var weeklyCategoryBreakdownView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Top catégories")
                .font(.custom("Roboto", size: 22).weight(.bold))
                .foregroundColor(Color(hex: "000000", alpha: 0.9))
            
            VStack(spacing: 12) {
                ForEach(Listy.weeklyCategoryExpenses, id: \.0) { category, value, color in // Utilise weeklyCategoryExpenses
                    HStack {
                        HStack(spacing: 4) {
                            Circle().fill(color).frame(width: 12, height: 12)
                            Text(category)
                                .font(.custom("Roboto", size: 14))
                                .foregroundColor(Color(hex: "000000", alpha: 0.7))
                        }
                        Spacer()
                        Text("\(String(format: "%.2f", value))€")
                            .font(.custom("Roboto", size: 14))
                            .foregroundColor(Color(hex: "000000", alpha: 0.7))
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
    }
    
    // Nombre d'articles achetés (Semaine)
    private var weeklyItemCountView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Nombre d'articles achetés")
                .font(.custom("Roboto", size: 22).weight(.bold))
                .foregroundColor(Color(hex: "000000", alpha: 0.9))
            
            Text("19") // Exemple Semaine
                .font(.custom("Roboto", size: 28).weight(.heavy))
                .foregroundColor(Color(hex: "000000", alpha: 0.9))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
    }
    
    // Dépenses par magasin (Semaine)
    private var weeklyStoreExpensesView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Dépenses par magasins")
                .font(.custom("Roboto", size: 22).weight(.bold))
                .foregroundColor(Color(hex: "000000", alpha: 0.9))

            GeometryReader { geometry in
                let availableWidth = geometry.size.width
                VStack(spacing: 36) {
                    ForEach(weeklyStoreExpenses, id: \.0) { storeName, value, lastValue in // Utilise weeklyStoreExpenses
                        let maxBarWidth = availableWidth
                        let currentBarWidth = min(CGFloat(value) * 1.2, maxBarWidth)
                        let lastBarWidth = min(CGFloat(lastValue) * 1.2, maxBarWidth)

                        VStack(alignment: .leading, spacing: 8) {
                            Text(storeName)
                                .font(.custom("Roboto", size: 16))
                                .foregroundColor(Color(hex: "1C1B1F", alpha: 0.8))

                            VStack(alignment: .leading, spacing: 2) {
                                // Barre actuelle
                                HStack(spacing: 8) {
                                    Rectangle().fill(Color.black).frame(width: currentBarWidth, height: 20).cornerRadius(4)
                                    if selectedStore == storeName {
                                        Text("\(Int(value))€").font(.custom("Roboto", size: 14).bold()).foregroundColor(.black).transition(AnyTransition.opacity.combined(with: .offset(x: -10)))
                                    }
                                    Spacer()
                                }
                                .frame(height: 20)
                                .contentShape(Rectangle())
                                .onTapGesture { handleTap(storeName: storeName) }

                                // Barre précédente
                                HStack(spacing: 8) {
                                    Rectangle().fill(Color(hex: "E0E0E0")).frame(width: lastBarWidth, height: 20).cornerRadius(4)
                                    if selectedStore == storeName {
                                        Text("\(Int(lastValue))€").font(.custom("Roboto", size: 14).bold()).foregroundColor(.gray).transition(AnyTransition.opacity.combined(with: .offset(x: -10)))
                                    }
                                    Spacer()
                                }
                                .frame(height: 20)
                                .contentShape(Rectangle())
                                .onTapGesture { handleTap(storeName: storeName) }
                            }
                        }
                    }
                }
            }
             .frame(height: CGFloat(weeklyStoreExpenses.count) * 110) // Utilise weeklyStoreExpenses.count

            // Légende en bas
            HStack(spacing: 24) {
                Spacer()
                HStack(spacing: 4) {
                    Rectangle().fill(Color.black).frame(width: 12, height: 12).cornerRadius(2)
                    Text("Cette semaine").font(.custom("Roboto", size: 14)).foregroundColor(Color(hex: "1C1B1F", alpha: 0.8))
                }
                HStack(spacing: 4) {
                    Rectangle().fill(Color(hex: "E0E0E0")).frame(width: 12, height: 12).cornerRadius(2)
                    Text("Semaine dernière").font(.custom("Roboto", size: 14)).foregroundColor(Color(hex: "1C1B1F", alpha: 0.8))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 24)
        .background(Color.white)
        .cornerRadius(12)
    }
    
    // --- Vues Mois --- (Implémentation)

    // Graphique circulaire (Mois)
    private var monthlyPieChartView: some View {
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
                
                // Montant total au centre (Mois)
                VStack(spacing: 4) {
                    Text("289.24€")
                        .font(.custom("Roboto", size: 28).weight(.bold))
                        .foregroundColor(.black)
                    
                    Text("+2,3% vs mois dernier")
                        .font(.custom("Roboto", size: 14))
                        .foregroundColor(.black)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(Color.white)
        .cornerRadius(16)
    }

    // Top Dépenses (Mois)
    private var monthlyTopExpenseView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ton top dépense")
                .font(.custom("Roboto", size: 22).weight(.bold)) // Style Figma
                .foregroundColor(Color(hex: "000000", alpha: 0.9))
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Produits : \(monthlyData.topProduct.name) \(Int(monthlyData.topProduct.amount))€")
                    .font(.custom("Roboto", size: 14)) // Style Figma
                    .foregroundColor(Color(hex: "000000", alpha: 0.7))
                
                Text("Magasin : \(monthlyData.topStore.name) \(Int(monthlyData.topStore.amount))€")
                    .font(.custom("Roboto", size: 14)) // Style Figma
                    .foregroundColor(Color(hex: "000000", alpha: 0.7))
                
                Text("Semaine \(monthlyData.topWeek.name) : \(Int(monthlyData.topWeek.amount))€")
                    .font(.custom("Roboto", size: 14)) // Style Figma
                    .foregroundColor(Color(hex: "000000", alpha: 0.7))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(12)
    }
    
    // Répartition par catégorie (Mois)
    private var monthlyCategoryBreakdownView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Top catégories")
                .font(.custom("Roboto", size: 22).weight(.bold))
                .foregroundColor(Color(hex: "000000", alpha: 0.9))
            
            VStack(spacing: 12) {
                ForEach(monthlyData.categoryExpenses) { expense in
                    HStack {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(expense.color)
                                .frame(width: 12, height: 12)
                            Text(expense.name)
                                .font(.custom("Roboto", size: 14))
                                .foregroundColor(Color(hex: "000000", alpha: 0.7))
                        }
                        Spacer()
                        Text("\(String(format: "%.2f", expense.amount))€")
                            .font(.custom("Roboto", size: 14))
                            .foregroundColor(Color(hex: "000000", alpha: 0.7))
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
    }

    // Dépenses par semaine (Mois)
    private var monthlyWeeklyExpensesChartView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Dépenses sur le mois")
                .font(.custom("Roboto", size: 22).weight(.bold))
                .foregroundColor(Color(hex: "000000", alpha: 0.9))

            GeometryReader { geometry in
                let availableWidth = geometry.size.width
                VStack(spacing: 32) {
                    ForEach(monthlyData.weeklyExpenses) { expense in
                        let maxBarWidth = availableWidth
                        let currentBarWidth = min(CGFloat(expense.amount) * 1.2, maxBarWidth)
                        let previousBarWidth = min(CGFloat(expense.amount * 0.8) * 1.2, maxBarWidth)

                        VStack(alignment: .leading, spacing: 8) {
                            Text(expense.weekRange)
                                .font(.custom("Roboto", size: 16))
                                .foregroundColor(Color(hex: "1C1B1F", alpha: 0.8))

                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 8) {
                                    Rectangle()
                                        .fill(Color.black)
                                        .frame(width: currentBarWidth, height: 20)
                                        .cornerRadius(4)
                                    if selectedStore == expense.weekRange {
                                        Text("\(Int(expense.amount))€")
                                            .font(.custom("Roboto", size: 14).bold())
                                            .foregroundColor(.black)
                                            .transition(AnyTransition.opacity.combined(with: .offset(x: -10)))
                                    }
                                    Spacer()
                                }
                                .frame(height: 20)
                                .contentShape(Rectangle())
                                .onTapGesture { handleMonthTap(weekRange: expense.weekRange) }

                                HStack(spacing: 8) {
                                    Rectangle()
                                        .fill(Color(hex: "E0E0E0"))
                                        .frame(width: previousBarWidth, height: 20)
                                        .cornerRadius(4)
                                    if selectedStore == expense.weekRange {
                                        Text("\(Int(expense.amount * 0.8))€")
                                            .font(.custom("Roboto", size: 14).bold())
                                            .foregroundColor(.gray)
                                            .transition(AnyTransition.opacity.combined(with: .offset(x: -10)))
                                    }
                                    Spacer()
                                }
                                .frame(height: 20)
                                .contentShape(Rectangle())
                                .onTapGesture { handleMonthTap(weekRange: expense.weekRange) }
                            }
                        }
                    }
                }
            }
            .frame(height: CGFloat(monthlyData.weeklyExpenses.count) * 100)

            // Légende
            HStack(spacing: 24) {
                Spacer()
                HStack(spacing: 4) {
                    Rectangle()
                        .fill(Color.black)
                        .frame(width: 12, height: 12)
                        .cornerRadius(2)
                    Text("Ce mois")
                        .font(.custom("Roboto", size: 14))
                        .foregroundColor(Color(hex: "1C1B1F", alpha: 0.8))
                }
                HStack(spacing: 4) {
                    Rectangle()
                        .fill(Color(hex: "E0E0E0"))
                        .frame(width: 12, height: 12)
                        .cornerRadius(2)
                    Text("Mois dernier")
                        .font(.custom("Roboto", size: 14))
                        .foregroundColor(Color(hex: "1C1B1F", alpha: 0.8))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 24)
        .background(Color.white)
        .cornerRadius(12)
    }

    // Fonction pour gérer les taps dans la vue mensuelle
    private func handleMonthTap(weekRange: String) {
        withAnimation(.easeInOut(duration: 0.2)) {
            if selectedStore == weekRange {
                selectedStore = nil
            } else {
                selectedStore = weekRange
            }
        }
    }

    // Fonction séparée pour la logique du tap (peut-être à adapter si besoin pour le mois)
    private func handleTap(storeName: String) {
        withAnimation(.easeInOut(duration: 0.2)) {
            if selectedStore == storeName {
                selectedStore = nil
            } else {
                selectedStore = storeName
            }
        }
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

#Preview {
    StatsView()
} 
