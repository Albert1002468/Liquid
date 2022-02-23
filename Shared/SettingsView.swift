//
//  SettingsView.swift
//  Liquid
//
//  Created by Alberto Dominguez on 2/12/22.
//

import SwiftUI
import Firebase
import GoogleSignIn

struct SettingsView: View {
    @EnvironmentObject var viewModel: AppViewModel
    var body: some View {
        VStack(spacing: 15) {
            Text("Logged In")
            
            Button("Logout") {
                viewModel.signOut()
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
