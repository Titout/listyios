import SwiftUI
import VisionKit
import UIKit
import SharedKit

struct ScanListView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showScanner = true
    @State private var scannedItems: [ListItemDetail] = []
    @State private var selectedListId: UUID? = nil
    @State private var showListSelection = false
    
    // Liste fictive d'articles détectés (simuler le résultat de l'OCR)
    private let mockedScannedItems = [
        ListItemDetail(name: "Lait", price: 1.20, isCompleted: false, quantity: "1L", image: nil),
        ListItemDetail(name: "Pâtes", price: 0.90, isCompleted: false, quantity: "500g", image: nil),
        ListItemDetail(name: "Beurre", price: 2.50, isCompleted: false, quantity: "250g", image: nil),
        ListItemDetail(name: "Tomates", price: 1.80, isCompleted: false, quantity: "6 pièces", image: nil),
        ListItemDetail(name: "Pain", price: 1.10, isCompleted: false, quantity: "1 baguette", image: nil),
        ListItemDetail(name: "Pommes", price: 2.30, isCompleted: false, quantity: "1kg", image: nil)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    if !scannedItems.isEmpty {
                        // Afficher les articles détectés
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(scannedItems) { item in
                                    ListItemRow(
                                        title: item.name,
                                        quantity: item.quantity ?? "",
                                        price: item.price != nil ? String(format: "%.2f €", item.price!) : "",
                                        image: nil,
                                        isPurchased: item.isCompleted,
                                        isInDetailView: false,
                                        showShadow: true
                                    )
                                    .padding(.horizontal, 16)
                                }
                            }
                            .padding(.vertical, 16)
                        }
                        
                        Spacer()
                        
                        // Bouton pour ajouter à une liste
                        Button {
                            showListSelection = true
                        } label: {
                            Text("Ajouter à ma liste")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.black)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 24)
                    } else {
                        // Message d'attente pendant le scan
                        Text("Scan en cours...")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.gray)
                    }
                }
                .navigationTitle("Scanner une liste")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Annuler") {
                            dismiss()
                        }
                    }
                    
                    if !scannedItems.isEmpty {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Nouveau scan") {
                                showScanner = true
                                scannedItems = []
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showScanner, onDismiss: {
            // Quand le scanner est fermé, charger les articles fictifs
            if scannedItems.isEmpty {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    scannedItems = mockedScannedItems
                }
            }
        }) {
            ScannerView { textPerPage in
                // Traitement du texte reconnu par l'OCR (en conditions réelles)
                // Pour cette démo, nous utilisons des données simulées à la place
                showScanner = false
            }
        }
        .sheet(isPresented: $showListSelection) {
            ListPickerView(selectedList: $selectedListId)
        }
    }
}

// Représentant UIKit pour VNDocumentCameraViewController
struct ScannerView: UIViewControllerRepresentable {
    var didFinishScanning: ([String]) -> Void
    
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scannerViewController = VNDocumentCameraViewController()
        scannerViewController.delegate = context.coordinator
        return scannerViewController
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(didFinishScanning: didFinishScanning)
    }
    
    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        var didFinishScanning: ([String]) -> Void
        
        init(didFinishScanning: @escaping ([String]) -> Void) {
            self.didFinishScanning = didFinishScanning
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            // Dans une vraie implémentation, nous traiterions les images scannées avec Vision
            // Pour cette démo, nous simulons simplement la fin du scan
            controller.dismiss(animated: true)
            didFinishScanning([])
        }
        
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            controller.dismiss(animated: true)
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            controller.dismiss(animated: true)
        }
    }
}

// Vue pour sélectionner une liste
struct ListPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedList: UUID?
    
    // Données d'exemple pour les listes
    private let sampleLists: [ListItem] = [
        ListItem(title: "Courses maison", icon: "house", numberOfItems: 12, price: 45.99, color: .blue, category: .maison),
        ListItem(title: "Courses enfants", icon: "person.2", numberOfItems: 8, price: 34.50, color: .orange, category: .enfants),
        ListItem(title: "Courses de la semaine", icon: "cart", numberOfItems: 15, price: 62.75, color: .green, category: .courses),
        ListItem(title: "Soirée pizza", icon: "fork.knife", numberOfItems: 6, price: 25.30, color: .red, category: .soiree)
    ]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(sampleLists) { list in
                    Button {
                        if let uuid = UUID(uuidString: list.id) {
                            selectedList = uuid
                        }
                        dismiss()
                    } label: {
                        HStack {
                            if let icon = list.icon {
                                Image(systemName: icon)
                                    .foregroundColor(.gray)
                            }
                            
                            Text(list.title)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    }
                }
            }
            .navigationTitle("Choisir une liste")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ScanListView()
} 
