//
//  HomeView.swift
//  Liquid
//
//  Created by Alberto Dominguez on 2/12/22.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        ScrollView{
            VStack {
                HStack (spacing: 4){
                    Spacer()
                    Button(action: {
                        // Do something...
                    }, label: {
                        Image(systemName: "pencil")
                            .resizable()
                            .frame(width: 30,height: 30)
                            .padding(.all, 40.0)
                    })
                    .buttonStyle(PlainButtonStyle())
                }
                Spacer(minLength: 900)
                Text("Hello World")
                    
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
.previewInterfaceOrientation(.portrait)
    }
}
