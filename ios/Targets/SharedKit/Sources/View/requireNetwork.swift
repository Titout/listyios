import Combine
import Network
import SwiftUI

extension View {
    public func requireNetwork() -> some View {
        modifier(RequireInternet())
    }
}

private struct RequireInternet: ViewModifier {
    @StateObject var nwMonitor = NetworkMonitor()
    
    func body(content: Content) -> some View {
        Group {
            if nwMonitor.isConnected {
                content
                    .animation(.default, value: nwMonitor.isConnected)
            } else {
                VStack {
                    Image(systemName: "wifi.slash")
                        .font(.system(size: 56))
                        .foregroundColor(.gray)
                    Text("No Internet Access")
                        .font(.headline)
                    Text("Connect to the internet and try again.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .animation(.default, value: nwMonitor.isConnected)
            }
        }
    }
} 