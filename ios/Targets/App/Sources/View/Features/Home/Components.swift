import SwiftUI

// MARK: - ListCardFactory - Un composant pour afficher une carte de liste
struct ListCardFactory: View {
    let list: ListItem
    let onTap: () -> Void
    let onDelete: (ListItem) -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icône de la liste
                if let icon = list.icon {
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(list.color)
                        .frame(width: 48, height: 48)
                        .background(list.color.opacity(0.15))
                        .cornerRadius(12)
                }
                
                // Informations de la liste
                VStack(alignment: .leading, spacing: 4) {
                    Text(list.title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 12) {
                        Text("\(list.numberOfItems) items")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        
                        if let price = list.price {
                            Text("\(String(format: "%.2f", price)) €")
                                .font(.system(size: 14))
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                Spacer()
                
                // Flèche de navigation
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(UIColor.systemGray3))
            }
            .padding(12)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .contextMenu {
            Button(role: .destructive) {
                onDelete(list)
            } label: {
                Label("Supprimer", systemImage: "trash")
            }
        }
    }
}

// MARK: - ListItemRow - Un composant pour afficher un élément de liste détaillé
struct ListItemRow: View {
    let image: String?
    let title: String
    let quantity: String
    let price: String
    let isPurchased: Bool
    let isInDetailView: Bool
    let showShadow: Bool
    var onAddButtonTap: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Image de l'élément
            if let imageName = image {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            } else {
                // Image placeholder
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 48, height: 48)
                    .cornerRadius(8)
            }
            
            // Informations du produit
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                HStack(spacing: 8) {
                    Text(quantity)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    
                    Text(price)
                        .font(.system(size: 14))
                        .foregroundColor(.blue)
                }
            }
            
            Spacer()
            
            // Bouton d'ajout
            Button(action: onAddButtonTap) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .applyIf(showShadow) { view in
            view.shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
}

// Extension pour conditionnellement appliquer un modificateur
extension View {
    @ViewBuilder
    func applyIf<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// Vue simple pour afficher les notifications
struct NotificationsView: View {
    var body: some View {
        VStack {
            Text("Notifications")
                .font(.title)
                .padding()
            
            Text("Vous n'avez pas de notifications")
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

// Vue simple pour la vue détaillée d'une liste
struct DetailListView: View {
    let list: ListItem
    
    var body: some View {
        VStack {
            Text(list.title)
                .font(.title)
                .padding()
            
            Text("\(list.numberOfItems) items")
                .foregroundColor(.secondary)
            
            if let price = list.price {
                Text("Total: \(String(format: "%.2f", price)) €")
                    .foregroundColor(.blue)
                    .padding()
            }
            
            Spacer()
        }
    }
}

// Vue simple pour le menu d'édition de liste
struct ListEditMenu: View {
    let list: ListItem
    let onDelete: (ListItem) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Options pour \(list.title)")
                .font(.headline)
                .padding(.top)
            
            Button(action: {
                onDelete(list)
            }) {
                HStack {
                    Image(systemName: "trash")
                    Text("Supprimer la liste")
                }
                .foregroundColor(.red)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red.opacity(0.1))
                .cornerRadius(10)
            }
            
            Spacer()
        }
        .padding()
    }
}

// Vue simple pour ListView (référencée dans HomeView)
struct SimpleListView: View {
    var body: some View {
        Text("Vue de listes")
            .font(.title)
    }
} 