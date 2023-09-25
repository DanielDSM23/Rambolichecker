//
//  productsView.swift
//  rambolitalentsCheckerApp
//
//  Created by Daniel Monteiro on 21/09/2023.
//

import SwiftUI
import Foundation

struct Product: Decodable {
    let productId: Int
    let name: String
}


struct productsView: View {
    @State var products: [Product] = []
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var selectedProductDetails: SelectedProductDetails
    var body: some View {
        NavigationView {
            List {
                ForEach(0..<products.count) { index in
                    
                    HStack {
                        AsyncImage(
                            url: URL(string: "https://checker.rambolitalents.daniel-monteiro.fr/getImage.php?id="+String(products[index].productId)),
                            content: { image in
                                image.resizable()
                                    .frame(maxWidth: 1920/20, maxHeight: 1080/20) // Adjust size as needed
                                    .padding(.trailing, 10) // Spacing between image and text
                            },
                            placeholder: {
                                ProgressView()
                            }
                        )
                        
                        
                        Text(products[index].name)
                            .frame(width: 160)
                        Spacer()
                        if(products[index].productId == selectedProductDetails.productIdSelected){
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .onTapGesture {
                        withAnimation {
                            selectedProductDetails.productIdSelected = products[index].productId
                            selectedProductDetails.productNameSelected = products[index].name
                        }
                    }
                }
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button("Revenir en arrière") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        Spacer()
                    }
                    Spacer()
                }
                
            }
            .navigationTitle("Selectionner le Produit")
        }.onAppear(){
            products = productList()
        }
    }
}

struct productsView_Previews: PreviewProvider {
    static var previews: some View {
        productsView()
    }
}


func productList() ->  [Product] {
    var products: [Product] = []
    let url = URL(string: "https://checker.rambolitalents.daniel-monteiro.fr/getProducts.php")!
    
    let group = DispatchGroup()
    
    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        defer {
            group.leave()
        }
        
        guard let jsonData = data else { return }
        do {
            let decodedData = try JSONDecoder().decode([Product].self, from: jsonData)
            products = decodedData
        } catch {
            print("Error decoding JSON: \(error)")
        }
    }
    
    group.enter()
    task.resume()
    
    let timeoutResult = group.wait(timeout: .now() + 10) // Wait for a maximum of 10 seconds
    
    if timeoutResult == .timedOut {
        task.cancel() // Cancel the request if it times out
    }
    print("recovered")
    return products
}
