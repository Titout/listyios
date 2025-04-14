import SwiftUI

struct AddListView: View {
    @Environment(\.dismiss) private var dismiss
    
    // États pour les champs du formulaire
    @State private var selectedCategory: ListCategory = .courses
    @State private var showShareSheet: Bool = false
    @State private var shareLink: String = ""
    
    var onAddList: ((ListItem) -> Void)?
    
    var body: some View {
           // Contenu principal directement dans un VStack
           VStack(spacing: 16) { // VStack principal - Début { 1 }
               // Indicateur de pilule pour fermer la modale
               Rectangle()
                   .fill(Color.gray.opacity(0.5))
                   .frame(width: 40, height: 5)
                   .cornerRadius(2.5)
                   // Pas de padding top ici pour être prêt pour .sheet

               // Titre aligné à gauche
               Text("Nouvelle liste")
                   .font(.title2)
                   .fontWeight(.bold)
                   .padding(.top, 8)
                   .padding(.bottom, 8)
                   .frame(maxWidth: .infinity, alignment: .leading)

               // Section Catégorie
               VStack(alignment: .leading, spacing: 8) { // Début { 2 }
                   Text("SÉLECTIONNEZ UNE CATÉGORIE")
                       .font(.caption)
                       .fontWeight(.semibold)
                       .foregroundColor(.gray)

                   // Correction de l'emplacement de l'accolade et des modificateurs
                   HStack { // Début { 3 }
                       Text("Catégorie")
                           .foregroundColor(.black) // Gardé tel quel

                       Spacer()

                       Picker("", selection: $selectedCategory) { // Début { 4 }
                           ForEach(ListCategory.allCases) { category in // Début { 5 }
                               HStack { // Début { 6 }
                                   category.imageView(size: 20)
                                   Text(category.rawValue)
                               } // Fin { 6 }
                               .tag(category)
                           } // Fin { 5 }
                       } // Fin { 4 }
                       .pickerStyle(.menu)
                       .accentColor(.black) // Gardé tel quel

                   } // Fin { 3 } <--- Accolade du HStack déplacée ici
                   // Modificateurs appliqués au HStack
                   .padding(.horizontal, 12)
                   .padding(.vertical, 10)
                   .background(Color.white) // Gardé tel quel
                   .cornerRadius(10)

               } // Fin { 2 } Vstack Catégorie

               // Texte du partage (inchangé)
               Text("Lorsque vous aller créer cette liste, vous pourrez générer un lien de partage pour inviter des collaborateurs.")
                   .font(.caption)
                   .foregroundColor(.gray)
                   .multilineTextAlignment(.center)
                   .fixedSize(horizontal: false, vertical: true)
                   .padding(.horizontal, 8)

               // Bouton de création (inchangé)
               Button(action: {
                   createList()
               }) { // Début { Action Button }
                   Text("Créer la liste")
                       .font(.system(size: 16, weight: .semibold))
                       .foregroundColor(.white)
                       .frame(maxWidth: .infinity)
                       .padding(.vertical, 14)
                       .background(Color.black) // Gardé tel quel
                       .cornerRadius(10)
               } // Fin { Action Button }
               .padding(.bottom, 32) // Padding sous le bouton

           } // Fin { 1 } VStack principal
           // Modificateurs appliqués au VStack principal
           .padding(.horizontal, 24) // Padding horizontal global
           // On ne remet PAS le .background et .clipShape ici si on utilise .sheet
           .fullScreenCover(isPresented: $showShareSheet) { // Modificateur pour la vue de partage
               ShareListView(shareLink: $shareLink, onDismiss: {
                   showShareSheet = false
                   dismiss()
               })
           }
           // L'accolade en trop a été supprimée ici
       } // Fin body
    
    private func closeView() {
        // Fermer la vue en appelant la fonction de rappel
        dismiss()
    }
    
    private func createList() {
        // Créer une nouvelle liste avec le titre de la catégorie sélectionnée
        let newList = ListItem(
            title: selectedCategory.displayName,
            icon: selectedCategory.systemIconName,
            numberOfItems: 0,
            price: 0.0,
            date: Date(),
            color: .blue,
            category: selectedCategory
        )
        
        // Appeler le callback
        onAddList?(newList)
        
        // Générer un lien fictif (à remplacer par une vraie implémentation)
        shareLink = "https://listy.app/share/\(newList.id)"
        
        // Afficher la vue de partage
        showShareSheet = true
    }
}

// Vue pour le partage de liste
struct ShareListView: View {
    @Binding var shareLink: String
    var onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            // Fond semi-transparent sur tout l'écran
            Color.black.opacity(0.4)
                .ignoresSafeArea(.all)
                .onTapGesture {
                    onDismiss()
                }
            
            // Contenu principal centré
            VStack(spacing: 16) {
                // Indicateur de pilule
                Rectangle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 40, height: 5)
                    .cornerRadius(2.5)
                    .padding(.top, 16)
                
                // Titre centré, sans croix
                Text("Liste créée avec succès!")
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding(.top, 4)
                
                // Contenu de la confirmation
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.green)
                    .padding(.top, 8)
                
                Text("Partagez cette liste avec d'autres personnes en utilisant ce lien.")
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 16)
                
                // Lien de partage
                HStack {
                    Text(shareLink)
                        .font(.caption)
                        .padding(8)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(6)
                        .lineLimit(1)
                    
                    Button(action: {
                        UIPasteboard.general.string = shareLink
                    }) {
                        Image(systemName: "doc.on.doc")
                            .foregroundColor(.blue)
                            .padding(6)
                    }
                }
                .padding(.horizontal, 16)
                
                // Boutons d'action
                HStack(spacing: 10) {
                    Button(action: {
                        onDismiss()
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Partager")
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 14)
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                    
                    Button("Terminé") {
                        onDismiss()
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 14)
                    .foregroundColor(.primary)
                    .background(Color(UIColor.systemGray5))
                    .cornerRadius(10)
                }
                .padding(.vertical, 16)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            .background(Color.white)
            .cornerRadius(20)
            .frame(width: UIScreen.main.bounds.width - 48)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

// Ajout de la structure RoundedCornerShape en bas du fichier
struct RoundedCornerShape: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    AddListView()
} 
