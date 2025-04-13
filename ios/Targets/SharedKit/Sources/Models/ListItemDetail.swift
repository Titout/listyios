import Foundation

public struct ListItemDetail: Identifiable, Equatable {
    public let id = UUID()
    public let name: String
    public let price: Double?
    public var isCompleted: Bool
    public let quantity: String?
    public let image: String?
    
    public init(name: String, price: Double?, isCompleted: Bool, quantity: String?, image: String?) {
        self.name = name
        self.price = price
        self.isCompleted = isCompleted
        self.quantity = quantity
        self.image = image
    }
    
    public static func == (lhs: ListItemDetail, rhs: ListItemDetail) -> Bool {
        lhs.id == rhs.id
    }
} 