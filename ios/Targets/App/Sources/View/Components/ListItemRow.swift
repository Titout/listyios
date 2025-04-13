import SwiftUI
import SharedKit // Pour ListItemDetail

struct ListItemRow: View {
    // Propriétés
    let title: String
    let quantity: String
    let price: String
    let image: String?
    let isPurchased: Bool
    let isInDetailView: Bool
    let showShadow: Bool
    var onAddButtonTap: (() -> Void)?
    
    var body: some View {
        HStack {
            // Section image + texte
            HStack(spacing: 12) {
                // Image
                if let imageName = image {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 42, height: 42)
                        .cornerRadius(8)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else if !isInDetailView {
                    // On affiche un rectangle de placeholder seulement si ce n'est pas dans la vue détaillée
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 42, height: 42)
                }
                
                // Détails du produit (nom et quantité)
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.system(size: 14))
                        .foregroundColor(isPurchased ? Color(UIColor.systemGray) : .black)
                        .strikethrough(isPurchased)
                    
                    Text(quantity)
                        .font(.system(size: 14))
                        .foregroundColor(Color(UIColor(red: 0.58, green: 0.58, blue: 0.58, alpha: 1)))
                }
            }
            
            Spacer()
            
            // Prix et bouton
            HStack(spacing: 12) {
                Text(price)
                    .font(.system(size: 14))
                    .foregroundColor(Color(UIColor(red: 0.58, green: 0.58, blue: 0.58, alpha: 1)))
                
                // Bouton pour ajouter/cocher l'article
                Button(action: {
                    onAddButtonTap?()
                }) {
                    if isPurchased {
                        // Afficher un checkmark pour les articles achetés
                        Image(systemName: "checkmark.square.fill")
                            .foregroundColor(.green)
                            .frame(width: 24, height: 24)
                    } else {
                        // Afficher un carré vide pour les articles à acheter
                        RoundedRectangle(cornerRadius: 5)
                            .strokeBorder(Color(UIColor(red: 0.58, green: 0.58, blue: 0.58, alpha: 1)), lineWidth: 2)
                            .frame(width: 24, height: 24)
                    }
                }
            }
        }
        .padding(.horizontal, isInDetailView ? 0 : 16)
        .padding(.vertical, 0)
        .frame(height: 42)
        .background(isInDetailView ? Color.clear : Color.white)
        .cornerRadius(isInDetailView ? 0 : 12)
        .shadow(color: (isInDetailView || !showShadow) ? Color.clear : Color.black.opacity(0.05), 
                radius: (isInDetailView || !showShadow) ? 0 : 12, 
                x: 0, y: 2)
    }
}

// Extension pour faciliter l'initialisation avec ListItemDetail
extension ListItemRow {
    init(item: ListItemDetail, isInDetailView: Bool = false, showShadow: Bool = false, onAddButtonTap: (() -> Void)? = nil) {
        self.title = item.name
        self.quantity = item.quantity ?? ""
        self.price = item.price != nil ? String(format: "%.2f €", item.price!) : ""
        self.image = nil // Pas d'image par défaut
        self.isPurchased = item.isCompleted
        self.isInDetailView = isInDetailView
        self.showShadow = showShadow
        self.onAddButtonTap = onAddButtonTap
    }
}

// Prévisualisation pour le composant
#Preview {
    VStack(spacing: 12) {
        ListItemRow(
            title: "Carottes",
            quantity: "2 packs",
            price: "3.20 €",
            image: "carotte",
            isPurchased: false,
            isInDetailView: false,
            showShadow: true
        )
        
        ListItemRow(
            title: "Baguette",
            quantity: "1 pack",
            price: "1.50 €",
            image: "baguette",
            isPurchased: true,
            isInDetailView: false,
            showShadow: true
        )
    }
    .padding()
    .background(Color(UIColor.systemGroupedBackground))
} 