import SwiftUI
import Foundation

// Structure pour les éléments de liste
public struct ListItem: Identifiable {
    public let id: String
    public var title: String
    public var icon: String?
    public var numberOfItems: Int
    public var price: Double?
    public var date: Date
    public var color: SwiftUI.Color
    public var category: ListCategory?
    
    public init(id: String = UUID().uuidString, title: String, icon: String? = nil, numberOfItems: Int = 0, price: Double? = nil, date: Date = Date(), color: SwiftUI.Color = .blue, category: ListCategory? = nil) {
        self.id = id
        self.title = title
        self.icon = icon
        self.numberOfItems = numberOfItems
        self.price = price
        self.date = date
        self.color = color
        self.category = category
    }
}

// Énumération pour les catégories de liste
public enum ListCategory: String, CaseIterable, Identifiable {
    case maison = "maison"
    case enfants = "enfants"
    case courses = "courses"
    case soiree = "soiree"
    
    public var id: String { self.rawValue }
    
    public var systemIconName: String {
        switch self {
        case .maison: return "house"
        case .enfants: return "person.2"
        case .courses: return "cart"
        case .soiree: return "fork.knife"
        }
    }
    
    @ViewBuilder
    public func imageView(size: CGFloat) -> some View {
        Image(systemName: systemIconName)
            .font(.system(size: size))
    }
    
    public var displayName: String {
        switch self {
        case .maison: return "Maison"
        case .enfants: return "Enfants"
        case .courses: return "Courses"
        case .soiree: return "Soirée"
        }
    }
}

// Structure pour les éléments recommandés
struct RecommendedItem: Identifiable {
    let id = UUID()
    let title: String
    let image: String?
    let quantity: String
    let price: String
}

// Échantillons de données pour les éléments recommandés
let sampleRecommendedItems: [RecommendedItem] = [
    RecommendedItem(title: "Carottes", image: "carotte", quantity: "2 packs", price: "3.20 €"),
    RecommendedItem(title: "Baguette", image: "baguette", quantity: "1 pack", price: "1.50 €"),
    RecommendedItem(title: "Lait", image: nil, quantity: "1 L", price: "2.10 €")
]

// Échantillons de données pour les listes
public let sampleLists: [ListItem] = [
    ListItem(title: "Courses maison", icon: "house", numberOfItems: 12, price: 45.99, color: SwiftUI.Color.blue, category: .maison),
    ListItem(title: "Courses enfants", icon: "person.2", numberOfItems: 8, price: 34.50, color: SwiftUI.Color.orange, category: .enfants),
    ListItem(title: "Courses de la semaine", icon: "cart", numberOfItems: 15, price: 62.75, color: SwiftUI.Color.green, category: .courses),
    ListItem(title: "Soirée pizza", icon: "fork.knife", numberOfItems: 6, price: 25.30, color: SwiftUI.Color.red, category: .soiree)
]

// Données pour le graphique des catégories
let weeklyCategoryExpenses = [
    ("Produits laitiers", 12.50, SwiftUI.Color(hex: "7086FD")),
    ("Viandes", 7.90, SwiftUI.Color(hex: "6FD195")),
    ("Fruits", 4.49, SwiftUI.Color(hex: "FFAE4C")),
    ("Légumes", 3.00, SwiftUI.Color(hex: "07DBFA")),
    ("Épicerie", 2.00, SwiftUI.Color(hex: "988AFC"))
]

// Extension Color pour supporter le code hexadécimal
extension SwiftUI.Color {
    init(hex: String, alpha: Double = 1.0) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b, opacity: alpha)
    }
}

// Structure pour les ingrédients
struct IngredientItem: Identifiable {
    let id = UUID()
    let name: String
    let quantity: String
    let unit: String
} 