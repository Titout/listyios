import SwiftUI
import Foundation

// Structure pour les éléments de liste
struct ListItem: Identifiable {
    let id: String
    var title: String
    var icon: String?
    var numberOfItems: Int
    var price: Double?
    var date: Date
    var color: Color
    
    init(id: String = UUID().uuidString, title: String, icon: String? = nil, numberOfItems: Int = 0, price: Double? = nil, date: Date = Date(), color: Color = .blue) {
        self.id = id
        self.title = title
        self.icon = icon
        self.numberOfItems = numberOfItems
        self.price = price
        self.date = date
        self.color = color
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
let sampleLists: [ListItem] = [
    ListItem(title: "Courses maison", icon: "house", numberOfItems: 12, price: 45.99, color: .blue),
    ListItem(title: "Courses enfants", icon: "person.2", numberOfItems: 8, price: 34.50, color: .orange)
]

// Données pour le graphique des catégories
let weeklyCategoryExpenses = [
    ("Produits laitiers", 12.50, Color(hex: "7086FD")),
    ("Viandes", 7.90, Color(hex: "6FD195")),
    ("Fruits", 4.49, Color(hex: "FFAE4C")),
    ("Légumes", 3.00, Color(hex: "07DBFA")),
    ("Épicerie", 2.00, Color(hex: "988AFC"))
]

// Extension Color pour supporter le code hexadécimal
extension Color {
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